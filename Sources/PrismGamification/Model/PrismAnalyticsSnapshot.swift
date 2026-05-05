#if canImport(SwiftData)
    import Foundation

    /// Aggregated gamification analytics for a time period.
    public struct PrismAnalyticsSnapshot: Sendable {
        /// Total challenges started in the period.
        public let totalChallengesStarted: Int
        /// Total challenges completed in the period.
        public let totalChallengesCompleted: Int
        /// Completion rate (0.0 to 1.0).
        public let completionRate: Double
        /// Average time to complete a challenge.
        public let averageTimeToComplete: TimeInterval?
        /// Total streak-extended events in the period.
        public let totalStreakDays: Int
        /// Total badges unlocked in the period.
        public let totalBadgesUnlocked: Int
        /// Total number of events in the period.
        public let eventCount: Int
        /// Start of the analytics period.
        public let periodStart: Date
        /// End of the analytics period.
        public let periodEnd: Date
    }

    /// Sendable snapshot of an analytics record, safe to pass across actor boundaries.
    public struct PrismAnalyticsRecordSnapshot: Sendable {
        /// The record identifier.
        public let recordID: String
        /// Event type name.
        public let eventType: String
        /// Related entity identifier.
        public let entityID: String
        /// When the event occurred.
        public let timestamp: Date
        /// JSON-encoded extra data.
        public let metadata: String
        /// Duration for completion events.
        public let completionDuration: Double?
    }

    extension PrismAnalyticsRecord {
        /// Creates a Sendable snapshot of this analytics record.
        public var snapshot: PrismAnalyticsRecordSnapshot {
            PrismAnalyticsRecordSnapshot(
                recordID: recordID,
                eventType: eventType,
                entityID: entityID,
                timestamp: timestamp,
                metadata: metadata,
                completionDuration: completionDuration
            )
        }
    }
#endif
