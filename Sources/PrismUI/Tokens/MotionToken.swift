import SwiftUI

/// Animation duration and curve tokens.
///
/// Every animation in the design system uses these tokens.
/// All animations are automatically disabled when the user
/// has enabled "Reduce Motion" in accessibility settings.
public enum MotionToken: Sendable, CaseIterable {
    case instant
    case fast
    case normal
    case slow
    case expressive
    case snappy
    case bouncy
    case smooth

    /// The duration in seconds for this motion token.
    public var duration: Double {
        switch self {
        case .instant: 0.1
        case .fast: 0.15
        case .normal: 0.25
        case .slow: 0.35
        case .expressive: 0.5
        case .snappy: 0.25
        case .bouncy: 0.35
        case .smooth: 0.3
        }
    }

    /// The SwiftUI animation configured with this token's duration and curve.
    public var animation: Animation {
        switch self {
        case .instant:
            .linear(duration: duration)
        case .fast:
            .easeOut(duration: duration)
        case .normal:
            .easeInOut(duration: duration)
        case .slow:
            .easeInOut(duration: duration)
        case .expressive:
            .spring(duration: duration, bounce: 0.2)
        case .snappy:
            .snappy
        case .bouncy:
            .bouncy
        case .smooth:
            .smooth
        }
    }
}
