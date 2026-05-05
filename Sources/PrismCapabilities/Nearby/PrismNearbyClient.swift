import Foundation

// MARK: - Nearby Object

/// Represents a nearby device discovered via NearbyInteraction.
///
/// Wraps the peer's discovery token along with optional distance and direction
/// measurements provided by the UWB (Ultra-Wideband) hardware.
///
/// - Note: Distance and direction may be `nil` when line-of-sight is obstructed
///   or the hardware does not support directional measurements (e.g. Apple Watch).
public struct PrismNearbyObject: Sendable {
    /// The discovery token that uniquely identifies the peer.
    public let peerToken: Data
    /// Distance to the peer in meters, if available.
    public let distance: Float?
    /// Unit vector pointing toward the peer in the device's coordinate system.
    public let direction: SIMD3<Float>?

    /// Creates a new nearby object with the given peer token and optional spatial measurements.
    public init(peerToken: Data, distance: Float? = nil, direction: SIMD3<Float>? = nil) {
        self.peerToken = peerToken
        self.distance = distance
        self.direction = direction
    }
}

// MARK: - Session State

/// The lifecycle state of a NearbyInteraction session.
///
/// Maps to `NISession` delegate callbacks so consumers can react to
/// state changes without importing NearbyInteraction directly.
public enum PrismNearbySessionState: Sendable, CaseIterable {
    /// The session has not been started.
    case idle
    /// The session is actively discovering and ranging peers.
    case running
    /// The session was temporarily suspended (e.g. app backgrounded).
    case suspended
    /// The session has been permanently invalidated and cannot be restarted.
    case invalidated
}

// MARK: - Nearby Client

#if canImport(NearbyInteraction) && os(iOS)
    import NearbyInteraction

    /// Observable client that manages a NearbyInteraction session for peer discovery
    /// and UWB-based spatial awareness.
    ///
    /// Uses `NISession` under the hood to generate discovery tokens, start ranging,
    /// and publish nearby object updates. The session delegate is forwarded through
    /// the `@Observable` properties so SwiftUI views update automatically.
    ///
    /// ## Example
    /// ```swift
    /// let client = PrismNearbyClient()
    /// if let token = client.generateToken() {
    ///     // Exchange token with peer via MultipeerConnectivity or another channel
    ///     client.start(peerToken: peerToken)
    /// }
    /// ```
    @MainActor @Observable
    public final class PrismNearbyClient: NSObject, NISessionDelegate {
        /// Current state of the NearbyInteraction session.
        public private(set) var sessionState: PrismNearbySessionState = .idle
        /// All nearby objects currently being tracked.
        public private(set) var nearbyObjects: [PrismNearbyObject] = []

        private var session: NISession?

        /// Creates a new nearby interaction client.
        public override init() {
            super.init()
        }

        /// Starts a NearbyInteraction session with the given peer discovery token.
        ///
        /// Creates a new `NISession`, assigns this client as the delegate, and runs
        /// the session with the peer's token. Any previously running session is
        /// invalidated first.
        ///
        /// - Parameter peerToken: The discovery token received from the remote peer.
        public func start(peerToken: Data) {
            session?.invalidate()
            let niSession = NISession()
            niSession.delegate = self
            session = niSession

            guard let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: peerToken)
            else { return }
            let config = NINearbyPeerConfiguration(peerToken: token)
            niSession.run(config)
            sessionState = .running
        }

        /// Stops and invalidates the current NearbyInteraction session.
        public func stop() {
            session?.invalidate()
            session = nil
            sessionState = .idle
            nearbyObjects = []
        }

        /// Generates a discovery token for this device.
        ///
        /// The token must be exchanged with the remote peer (e.g. via
        /// MultipeerConnectivity) before calling `start(peerToken:)`.
        ///
        /// - Returns: The serialized discovery token data, or `nil` if unavailable.
        public func generateToken() -> Data? {
            let niSession = NISession()
            session = niSession
            guard let token = niSession.discoveryToken else { return nil }
            return try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
        }

        // MARK: - NISessionDelegate

        /// Serializes an `NIDiscoveryToken` to `Data` using secure coding.
        private nonisolated func tokenData(from token: NIDiscoveryToken) -> Data {
            (try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)) ?? Data()
        }

        nonisolated public func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
            let objects = nearbyObjects.map { obj in
                PrismNearbyObject(
                    peerToken: tokenData(from: obj.discoveryToken),
                    distance: obj.distance,
                    direction: obj.direction
                )
            }
            Task { @MainActor in
                self.nearbyObjects = objects
            }
        }

        nonisolated public func session(
            _ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason
        ) {
            let removedTokens = Set(nearbyObjects.map { tokenData(from: $0.discoveryToken) })
            Task { @MainActor in
                self.nearbyObjects.removeAll { removedTokens.contains($0.peerToken) }
            }
        }

        nonisolated public func sessionWasSuspended(_ session: NISession) {
            Task { @MainActor in
                self.sessionState = .suspended
            }
        }

        nonisolated public func sessionSuspensionEnded(_ session: NISession) {
            Task { @MainActor in
                self.sessionState = .running
            }
        }

        nonisolated public func session(_ session: NISession, didInvalidateWith error: Error) {
            Task { @MainActor in
                self.sessionState = .invalidated
                self.nearbyObjects = []
            }
        }
    }
#endif
