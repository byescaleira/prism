import Foundation

/// Condition that must be met for a badge to be unlocked.
public enum PrismBadgeCondition: Sendable, Equatable {
    /// A specific challenge must be completed.
    case challengeCompleted(challengeID: String)
    /// Total points must reach the given threshold.
    case pointsReached(threshold: Int)
    /// A streak must reach the given number of consecutive days.
    case streakReached(streakID: String, days: Int)
    /// Custom condition evaluated by the caller.
    case custom(id: String)
}
