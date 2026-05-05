import SwiftUI

/// Elevation tokens combining shadow and material tiers.
///
/// Maps to Apple's visual hierarchy — higher elevation
/// means more visual prominence and separation from background.
public enum ElevationToken: Int, Sendable, CaseIterable, Comparable {
    case flat = 0
    case low = 1
    case medium = 2
    case high = 3
    case overlay = 4

    /// The blur radius of the shadow for this elevation level.
    public var shadowRadius: CGFloat {
        switch self {
        case .flat: 0
        case .low: 2
        case .medium: 4
        case .high: 8
        case .overlay: 16
        }
    }

    /// The vertical offset of the shadow for this elevation level.
    public var shadowY: CGFloat {
        switch self {
        case .flat: 0
        case .low: 1
        case .medium: 2
        case .high: 4
        case .overlay: 8
        }
    }

    /// The opacity of the shadow color for this elevation level.
    public var shadowOpacity: Double {
        switch self {
        case .flat: 0
        case .low: 0.06
        case .medium: 0.1
        case .high: 0.15
        case .overlay: 0.2
        }
    }

    /// Compares two elevation tokens by their raw tier value.
    public static func < (lhs: ElevationToken, rhs: ElevationToken) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
