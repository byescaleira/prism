#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Persisted progress for a single challenge, synced to CloudKit.
    @Model
    public final class PrismChallengeProgress {
        /// Stable identifier matching the PrismChallenge enum rawValue.
        @Attribute(.unique)
        public var challengeID: String

        /// Current progress value.
        public var currentValue: Int

        /// Goal value at time of registration.
        public var goalValue: Int

        /// Whether the challenge has been completed.
        public var isCompleted: Bool

        /// Challenge type raw value.
        public var typeRawValue: String

        /// When progress was first created.
        public var createdAt: Date

        /// When progress was last updated.
        public var updatedAt: Date

        /// When the challenge was completed.
        public var completedAt: Date?

        /// Completion percentage (0.0 to 1.0).
        @Transient
        public var progress: Double {
            guard goalValue > 0 else { return 0 }
            return min(Double(currentValue) / Double(goalValue), 1.0)
        }

        /// Creates a new `PrismChallengeProgress` with the specified configuration.
        public init(
            challengeID: String,
            currentValue: Int = 0,
            goalValue: Int,
            isCompleted: Bool = false,
            typeRawValue: String,
            createdAt: Date = .now,
            updatedAt: Date = .now,
            completedAt: Date? = nil
        ) {
            self.challengeID = challengeID
            self.currentValue = currentValue
            self.goalValue = goalValue
            self.isCompleted = isCompleted
            self.typeRawValue = typeRawValue
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.completedAt = completedAt
        }
    }
#endif
