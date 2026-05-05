import SwiftUI

/// Typography scale aligned with Apple's Dynamic Type system.
///
/// Each case maps to a `Font.TextStyle` and carries
/// weight + tracking metadata for full typographic control.
public enum TypographyToken: Sendable, CaseIterable {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption
    case caption2

    /// The corresponding Dynamic Type text style.
    public var textStyle: Font.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption
        case .caption2: .caption2
        }
    }

    /// The default font weight for this typography level.
    public var defaultWeight: Font.Weight {
        switch self {
        case .largeTitle: .bold
        case .title: .bold
        case .title2: .bold
        case .title3: .semibold
        case .headline: .semibold
        case .subheadline: .regular
        case .body: .regular
        case .callout: .regular
        case .footnote: .regular
        case .caption: .regular
        case .caption2: .regular
        }
    }

    /// A system font using this token's text style and default weight.
    public var font: Font {
        .system(textStyle, weight: defaultWeight)
    }

    /// Returns a font with the given weight override.
    public func font(weight: Font.Weight) -> Font {
        .system(textStyle, weight: weight)
    }

    /// Returns a font with the given weight and design.
    public func font(weight: Font.Weight, design: Font.Design) -> Font {
        .system(textStyle, design: design, weight: weight)
    }

    /// Returns a font with the given weight and width.
    public func font(weight: Font.Weight, width: Font.Width) -> Font {
        .system(textStyle, weight: weight).width(width)
    }

    /// Returns a font with the given weight, design, and width.
    public func font(weight: Font.Weight, design: Font.Design, width: Font.Width) -> Font {
        .system(textStyle, design: design, weight: weight).width(width)
    }
}
