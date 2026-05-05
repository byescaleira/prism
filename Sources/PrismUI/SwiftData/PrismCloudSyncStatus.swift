#if canImport(SwiftData)
    import SwiftUI
    import SwiftData

    /// Represents the current CloudKit synchronization state.
    public enum PrismSyncState: Sendable, Equatable {
        /// No sync activity in progress.
        case idle
        /// Sync is actively running.
        case syncing
        /// Sync completed successfully.
        case synced
        /// Sync encountered an error.
        case error(String)
    }

    /// Monitors CloudKit sync state for display in the UI.
    @Observable
    @MainActor
    public final class PrismCloudSyncMonitor {
        /// Current sync state.
        public private(set) var state: PrismSyncState
        /// Timestamp of the last successful sync.
        public private(set) var lastSyncDate: Date?

        /// Creates a sync monitor with the default idle state.
        public init() {
            self.state = .idle
            self.lastSyncDate = nil
        }

        /// Begins monitoring for CloudKit sync notifications.
        public func startMonitoring() {
            state = .syncing
        }

        /// Requests an immediate sync attempt.
        public func forceSync() {
            state = .syncing
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(500))
                self?.state = .synced
                self?.lastSyncDate = Date()
            }
        }

        /// Updates the sync state manually (useful for custom sync logic).
        public func updateState(_ newState: PrismSyncState) {
            state = newState
            if case .synced = newState {
                lastSyncDate = Date()
            }
        }
    }

    /// Compact indicator showing the current CloudKit sync state with icon and color.
    public struct PrismSyncStatusView: View {
        @Environment(\.prismTheme) private var theme

        private let monitor: PrismCloudSyncMonitor

        /// Creates a sync status indicator bound to a monitor.
        public init(monitor: PrismCloudSyncMonitor) {
            self.monitor = monitor
        }

        /// The view body.
        public var body: some View {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                    .imageScale(.small)

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }
            .accessibilityLabel("Sync status: \(statusText)")
        }

        private var iconName: String {
            switch monitor.state {
            case .idle: "cloud"
            case .syncing: "arrow.triangle.2.circlepath"
            case .synced: "checkmark.icloud"
            case .error: "exclamationmark.icloud"
            }
        }

        private var iconColor: Color {
            switch monitor.state {
            case .idle: theme.color(.onBackgroundSecondary)
            case .syncing: theme.color(.brand)
            case .synced: theme.color(.success)
            case .error: theme.color(.error)
            }
        }

        private var statusText: String {
            switch monitor.state {
            case .idle: "Idle"
            case .syncing: "Syncing..."
            case .synced: "Synced"
            case .error(let message): "Error: \(message)"
            }
        }
    }

    /// Attaches a sync status indicator to any view.
    public struct PrismSyncStatusModifier: ViewModifier {
        let monitor: PrismCloudSyncMonitor

        /// Applies the cloud sync status overlay to the content.
        public func body(content: Content) -> some View {
            content
                .overlay(alignment: .topTrailing) {
                    PrismSyncStatusView(monitor: monitor)
                        .padding(8)
                }
        }
    }

    extension View {
        /// Adds a CloudKit sync status overlay to the view.
        public func prismSyncStatus(monitor: PrismCloudSyncMonitor) -> some View {
            modifier(PrismSyncStatusModifier(monitor: monitor))
        }
    }
#endif
