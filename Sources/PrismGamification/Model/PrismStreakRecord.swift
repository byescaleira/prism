#if canImport(SwiftData)
    import Foundation
    import SwiftData

    /// Tracks daily engagement streaks, Duolingo-style.
    @Model
    public final class PrismStreakRecord {
        /// Identifier for the streak category.
        @Attribute(.unique)
        public var streakID: String

        /// Current consecutive-day streak count.
        public var currentStreak: Int

        /// Longest streak ever achieved.
        public var longestStreak: Int

        /// Calendar date of last qualifying activity.
        public var lastActivityDate: Date?

        /// Total number of days with qualifying activity.
        public var totalActiveDays: Int

        /// When streak tracking began.
        public var startedAt: Date

        /// Creates a new `PrismStreakRecord` with the specified configuration.
        public init(
            streakID: String,
            currentStreak: Int = 0,
            longestStreak: Int = 0,
            lastActivityDate: Date? = nil,
            totalActiveDays: Int = 0,
            startedAt: Date = .now
        ) {
            self.streakID = streakID
            self.currentStreak = currentStreak
            self.longestStreak = longestStreak
            self.lastActivityDate = lastActivityDate
            self.totalActiveDays = totalActiveDays
            self.startedAt = startedAt
        }
    }
#endif
