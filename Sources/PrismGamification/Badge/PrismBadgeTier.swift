import Foundation

/// Tier levels for badges, ordered from lowest to highest.
public enum PrismBadgeTier: String, Codable, Sendable, CaseIterable, Comparable {
    case bronze
    case silver
    case gold
    case platinum
    case diamond

    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard let l = allCases.firstIndex(of: lhs),
              let r = allCases.firstIndex(of: rhs)
        else { return false }
        return l < r
    }
}
