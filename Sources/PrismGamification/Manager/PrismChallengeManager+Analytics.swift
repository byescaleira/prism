#if canImport(SwiftData)
    import Foundation
    import SwiftData

    extension PrismChallengeManager {
        // MARK: - Record

        /// Records a gamification analytics event.
        public func recordAnalyticsEvent(_ event: PrismGamificationAnalyticsEvent) throws {
            var duration: Double? = nil
            if case .challengeCompleted(_, _, let d) = event { duration = d }

            let record = PrismAnalyticsRecord(
                eventType: event.eventType,
                entityID: event.entityID,
                completionDuration: duration
            )
            modelContext.insert(record)
            try modelContext.save()
        }

        // MARK: - Aggregation

        /// Returns aggregated analytics for a time period.
        public func analyticsSnapshot(from start: Date, to end: Date) throws -> PrismAnalyticsSnapshot {
            let descriptor = FetchDescriptor<PrismAnalyticsRecord>(
                predicate: #Predicate { $0.timestamp >= start && $0.timestamp <= end }
            )
            let records = try modelContext.fetch(descriptor)

            let started = records.filter { $0.eventType == "challenge_started" }.count
            let completed = records.filter { $0.eventType == "challenge_completed" }
            let completedCount = completed.count
            let rate = started > 0 ? Double(completedCount) / Double(started) : 0

            let durations = completed.compactMap(\.completionDuration)
            let avgDuration: TimeInterval? = durations.isEmpty
                ? nil
                : durations.reduce(0, +) / Double(durations.count)

            let streakDays = records.filter { $0.eventType == "streak_extended" }.count
            let badges = records.filter { $0.eventType == "badge_unlocked" }.count

            return PrismAnalyticsSnapshot(
                totalChallengesStarted: started,
                totalChallengesCompleted: completedCount,
                completionRate: rate,
                averageTimeToComplete: avgDuration,
                totalStreakDays: streakDays,
                totalBadgesUnlocked: badges,
                eventCount: records.count,
                periodStart: start,
                periodEnd: end
            )
        }

        // MARK: - Query

        /// Returns analytics events for a specific entity.
        public func analyticsEvents(for entityID: String, limit: Int = 100) throws -> [PrismAnalyticsRecordSnapshot] {
            var descriptor = FetchDescriptor<PrismAnalyticsRecord>(
                predicate: #Predicate { $0.entityID == entityID },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            descriptor.fetchLimit = limit
            return try modelContext.fetch(descriptor).map(\.snapshot)
        }

        // MARK: - Cleanup

        /// Clears analytics records before a date.
        public func clearAnalytics(before date: Date) throws {
            let descriptor = FetchDescriptor<PrismAnalyticsRecord>(
                predicate: #Predicate { $0.timestamp < date }
            )
            let records = try modelContext.fetch(descriptor)
            for record in records {
                modelContext.delete(record)
            }
            try modelContext.save()
        }
    }
#endif
