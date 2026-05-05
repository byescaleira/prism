import SwiftUI

/// Named content transition presets.
public enum PrismContentTransition: Sendable {
    /// Represents a numeric text counting-up transition.
    case numericText
    /// Represents a numeric text counting-down transition.
    case numericTextCountdown
    /// Represents an interpolated content transition.
    case interpolate
    /// Represents an opacity crossfade transition.
    case opacity
    /// Represents an identity transition with no visual change.
    case identity
}

extension View {

    /// Applies a named content transition.
    @ViewBuilder
    public func prismContentTransition(_ transition: PrismContentTransition) -> some View {
        switch transition {
        case .numericText:
            self.contentTransition(.numericText())
        case .numericTextCountdown:
            self.contentTransition(.numericText(countsDown: true))
        case .interpolate:
            self.contentTransition(.interpolate)
        case .opacity:
            self.contentTransition(.opacity)
        case .identity:
            self.contentTransition(.identity)
        }
    }
}
