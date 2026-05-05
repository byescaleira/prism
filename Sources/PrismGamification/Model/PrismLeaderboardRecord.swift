#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Persisted leaderboard entry for a user within a specific period.
    @Model
    public final class PrismLeaderboardRecord {
        /// Composite unique key: "\(userID)_\(periodRawValue)".
        @Attribute(.unique)
        public var entryID: String

        /// The user identifier.
        public var userID: String

        /// The user's display name.
        public var displayName: String

        /// The user's score for the period.
        public var score: Int

        /// Raw value of the ``PrismLeaderboardPeriod``.
        public var periodRawValue: String

        /// When the record was last updated.
        public var updatedAt: Date

        /// When the record was first created.
        public var createdAt: Date

        /// Creates a new `PrismLeaderboardRecord` with the specified configuration.
        public init(
            entryID: String,
            userID: String,
            displayName: String,
            score: Int,
            periodRawValue: String,
            updatedAt: Date = .now,
            createdAt: Date = .now
        ) {
            self.entryID = entryID
            self.userID = userID
            self.displayName = displayName
            self.score = score
            self.periodRawValue = periodRawValue
            self.updatedAt = updatedAt
            self.createdAt = createdAt
        }
    }
#endif
