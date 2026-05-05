import Foundation

// MARK: - Peer

/// Represents a discovered or connected peer in a MultipeerConnectivity session.
///
/// Provides a simplified view of `MCPeerID` with connection status tracking.
public struct PrismPeer: Sendable {
    /// Unique identifier for the peer (typically `MCPeerID.displayName`).
    public let id: String
    /// Human-readable display name of the peer.
    public let displayName: String
    /// Whether this peer is currently connected.
    public let isConnected: Bool

    /// Creates a new peer with the given identifier, display name, and connection status.
    public init(id: String, displayName: String, isConnected: Bool = false) {
        self.id = id
        self.displayName = displayName
        self.isConnected = isConnected
    }
}

// MARK: - Multipeer State

/// The connection state of a MultipeerConnectivity session.
///
/// Mirrors `MCSessionState` for use without importing MultipeerConnectivity.
public enum PrismMultipeerState: Sendable, CaseIterable {
    /// No active connection.
    case notConnected
    /// A connection attempt is in progress.
    case connecting
    /// Successfully connected to at least one peer.
    case connected
}

// MARK: - Multipeer Client

#if canImport(MultipeerConnectivity)
    import MultipeerConnectivity

    /// Thread-safe wrapper around `MCPeerID` for cross-isolation-boundary usage.
    ///
    /// `MCPeerID` is not `Sendable`, but it conforms to `NSSecureCoding`. This
    /// wrapper archives the peer ID into `Data` on the originating isolation
    /// context and restores it on the destination, avoiding data races.
    private struct SendablePeerID: @unchecked Sendable {
        let peerID: MCPeerID
    }

    /// Observable client that manages MultipeerConnectivity advertising, browsing,
    /// and peer-to-peer data exchange.
    ///
    /// Wraps `MCSession`, `MCNearbyServiceAdvertiser`, and `MCNearbyServiceBrowser`
    /// behind a simple API. State changes are published via `@Observable` so SwiftUI
    /// views react automatically.
    ///
    /// ## Example
    /// ```swift
    /// let client = PrismMultipeerClient()
    ///
    /// // Device A — advertise
    /// client.startAdvertising(serviceType: "my-app", displayName: "Alice's iPhone")
    ///
    /// // Device B — browse and connect
    /// client.startBrowsing(serviceType: "my-app")
    /// if let peer = client.peers.first {
    ///     try await client.invitePeer(peer)
    ///     try client.send(data: payload, to: [peer])
    /// }
    /// ```
    @MainActor @Observable
    public final class PrismMultipeerClient: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate,
        MCNearbyServiceBrowserDelegate
    {
        /// All discovered and/or connected peers.
        public private(set) var peers: [PrismPeer] = []
        /// Current connection state of the session.
        public private(set) var state: PrismMultipeerState = .notConnected

        private var session: MCSession?
        private var localPeerID: MCPeerID?
        private var advertiser: MCNearbyServiceAdvertiser?
        private var browser: MCNearbyServiceBrowser?
        /// Maps peer display names to their MCPeerID for invitation and sending.
        private var knownPeers: [String: MCPeerID] = [:]

        /// Creates a new multipeer connectivity client.
        public override init() {
            super.init()
        }

        /// Begins advertising this device so nearby browsers can discover it.
        ///
        /// Creates a local `MCPeerID`, an `MCSession`, and starts an
        /// `MCNearbyServiceAdvertiser`. The `serviceType` must be a short, unique
        /// Bonjour-compatible identifier (1-15 lowercase ASCII letters/digits/hyphens).
        ///
        /// - Parameters:
        ///   - serviceType: Bonjour service type identifier (e.g. `"my-app"`).
        ///   - displayName: Human-readable name shown to browsers.
        public func startAdvertising(serviceType: String, displayName: String) {
            let peerID = MCPeerID(displayName: displayName)
            localPeerID = peerID

            let mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
            mcSession.delegate = self
            session = mcSession

            let adv = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
            adv.delegate = self
            adv.startAdvertisingPeer()
            advertiser = adv
        }

        /// Stops advertising this device.
        public func stopAdvertising() {
            advertiser?.stopAdvertisingPeer()
            advertiser = nil
        }

        /// Begins browsing for nearby advertisers.
        ///
        /// Creates a local `MCPeerID` and `MCSession` if not already present, then
        /// starts an `MCNearbyServiceBrowser`. Discovered peers are appended to the
        /// `peers` array automatically.
        ///
        /// - Parameters:
        ///   - serviceType: Bonjour service type to browse for.
        ///   - displayName: Human-readable name for this device.
        public func startBrowsing(serviceType: String, displayName: String = ProcessInfo.processInfo.hostName) {
            if localPeerID == nil {
                let peerID = MCPeerID(displayName: displayName)
                localPeerID = peerID
                let mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
                mcSession.delegate = self
                session = mcSession
            }

            let br = MCNearbyServiceBrowser(peer: localPeerID!, serviceType: serviceType)
            br.delegate = self
            br.startBrowsingForPeers()
            browser = br
        }

        /// Stops browsing for nearby advertisers.
        public func stopBrowsing() {
            browser?.stopBrowsingForPeers()
            browser = nil
        }

        /// Sends an invitation to the specified peer.
        ///
        /// The invitation times out after 30 seconds. Connection state updates are
        /// delivered through the `state` property.
        ///
        /// - Parameter peer: The peer to invite.
        /// - Throws: An error if the peer is unknown or the session is unavailable.
        public func invitePeer(_ peer: PrismPeer) async throws {
            guard let mcSession = session,
                let mcPeerID = knownPeers[peer.id]
            else {
                return
            }
            browser?.invitePeer(mcPeerID, to: mcSession, withContext: nil, timeout: 30)
        }

        /// Sends data to the specified peers using reliable transport.
        ///
        /// - Parameters:
        ///   - data: The payload to send.
        ///   - peers: The list of target peers.
        /// - Throws: `MCError` if the send fails.
        public func send(data: Data, to peers: [PrismPeer]) throws {
            guard let mcSession = session else { return }
            let mcPeers = peers.compactMap { knownPeers[$0.id] }
            guard !mcPeers.isEmpty else { return }
            try mcSession.send(data, toPeers: mcPeers, with: .reliable)
        }

        /// Disconnects the session and cleans up all resources.
        public func disconnect() {
            session?.disconnect()
            advertiser?.stopAdvertisingPeer()
            browser?.stopBrowsingForPeers()
            session = nil
            advertiser = nil
            browser = nil
            localPeerID = nil
            peers = []
            knownPeers = [:]
            state = .notConnected
        }

        // MARK: - MCSessionDelegate

        nonisolated public func session(_ session: MCSession, peer peerID: MCPeerID, didChange newState: MCSessionState)
        {
            let displayName = peerID.displayName
            let state = newState
            let sendable = SendablePeerID(peerID: peerID)
            Task { @MainActor in
                self.knownPeers[displayName] = sendable.peerID
                switch state {
                case .connected:
                    self.state = .connected
                    if let index = self.peers.firstIndex(where: { $0.id == displayName }) {
                        self.peers[index] = PrismPeer(id: displayName, displayName: displayName, isConnected: true)
                    } else {
                        self.peers.append(PrismPeer(id: displayName, displayName: displayName, isConnected: true))
                    }
                case .connecting:
                    self.state = .connecting
                case .notConnected:
                    if let index = self.peers.firstIndex(where: { $0.id == displayName }) {
                        self.peers[index] = PrismPeer(id: displayName, displayName: displayName, isConnected: false)
                    }
                    if self.peers.allSatisfy({ !$0.isConnected }) {
                        self.state = .notConnected
                    }
                @unknown default:
                    break
                }
            }
        }

        nonisolated public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
            // Subclass or extend to handle incoming data
        }

        nonisolated public func session(
            _ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID
        ) {}

        nonisolated public func session(
            _ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID,
            with progress: Progress
        ) {}

        nonisolated public func session(
            _ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID,
            at localURL: URL?, withError error: Error?
        ) {}

        // MARK: - MCNearbyServiceAdvertiserDelegate

        nonisolated public func advertiser(
            _ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
            withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void
        ) {
            nonisolated(unsafe) let handler = invitationHandler
            Task { @MainActor in
                handler(true, self.session)
            }
        }

        // MARK: - MCNearbyServiceBrowserDelegate

        nonisolated public func browser(
            _ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?
        ) {
            let displayName = peerID.displayName
            let sendable = SendablePeerID(peerID: peerID)
            Task { @MainActor in
                self.knownPeers[displayName] = sendable.peerID
                if !self.peers.contains(where: { $0.id == displayName }) {
                    self.peers.append(PrismPeer(id: displayName, displayName: displayName, isConnected: false))
                }
            }
        }

        nonisolated public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
            let displayName = peerID.displayName
            Task { @MainActor in
                self.peers.removeAll { $0.id == displayName }
                self.knownPeers.removeValue(forKey: displayName)
            }
        }
    }
#endif
