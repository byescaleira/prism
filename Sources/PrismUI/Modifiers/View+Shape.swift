import SwiftUI

extension View {

    /// Clips the view with a continuous corner radius.
    public func prismRadius(_ token: RadiusToken) -> some View {
        clipShape(token.shape)
    }

    /// Applies a themed background with continuous corner radius.
    public func prismSurface(
        _ colorToken: ColorToken = .surface,
        radius: RadiusToken = .md
    ) -> some View {
        modifier(SurfaceModifier(colorToken: colorToken, radius: radius))
    }

    /// Applies an elevation shadow.
    public func prismElevation(_ token: ElevationToken) -> some View {
        shadow(
            color: .black.opacity(token.shadowOpacity),
            radius: token.shadowRadius,
            y: token.shadowY
        )
    }

    /// Applies a themed border with continuous corner radius.
    public func prismBorder(
        _ colorToken: ColorToken = .border,
        radius: RadiusToken = .md,
        width: CGFloat = 1
    ) -> some View {
        modifier(BorderModifier(colorToken: colorToken, radius: radius, width: width))
    }
}

// MARK: - Modifiers

private struct SurfaceModifier: ViewModifier {
    @Environment(\.prismTheme) private var theme
    let colorToken: ColorToken
    let radius: RadiusToken

    func body(content: Content) -> some View {
        content
            .background(theme.color(colorToken), in: radius.shape)
    }
}

private struct BorderModifier: ViewModifier {
    @Environment(\.prismTheme) private var theme
    let colorToken: ColorToken
    let radius: RadiusToken
    let width: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(radius.shape.stroke(theme.color(colorToken), lineWidth: width))
    }
}
