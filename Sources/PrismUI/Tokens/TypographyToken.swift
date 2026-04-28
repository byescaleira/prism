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

    public var font: Font {
        .system(textStyle, weight: defaultWeight)
    }

    public func font(weight: Font.Weight) -> Font {
        .system(textStyle, weight: weight)
    }

    public func font(weight: Font.Weight, design: Font.Design) -> Font {
        .system(textStyle, design: design, weight: weight)
    }
}
