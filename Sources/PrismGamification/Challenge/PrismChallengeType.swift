import Foundation

/// The kind of goal a challenge tracks.
public enum PrismChallengeType: String, Codable, Sendable, CaseIterable {
    /// Completed by incrementing a counter to reach a numeric goal.
    case counter
    /// Completed by reaching a binary objective.
    case milestone
}
