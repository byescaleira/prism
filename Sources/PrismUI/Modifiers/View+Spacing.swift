import SwiftUI

extension View {

    /// Applies uniform padding using a spacing token.
    public func prismPadding(_ token: SpacingToken) -> some View {
        padding(token.rawValue)
    }

    /// Applies padding on specific edges using a spacing token.
    public func prismPadding(_ edges: Edge.Set, _ token: SpacingToken) -> some View {
        padding(edges, token.rawValue)
    }

    /// Applies horizontal and vertical padding using spacing tokens.
    public func prismPadding(
        horizontal: SpacingToken,
        vertical: SpacingToken
    ) -> some View {
        padding(.horizontal, horizontal.rawValue)
            .padding(.vertical, vertical.rawValue)
    }

    /// Applies spacing between items in stacks.
    public func prismSpacing(_ token: SpacingToken) -> some View {
        environment(\.prismStackSpacing, token)
    }
}

// MARK: - Stack Spacing Environment

private struct PrismStackSpacingKey: EnvironmentKey {
    static let defaultValue: SpacingToken = .md
}

extension EnvironmentValues {
    public var prismStackSpacing: SpacingToken {
        get { self[PrismStackSpacingKey.self] }
        set { self[PrismStackSpacingKey.self] = newValue }
    }
}
