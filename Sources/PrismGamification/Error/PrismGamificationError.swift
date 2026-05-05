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
        }
    }
}
