import SwiftUI

/// Conforming types can be reloaded by the live reload server.
public protocol PrismLiveReloadable: AnyObject, Sendable {
    /// Performs a reload of the conforming object.
    @MainActor func reload()
}

/// Coordinates live reload across registered reloadable objects.
@Observable
@MainActor
public final class PrismLiveReloadServer {
    /// Whether the server is currently connected and active.
    public private(set) var isConnected: Bool = false
    /// The date of the most recent reload, if any.
    public private(set) var lastReloadDate: Date?

    private var reloadables: [any PrismLiveReloadable] = []

    /// Creates a live reload server.
    public init() {}

    /// Registers a reloadable object for future reload events.
    public func register(_ reloadable: any PrismLiveReloadable) {
        reloadables.append(reloadable)
        isConnected = true
    }

    /// Triggers reload on all registered objects and updates the timestamp.
    public func triggerReload() {
        for reloadable in reloadables {
            reloadable.reload()
        }
        lastReloadDate = Date()
    }

    /// Removes all registered objects and disconnects.
    public func disconnect() {
        reloadables.removeAll()
        isConnected = false
    }
}

// MARK: - Status Banner

/// Displays the current live reload connection status.
public struct PrismLiveReloadBanner: View {
    let server: PrismLiveReloadServer

    /// Creates a banner showing the live reload server status.
    public init(server: PrismLiveReloadServer) {
        self.server = server
    }

    /// The banner view body with connection indicator and last reload time.
    public var body: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            Circle()
                .fill(server.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)

            Text(server.isConnected ? "Live Reload Connected" : "Live Reload Disconnected")
                .font(TypographyToken.caption.font)
                .foregroundStyle(server.isConnected ? .primary : .secondary)

            if let date = server.lastReloadDate {
                Spacer()
                Text(date, style: .time)
                    .font(TypographyToken.caption2.font)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, SpacingToken.md.rawValue)
        .padding(.vertical, SpacingToken.xs.rawValue)
        .background(.ultraThinMaterial)
        .clipShape(RadiusToken.sm.shape)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            server.isConnected ? "Live reload connected" : "Live reload disconnected"
        )
    }
}
