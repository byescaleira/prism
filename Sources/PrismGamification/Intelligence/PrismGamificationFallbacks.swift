import Foundation

/// Static fallback messages when AI generation is unavailable.
public enum PrismGamificationFallbacks: Sendable {

    /// Returns a static fallback message for the given kind and context.
    public static func message(
        for kind: PrismGamificationMessageKind,
        context: PrismGamificationContext
    ) -> String {
        switch kind {
        case .challengeCompleted:
            challengeCompleted(context)
        case .challengeProgress:
            challengeProgress(context)
        case .streakMotivation:
            streakMotivation(context)
        case .streakAtRisk:
            streakAtRisk(context)
        case .badgeUnlocked:
            badgeUnlocked(context)
        case .leaderboardUpdate:
            leaderboardUpdate(context)
        case .challengeRecommendation:
            "Keep going — new challenges await!"
        }
    }

    private static func challengeCompleted(_ ctx: PrismGamificationContext) -> String {
        let title = ctx.challengeTitle ?? ctx.entityID
        if let points = ctx.points {
            return "Challenge \"\(title)\" completed! +\(points) points"
        }
        return "Challenge \"\(title)\" completed!"
    }

    private static func challengeProgress(_ ctx: PrismGamificationContext) -> String {
        let title = ctx.challengeTitle ?? ctx.entityID
        if let current = ctx.currentValue, let goal = ctx.goalValue {
            return "\(current)/\(goal) on \"\(title)\" — keep it up!"
        }
        return "Making progress on \"\(title)\"!"
    }

    private static func streakMotivation(_ ctx: PrismGamificationContext) -> String {
        let days = ctx.currentStreak ?? 1
        return "\(days)-day streak — don't stop now!"
    }

    private static func streakAtRisk(_ ctx: PrismGamificationContext) -> String {
        let days = ctx.currentStreak ?? 1
        return "Your \(days)-day streak is at risk! Log activity today."
    }

    private static func badgeUnlocked(_ ctx: PrismGamificationContext) -> String {
        let title = ctx.badgeTitle ?? ctx.entityID
        if let tier = ctx.badgeTier {
            return "\(tier.capitalized) badge \"\(title)\" unlocked!"
        }
        return "Badge \"\(title)\" unlocked!"
    }

    private static func leaderboardUpdate(_ ctx: PrismGamificationContext) -> String {
        if let rank = ctx.rank {
            return "You're now ranked #\(rank)!"
        }
        return "Your leaderboard position updated!"
    }
}
