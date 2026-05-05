import Foundation

/// Builds prompts for AI-generated gamification messages.
public struct PrismGamificationPromptBuilder: Sendable {

    /// Creates a prompt builder.
    public init() {}

    /// Builds a prompt for the given message kind and context.
    public func prompt(
        for kind: PrismGamificationMessageKind,
        context: PrismGamificationContext
    ) -> String {
        switch kind {
        case .challengeCompleted:
            challengeCompletedPrompt(context)
        case .challengeProgress:
            challengeProgressPrompt(context)
        case .streakMotivation:
            streakMotivationPrompt(context)
        case .streakAtRisk:
            streakAtRiskPrompt(context)
        case .badgeUnlocked:
            badgeUnlockedPrompt(context)
        case .leaderboardUpdate:
            leaderboardUpdatePrompt(context)
        case .challengeRecommendation:
            challengeRecommendationPrompt(context)
        }
    }

    /// System instructions for gamification message generation.
    public var systemInstructions: String {
        """
        You are a gamification coach inside a mobile app. \
        Generate short, encouraging messages (1-2 sentences max). \
        Be enthusiastic but not excessive. Use emoji sparingly (max 1). \
        Never use generic phrases like "Great job!" alone. \
        Reference the specific achievement or context provided. \
        Keep messages under 100 characters when possible.
        """
    }

    private func challengeCompletedPrompt(_ ctx: PrismGamificationContext) -> String {
        var parts = ["The user completed the challenge \"\(ctx.challengeTitle ?? ctx.entityID)\"."]
        if let points = ctx.points { parts.append("They earned \(points) points.") }
        if let total = ctx.totalPoints { parts.append("Total points: \(total).") }
        parts.append("Write a celebration message.")
        return parts.joined(separator: " ")
    }

    private func challengeProgressPrompt(_ ctx: PrismGamificationContext) -> String {
        var parts = ["The user is working on \"\(ctx.challengeTitle ?? ctx.entityID)\"."]
        if let current = ctx.currentValue, let goal = ctx.goalValue {
            let pct = goal > 0 ? Int(Double(current) / Double(goal) * 100) : 0
            parts.append("Progress: \(current)/\(goal) (\(pct)%).")
        }
        parts.append("Write an encouraging progress message.")
        return parts.joined(separator: " ")
    }

    private func streakMotivationPrompt(_ ctx: PrismGamificationContext) -> String {
        var parts = ["The user has a \(ctx.currentStreak ?? 1)-day streak."]
        if let longest = ctx.longestStreak { parts.append("Their record is \(longest) days.") }
        parts.append("Write a motivational streak message.")
        return parts.joined(separator: " ")
    }

    private func streakAtRiskPrompt(_ ctx: PrismGamificationContext) -> String {
        var parts = ["The user has a \(ctx.currentStreak ?? 1)-day streak that might break today."]
        parts.append("Write an urgent but positive reminder to keep the streak alive.")
        return parts.joined(separator: " ")
    }

    private func badgeUnlockedPrompt(_ ctx: PrismGamificationContext) -> String {
        var parts = ["The user unlocked the \"\(ctx.badgeTitle ?? ctx.entityID)\" badge."]
        if let tier = ctx.badgeTier { parts.append("Tier: \(tier).") }
        parts.append("Write a badge celebration message.")
        return parts.joined(separator: " ")
    }

    private func leaderboardUpdatePrompt(_ ctx: PrismGamificationContext) -> String {
        var parts: [String] = []
        if let rank = ctx.rank { parts.append("The user is now ranked #\(rank).") }
        if let prev = ctx.previousRank, let rank = ctx.rank {
            let diff = prev - rank
            if diff > 0 { parts.append("They moved up \(diff) position(s).") }
            else if diff < 0 { parts.append("They dropped \(abs(diff)) position(s).") }
        }
        if let score = ctx.score { parts.append("Score: \(score).") }
        parts.append("Write a leaderboard update message.")
        return parts.joined(separator: " ")
    }

    private func challengeRecommendationPrompt(_ ctx: PrismGamificationContext) -> String {
        var parts = ["Based on the user's activity:"]
        if let completed = ctx.completedChallenges {
            parts.append("Completed \(completed) challenges.")
        }
        if let total = ctx.totalPoints { parts.append("Total points: \(total).") }
        if let categories = ctx.activeCategories, !categories.isEmpty {
            parts.append("Active in: \(categories.joined(separator: ", ")).")
        }
        parts.append("Suggest what they should try next in 1-2 sentences.")
        return parts.joined(separator: " ")
    }
}
