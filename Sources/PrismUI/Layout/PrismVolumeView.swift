import SwiftUI

#if os(visionOS)
/// Container for visionOS volumetric content with token-based styling.
///
/// ```swift
/// PrismVolumeView {
///     Model3D(named: "Globe")
/// }
/// ```
public struct PrismVolumeView<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let content: Content
    private let depth: CGFloat

    /// Creates a volume view with the specified depth offset.
    public init(
        depth: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.depth = depth
    }

    /// The content and behavior of the volume view.
    public var body: some View {
        content
            .offset(z: depth)
            .frame(depth: max(depth, 100))
    }
}

/// Themed ornament for visionOS windows.
public struct PrismOrnamentView<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let content: Content

    /// Creates an ornament view wrapping the given content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The content and behavior of the ornament.
    public var body: some View {
        content
            .padding(SpacingToken.md.rawValue)
            .glassBackgroundEffect()
    }
}
#endif
