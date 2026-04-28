import SwiftUI

extension View {

    /// Applies a typography token with default weight.
    public func prismFont(_ token: TypographyToken) -> some View {
        font(token.font)
    }

    /// Applies a typography token with custom weight.
    public func prismFont(_ token: TypographyToken, weight: Font.Weight) -> some View {
        font(token.font(weight: weight))
    }

    /// Applies a typography token with custom weight and design.
    public func prismFont(
        _ token: TypographyToken,
        weight: Font.Weight,
        design: Font.Design
    ) -> some View {
        font(token.font(weight: weight, design: design))
    }

    /// Applies a typography token with custom weight and font width.
    public func prismFont(
        _ token: TypographyToken,
        weight: Font.Weight,
        width: Font.Width
    ) -> some View {
        font(token.font(weight: weight, width: width))
    }

    /// Applies font width (expanded, condensed, compressed, standard).
    public func prismFontWidth(_ width: Font.Width) -> some View {
        fontWidth(width)
    }

    /// Applies a semantic foreground color from the current theme.
    public func prismColor(_ token: ColorToken) -> some View {
        modifier(ThemeColorModifier(token: token))
    }
}

private struct ThemeColorModifier: ViewModifier {
    @Environment(\.prismTheme) private var theme
    let token: ColorToken

    func body(content: Content) -> some View {
        content.foregroundStyle(theme.color(token))
    }
}
