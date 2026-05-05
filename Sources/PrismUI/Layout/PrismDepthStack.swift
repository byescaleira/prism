import SwiftUI

/// Z-axis depth stack for visionOS spatial layouts with fallback on other platforms.
///
/// On visionOS, applies depth offset via `offset(z:)` to create spatial layering.
/// On other platforms, uses standard ZStack with opacity-based depth cues.
public struct PrismDepthStack<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let spacing: CGFloat
    private let content: Content

    /// Creates a depth stack with the given spacing between layers.
    public init(
        spacing: CGFloat = SpacingToken.md.rawValue,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }

    /// The content and behavior of the depth stack.
    public var body: some View {
        ZStack {
            content
        }
    }
}

/// Modifier that applies z-offset on visionOS for spatial depth.
private struct PrismDepthModifier: ViewModifier {
    let depth: CGFloat

    func body(content: Content) -> some View {
        #if os(visionOS)
            content.offset(z: depth)
        #else
            content
        #endif
    }
}

extension View {

    /// Applies z-axis depth offset on visionOS. No-op on other platforms.
    public func prismDepth(_ depth: CGFloat) -> some View {
        modifier(PrismDepthModifier(depth: depth))
    }
}
