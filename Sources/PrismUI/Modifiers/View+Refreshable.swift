import SwiftUI

extension View {

    /// Adds themed pull-to-refresh.
    public func prismRefreshable(action: @escaping @Sendable () async -> Void) -> some View {
        refreshable(action: action)
    }
}
