import SwiftUI

/// Layout direction for bidirectional text and UI support.
public enum PrismLayoutDirection: Sendable, CaseIterable {
    /// Left-to-right layout (English, German, etc.).
    case leftToRight
    /// Right-to-left layout (Arabic, Hebrew, etc.).
    case rightToLeft
    /// Automatic direction based on the current environment locale.
    case auto
}

/// Directional edge that resolves to physical left/right based on layout direction.
public enum PrismDirectionalEdge: Sendable, CaseIterable {
    /// Leading edge (left in LTR, right in RTL).
    case leading
    /// Trailing edge (left in RTL, right in LTR).
    case trailing

    /// Resolves this directional edge to a physical edge for the given layout direction.
    public func resolved(for direction: LayoutDirection) -> Edge {
        switch (self, direction) {
        case (.leading, .leftToRight), (.trailing, .rightToLeft):
            return .leading
        case (.trailing, .leftToRight), (.leading, .rightToLeft):
            return .trailing
        @unknown default:
            return .leading
        }
    }
}

// MARK: - View Modifier

extension View {

    /// Sets the layout direction for this view and its descendants.
    public func prismLayoutDirection(_ direction: PrismLayoutDirection) -> some View {
        modifier(PrismLayoutDirectionModifier(direction: direction))
    }
}

/// Modifier that applies a layout direction to the environment.
private struct PrismLayoutDirectionModifier: ViewModifier {
    let direction: PrismLayoutDirection
    @Environment(\.locale) private var locale

    func body(content: Content) -> some View {
        switch direction {
        case .leftToRight:
            content.environment(\.layoutDirection, .leftToRight)
        case .rightToLeft:
            content.environment(\.layoutDirection, .rightToLeft)
        case .auto:
            content.environment(\.layoutDirection, resolvedDirection)
        }
    }

    private var resolvedDirection: LayoutDirection {
        let language = locale.language.languageCode?.identifier ?? "en"
        let rtlLanguages: Set<String> = ["ar", "he", "fa", "ur", "ps", "sd", "yi", "ku"]
        return rtlLanguages.contains(language) ? .rightToLeft : .leftToRight
    }
}

// MARK: - Bidirectional Stack

/// HStack that automatically reverses child order in right-to-left layouts.
public struct PrismBidirectionalStack<Content: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection
    private let alignment: VerticalAlignment
    private let spacing: CGFloat?
    private let content: Content

    /// Creates a bidirectional stack with the given alignment and spacing.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    /// The stack body that lays out children horizontally with environment-aware direction.
    public var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            content
        }
        .environment(\.layoutDirection, layoutDirection)
    }
}
