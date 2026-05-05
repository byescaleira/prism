import Foundation

/// Categories of AI-generated gamification messages.
public enum PrismGamificationMessageKind: String, Codable, Sendable, CaseIterable {
    /// Celebration message when a challenge is completed.
    case challengeCompleted
    /// Motivational nudge for an in-progress challenge.
    case challengeProgress
    /// Daily streak encouragement.
    case streakMotivation
    /// Alert when a streak is at risk of breaking.
    case streakAtRisk
    /// Congratulation for unlocking a badge.
    case badgeUnlocked
    /// Commentary on leaderboard position changes.
    case leaderboardUpdate
    /// Personalized challenge recommendation.
    case challengeRecommendation
}
