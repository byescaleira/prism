import Foundation

/// Events emitted when challenge or streak state changes.
public enum PrismChallengeEvent: Sendable {
    /// Challenge completed.
    case completed(challengeID: String, points: Int)
    /// Counter challenge progressed.
    case progressed(challengeID: String, currentValue: Int, goalValue: Int)
    /// Streak extended.
    case streakExtended(streakID: String, currentStreak: Int)
    /// Streak broken.
    case streakBroken(streakID: String, previousStreak: Int)
    /// New longest streak record.
    case newStreakRecord(streakID: String, longestStreak: Int)
}
