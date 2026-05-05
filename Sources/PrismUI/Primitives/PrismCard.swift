import SwiftUI

/// Themed card container with elevation, radius, and optional interactivity.
public struct PrismCard<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let surface: ColorToken
    private let radius: RadiusToken
    private let elevation: ElevationToken
    private let content: Content

    /// Creates a card with a surface color, corner radius, and elevation.
    public init(
        surface: ColorToken = .surface,
        radius: RadiusToken = .lg,
        elevation: ElevationToken = .low,
        @ViewBuilder content: () -> Content
    ) {
        self.surface = surface
        self.radius = radius
        self.elevation = elevation
        self.content = content()
    }

    /// The content and behavior of the card.
    public var body: some View {
        content
            .padding(SpacingToken.lg.rawValue)
            .background(theme.color(surface), in: radius.shape)
            .prismElevation(elevation)
    }
}
