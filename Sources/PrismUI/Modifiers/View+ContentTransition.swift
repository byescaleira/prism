import SwiftUI

/// Named content transition presets.
public enum PrismContentTransition: Sendable {
    case numericText
    case numericTextCountdown
    case interpolate
    case opacity
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
