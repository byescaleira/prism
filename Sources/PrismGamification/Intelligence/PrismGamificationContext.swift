import Foundation

/// Contextual data for AI-generated gamification messages.
public struct PrismGamificationContext: Sendable, Equatable {
    /// The entity ID (challenge, badge, streak, or user).
    public let entityID: String
    /// Challenge title, if applicable.
    public let challengeTitle: String?
    /// Current progress value.
    public let currentValue: Int?
    /// Goal value for the challenge.
    public let goalValue: Int?
    /// Points earned for this action.
    public let points: Int?
    /// Total accumulated points.
    public let totalPoints: Int?
    /// Current streak count.
    public let currentStreak: Int?
    /// Longest streak ever.
    public let longestStreak: Int?
    /// Badge display title.
    public let badgeTitle: String?
    /// Badge tier name.
    public let badgeTier: String?
    /// Current leaderboard rank.
    public let rank: Int?
    /// Previous leaderboard rank.
    public let previousRank: Int?
    /// Current score.
    public let score: Int?
    /// Number of completed challenges.
    public let completedChallenges: Int?
    /// Active challenge categories.
    public let activeCategories: [String]?

    /// Creates gamification context.
    public init(
        entityID: String,
        challengeTitle: String? = nil,
        currentValue: Int? = nil,
        goalValue: Int? = nil,
        points: Int? = nil,
        totalPoints: Int? = nil,
        currentStreak: Int? = nil,
        longestStreak: Int? = nil,
        badgeTitle: String? = nil,
        badgeTier: String? = nil,
        rank: Int? = nil,
        previousRank: Int? = nil,
        score: Int? = nil,
        completedChallenges: Int? = nil,
        activeCategories: [String]? = nil
    ) {
        self.entityID = entityID
        self.challengeTitle = challengeTitle
        self.currentValue = currentValue
        self.goalValue = goalValue
        self.points = points
        self.totalPoints = totalPoints
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.badgeTitle = badgeTitle
        self.badgeTier = badgeTier
        self.rank = rank
        self.previousRank = previousRank
        self.score = score
        self.completedChallenges = completedChallenges
        self.activeCategories = activeCategories
    }
}
