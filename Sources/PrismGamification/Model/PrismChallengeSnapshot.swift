#if canImport(SwiftData)
    import Foundation

    /// Sendable snapshot of challenge progress, safe to pass across actor boundaries.
    public struct PrismChallengeSnapshot: Sendable {
        /// The challenge identifier.
        public let challengeID: String
        /// Current progress value.
        public let currentValue: Int
        /// Goal value.
        public let goalValue: Int
        /// Whether completed.
        public let isCompleted: Bool
        /// Challenge type raw value.
        public let typeRawValue: String
        /// When created.
        public let createdAt: Date
        /// When last updated.
        public let updatedAt: Date
        /// When completed.
        public let completedAt: Date?

        /// Completion percentage (0.0 to 1.0).
        public var progress: Double {
            guard goalValue > 0 else { return 0 }
            return min(Double(currentValue) / Double(goalValue), 1.0)
        }
    }

    extension PrismChallengeProgress {
        /// Creates a Sendable snapshot of this progress record.
        public var snapshot: PrismChallengeSnapshot {
            PrismChallengeSnapshot(
                challengeID: challengeID,
                currentValue: currentValue,
                goalValue: goalValue,
                isCompleted: isCompleted,
                typeRawValue: typeRawValue,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt
            )
        }
    }

    /// Sendable snapshot of streak record, safe to pass across actor boundaries.
    public struct PrismStreakSnapshot: Sendable {
        /// The streak identifier.
        public let streakID: String
        /// Current streak count.
        public let currentStreak: Int
        /// Longest streak ever.
        public let longestStreak: Int
        /// Last activity date.
        public let lastActivityDate: Date?
        /// Total active days.
        public let totalActiveDays: Int
        /// When tracking started.
        public let startedAt: Date
    }

    extension PrismStreakRecord {
        /// Creates a Sendable snapshot of this streak record.
        public var snapshot: PrismStreakSnapshot {
            PrismStreakSnapshot(
                streakID: streakID,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastActivityDate: lastActivityDate,
                totalActiveDays: totalActiveDays,
                startedAt: startedAt
            )
        }
    }
#endif
