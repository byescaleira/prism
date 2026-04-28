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

    public var shadowRadius: CGFloat {
        switch self {
        case .flat: 0
        case .low: 2
        case .medium: 4
        case .high: 8
        case .overlay: 16
        }
    }

    public var shadowY: CGFloat {
        switch self {
        case .flat: 0
        case .low: 1
        case .medium: 2
        case .high: 4
        case .overlay: 8
        }
    }

    public var shadowOpacity: Double {
        switch self {
        case .flat: 0
        case .low: 0.06
        case .medium: 0.1
        case .high: 0.15
        case .overlay: 0.2
        }
    }

    public static func < (lhs: ElevationToken, rhs: ElevationToken) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
