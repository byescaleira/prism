import Foundation

/// Errors produced by the gamification module.
public enum PrismGamificationError: Error, Sendable, Equatable {
    /// Challenge identifier not found.
    case challengeNotFound(String)
    /// Challenge already completed.
    case challengeAlreadyCompleted(String)
    /// Persistence layer error.
    case persistenceFailed(String)
    /// Invalid operation attempted.
    case invalidOperation(String)
    /// Streak identifier not found.
    case streakNotFound(String)
    /// Badge identifier not found.
    case badgeNotFound(String)
    /// Badge already unlocked.
    case badgeAlreadyUnlocked(String)
    /// Leaderboard entry not found.
    case leaderboardEntryNotFound(String)
}

extension PrismGamificationError: LocalizedError {
    /// The error description.
    public var errorDescription: String? {
        switch self {
        case .challengeNotFound(let id):
            "Challenge not found: \(id)"
        case .challengeAlreadyCompleted(let id):
            "Challenge already completed: \(id)"
        case .persistenceFailed(let message):
            "Persistence failed: \(message)"
        case .invalidOperation(let message):
            "Invalid operation: \(message)"
        case .streakNotFound(let id):
            "Streak not found: \(id)"
        case .badgeNotFound(let id):
            "Badge not found: \(id)"
        case .badgeAlreadyUnlocked(let id):
            "Badge already unlocked: \(id)"
        case .leaderboardEntryNotFound(let id):
            "Leaderboard entry not found: \(id)"
        }
    }
}
