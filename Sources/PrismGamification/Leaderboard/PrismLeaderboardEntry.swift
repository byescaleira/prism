import Foundation

/// A single ranked entry in a leaderboard, safe to pass across actor boundaries.
public struct PrismLeaderboardEntry: Sendable, Identifiable, Comparable, Equatable {
    /// The user identifier.
    public let id: String
    /// The user's display name.
    public let displayName: String
    /// The user's score for the period.
    public let score: Int
    /// The user's rank (1 = first place).
    public let rank: Int

    /// Creates a new leaderboard entry.
    public init(id: String, displayName: String, score: Int, rank: Int) {
        self.id = id
        self.displayName = displayName
        self.score = score
        self.rank = rank
    }

    /// Compares entries by rank ascending (rank 1 is "best").
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rank < rhs.rank
    }
}
