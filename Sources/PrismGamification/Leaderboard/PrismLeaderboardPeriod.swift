import Foundation

/// Time period for leaderboard scoring and ranking.
public enum PrismLeaderboardPeriod: String, Codable, Sendable, CaseIterable {
    /// Daily leaderboard, reset every 24 hours.
    case daily
    /// Weekly leaderboard, reset every 7 days.
    case weekly
    /// Monthly leaderboard, reset every calendar month.
    case monthly
    /// All-time leaderboard, never reset.
    case allTime
}
