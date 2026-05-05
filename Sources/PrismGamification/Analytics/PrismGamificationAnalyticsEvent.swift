import Foundation

/// Structured analytics events for gamification.
public enum PrismGamificationAnalyticsEvent: Sendable {
    case challengeStarted(challengeID: String, at: Date)
    case challengeCompleted(challengeID: String, at: Date, duration: TimeInterval?)
    case challengeProgressed(challengeID: String, progress: Double)
    case streakExtended(streakID: String, currentStreak: Int)
    case streakBroken(streakID: String, previousStreak: Int)
    case badgeUnlocked(badgeID: String, tier: String)
    case leaderboardScoreSubmitted(userID: String, score: Int)

    /// Event type name for storage.
    public var eventType: String {
        switch self {
        case .challengeStarted: "challenge_started"
        case .challengeCompleted: "challenge_completed"
        case .challengeProgressed: "challenge_progressed"
        case .streakExtended: "streak_extended"
        case .streakBroken: "streak_broken"
        case .badgeUnlocked: "badge_unlocked"
        case .leaderboardScoreSubmitted: "leaderboard_score"
        }
    }

    /// Entity ID associated with the event.
    public var entityID: String {
        switch self {
        case .challengeStarted(let id, _),
            .challengeCompleted(let id, _, _),
            .challengeProgressed(let id, _):
            id
        case .streakExtended(let id, _),
            .streakBroken(let id, _):
            id
        case .badgeUnlocked(let id, _):
            id
        case .leaderboardScoreSubmitted(let id, _):
            id
        }
    }
}
