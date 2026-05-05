#if canImport(SwiftData)
    import Foundation

    /// Sendable snapshot of a leaderboard, safe to pass across actor boundaries.
    public struct PrismLeaderboardSnapshot: Sendable {
        /// Ranked entries in the leaderboard.
        public let entries: [PrismLeaderboardEntry]
        /// The period this leaderboard covers.
        public let period: PrismLeaderboardPeriod
        /// When this snapshot was generated.
        public let generatedAt: Date
    }

    extension PrismLeaderboardRecord {
        /// Converts this record to a ranked ``PrismLeaderboardEntry``.
        public func toEntry(rank: Int) -> PrismLeaderboardEntry {
            PrismLeaderboardEntry(
                id: userID,
                displayName: displayName,
                score: score,
                rank: rank
            )
        }
    }
#endif
