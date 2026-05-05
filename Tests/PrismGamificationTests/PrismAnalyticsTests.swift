#if canImport(SwiftData)
    import Foundation
    import SwiftData
    import Testing

    @testable import PrismGamification

    // MARK: - Analytics Event Type Tests

    @Suite("AEvtTests")
    struct AEvtTests {

        @Test("challengeStarted eventType")
        func startedType() {
            let e = PrismGamificationAnalyticsEvent.challengeStarted(challengeID: "x", at: .now)
            #expect(e.eventType == "challenge_started")
        }

        @Test("challengeCompleted eventType")
        func completedType() {
            let e = PrismGamificationAnalyticsEvent.challengeCompleted(
                challengeID: "x", at: .now, duration: 120
            )
            #expect(e.eventType == "challenge_completed")
        }

        @Test("challengeProgressed eventType")
        func progressedType() {
            let e = PrismGamificationAnalyticsEvent.challengeProgressed(
                challengeID: "x", progress: 0.5
            )
            #expect(e.eventType == "challenge_progressed")
        }

        @Test("streakExtended eventType")
        func extType() {
            let e = PrismGamificationAnalyticsEvent.streakExtended(
                streakID: "d", currentStreak: 5
            )
            #expect(e.eventType == "streak_extended")
        }

        @Test("streakBroken eventType")
        func brkType() {
            let e = PrismGamificationAnalyticsEvent.streakBroken(
                streakID: "d", previousStreak: 3
            )
            #expect(e.eventType == "streak_broken")
        }

        @Test("badgeUnlocked eventType")
        func badgeType() {
            let e = PrismGamificationAnalyticsEvent.badgeUnlocked(
                badgeID: "b1", tier: "gold"
            )
            #expect(e.eventType == "badge_unlocked")
        }

        @Test("leaderboard eventType")
        func lbType() {
            let e = PrismGamificationAnalyticsEvent.leaderboardScoreSubmitted(
                userID: "u1", score: 100
            )
            #expect(e.eventType == "leaderboard_score")
        }

        @Test("entityID for challenge events")
        func entityChallenge() {
            let s = PrismGamificationAnalyticsEvent.challengeStarted(
                challengeID: "login", at: .now
            )
            #expect(s.entityID == "login")

            let c = PrismGamificationAnalyticsEvent.challengeCompleted(
                challengeID: "workout", at: .now, duration: nil
            )
            #expect(c.entityID == "workout")

            let p = PrismGamificationAnalyticsEvent.challengeProgressed(
                challengeID: "profile", progress: 0.8
            )
            #expect(p.entityID == "profile")
        }

        @Test("entityID for streak events")
        func entityStreak() {
            let ext = PrismGamificationAnalyticsEvent.streakExtended(
                streakID: "daily", currentStreak: 10
            )
            #expect(ext.entityID == "daily")

            let brk = PrismGamificationAnalyticsEvent.streakBroken(
                streakID: "weekly", previousStreak: 4
            )
            #expect(brk.entityID == "weekly")
        }

        @Test("entityID for badge")
        func entityBadge() {
            let e = PrismGamificationAnalyticsEvent.badgeUnlocked(
                badgeID: "earlyBird", tier: "silver"
            )
            #expect(e.entityID == "earlyBird")
        }

        @Test("entityID for leaderboard")
        func entityLb() {
            let e = PrismGamificationAnalyticsEvent.leaderboardScoreSubmitted(
                userID: "user42", score: 500
            )
            #expect(e.entityID == "user42")
        }
    }

    // MARK: - Analytics Snapshot Tests

    @Suite("ASnpTests")
    struct ASnpTests {

        @Test("snapshot properties")
        func props() {
            let start = Date.now
            let end = Date.now
            let snap = PrismAnalyticsSnapshot(
                totalChallengesStarted: 10,
                totalChallengesCompleted: 8,
                completionRate: 0.8,
                averageTimeToComplete: 120,
                totalStreakDays: 5,
                totalBadgesUnlocked: 3,
                eventCount: 26,
                periodStart: start,
                periodEnd: end
            )
            #expect(snap.totalChallengesStarted == 10)
            #expect(snap.totalChallengesCompleted == 8)
            #expect(snap.completionRate == 0.8)
            #expect(snap.averageTimeToComplete == 120)
            #expect(snap.totalStreakDays == 5)
            #expect(snap.totalBadgesUnlocked == 3)
            #expect(snap.eventCount == 26)
        }

        @Test("nil average time")
        func nilAvg() {
            let snap = PrismAnalyticsSnapshot(
                totalChallengesStarted: 0,
                totalChallengesCompleted: 0,
                completionRate: 0,
                averageTimeToComplete: nil,
                totalStreakDays: 0,
                totalBadgesUnlocked: 0,
                eventCount: 0,
                periodStart: .now,
                periodEnd: .now
            )
            #expect(snap.averageTimeToComplete == nil)
            #expect(snap.completionRate == 0)
        }

        @Test("record snapshot")
        func recordSnap() {
            let snap = PrismAnalyticsRecordSnapshot(
                recordID: "abc",
                eventType: "challenge_started",
                entityID: "login",
                timestamp: .now,
                metadata: "{}",
                completionDuration: 60.5
            )
            #expect(snap.recordID == "abc")
            #expect(snap.eventType == "challenge_started")
            #expect(snap.entityID == "login")
            #expect(snap.completionDuration == 60.5)
        }

        @Test("record snapshot nil duration")
        func recordNilDur() {
            let snap = PrismAnalyticsRecordSnapshot(
                recordID: "x",
                eventType: "streak_extended",
                entityID: "daily",
                timestamp: .now,
                metadata: "",
                completionDuration: nil
            )
            #expect(snap.completionDuration == nil)
        }
    }

    // MARK: - Analytics Manager Tests

    @Suite("AnaMTests")
    struct AnaMTests {

        private func makeManager() throws -> PrismChallengeManager {
            let container = try PrismChallengeContainerProvider.makeContainer(inMemory: true)
            return PrismChallengeManager(container: container)
        }

        @Test("record event")
        func record() async throws {
            let m = try makeManager()
            let event = PrismGamificationAnalyticsEvent.challengeStarted(
                challengeID: "login", at: .now
            )
            try await m.recordAnalyticsEvent(event)
            let events = try await m.analyticsEvents(for: "login")
            #expect(events.count == 1)
            #expect(events[0].eventType == "challenge_started")
            #expect(events[0].entityID == "login")
        }

        @Test("record completion with duration")
        func recordDuration() async throws {
            let m = try makeManager()
            let event = PrismGamificationAnalyticsEvent.challengeCompleted(
                challengeID: "workout", at: .now, duration: 300
            )
            try await m.recordAnalyticsEvent(event)
            let events = try await m.analyticsEvents(for: "workout")
            #expect(events[0].completionDuration == 300)
        }

        @Test("record completion nil duration")
        func recordNilDur() async throws {
            let m = try makeManager()
            let event = PrismGamificationAnalyticsEvent.challengeCompleted(
                challengeID: "login", at: .now, duration: nil
            )
            try await m.recordAnalyticsEvent(event)
            let events = try await m.analyticsEvents(for: "login")
            #expect(events[0].completionDuration == nil)
        }

        @Test("analytics snapshot aggregation")
        func snapshot() async throws {
            let m = try makeManager()
            let start = Date.distantPast
            let end = Date.distantFuture

            try await m.recordAnalyticsEvent(
                .challengeStarted(challengeID: "a", at: .now)
            )
            try await m.recordAnalyticsEvent(
                .challengeStarted(challengeID: "b", at: .now)
            )
            try await m.recordAnalyticsEvent(
                .challengeCompleted(challengeID: "a", at: .now, duration: 100)
            )
            try await m.recordAnalyticsEvent(
                .streakExtended(streakID: "d", currentStreak: 5)
            )
            try await m.recordAnalyticsEvent(
                .badgeUnlocked(badgeID: "b1", tier: "gold")
            )

            let snap = try await m.analyticsSnapshot(from: start, to: end)
            #expect(snap.totalChallengesStarted == 2)
            #expect(snap.totalChallengesCompleted == 1)
            #expect(snap.completionRate == 0.5)
            #expect(snap.averageTimeToComplete == 100)
            #expect(snap.totalStreakDays == 1)
            #expect(snap.totalBadgesUnlocked == 1)
            #expect(snap.eventCount == 5)
        }

        @Test("snapshot empty range")
        func snapshotEmpty() async throws {
            let m = try makeManager()
            try await m.recordAnalyticsEvent(
                .challengeStarted(challengeID: "a", at: .now)
            )
            let snap = try await m.analyticsSnapshot(
                from: Date.distantPast,
                to: Date.distantPast
            )
            #expect(snap.eventCount == 0)
            #expect(snap.completionRate == 0)
            #expect(snap.averageTimeToComplete == nil)
        }

        @Test("snapshot multiple completions avg")
        func snapshotAvg() async throws {
            let m = try makeManager()
            try await m.recordAnalyticsEvent(
                .challengeCompleted(challengeID: "a", at: .now, duration: 100)
            )
            try await m.recordAnalyticsEvent(
                .challengeCompleted(challengeID: "b", at: .now, duration: 200)
            )
            let snap = try await m.analyticsSnapshot(
                from: .distantPast, to: .distantFuture
            )
            #expect(snap.averageTimeToComplete == 150)
            #expect(snap.totalChallengesCompleted == 2)
        }

        @Test("events for entity")
        func eventsForEntity() async throws {
            let m = try makeManager()
            try await m.recordAnalyticsEvent(
                .challengeStarted(challengeID: "login", at: .now)
            )
            try await m.recordAnalyticsEvent(
                .challengeCompleted(challengeID: "login", at: .now, duration: 10)
            )
            try await m.recordAnalyticsEvent(
                .challengeStarted(challengeID: "other", at: .now)
            )

            let loginEvents = try await m.analyticsEvents(for: "login")
            #expect(loginEvents.count == 2)

            let otherEvents = try await m.analyticsEvents(for: "other")
            #expect(otherEvents.count == 1)
        }

        @Test("events limit")
        func eventsLimit() async throws {
            let m = try makeManager()
            for i in 0..<5 {
                try await m.recordAnalyticsEvent(
                    .challengeProgressed(challengeID: "x", progress: Double(i) * 0.2)
                )
            }
            let events = try await m.analyticsEvents(for: "x", limit: 3)
            #expect(events.count == 3)
        }

        @Test("events empty")
        func eventsEmpty() async throws {
            let m = try makeManager()
            let events = try await m.analyticsEvents(for: "nonexistent")
            #expect(events.isEmpty)
        }

        @Test("clear analytics")
        func clear() async throws {
            let m = try makeManager()
            try await m.recordAnalyticsEvent(
                .challengeStarted(challengeID: "a", at: .now)
            )
            try await m.recordAnalyticsEvent(
                .challengeStarted(challengeID: "b", at: .now)
            )

            try await m.clearAnalytics(before: .distantFuture)

            let snap = try await m.analyticsSnapshot(
                from: .distantPast, to: .distantFuture
            )
            #expect(snap.eventCount == 0)
        }

        @Test("clear preserves future events")
        func clearPartial() async throws {
            let m = try makeManager()
            try await m.recordAnalyticsEvent(
                .challengeStarted(challengeID: "a", at: .now)
            )

            try await m.clearAnalytics(before: .distantPast)

            let snap = try await m.analyticsSnapshot(
                from: .distantPast, to: .distantFuture
            )
            #expect(snap.eventCount == 1)
        }

        @Test("non-challenge event no duration")
        func nonChallengeDuration() async throws {
            let m = try makeManager()
            try await m.recordAnalyticsEvent(
                .streakExtended(streakID: "daily", currentStreak: 5)
            )
            let events = try await m.analyticsEvents(for: "daily")
            #expect(events[0].completionDuration == nil)
        }

        @Test("all event types stored correctly")
        func allTypes() async throws {
            let m = try makeManager()
            try await m.recordAnalyticsEvent(
                .challengeStarted(challengeID: "e1", at: .now)
            )
            try await m.recordAnalyticsEvent(
                .challengeCompleted(challengeID: "e2", at: .now, duration: 60)
            )
            try await m.recordAnalyticsEvent(
                .challengeProgressed(challengeID: "e3", progress: 0.5)
            )
            try await m.recordAnalyticsEvent(
                .streakExtended(streakID: "e4", currentStreak: 3)
            )
            try await m.recordAnalyticsEvent(
                .streakBroken(streakID: "e5", previousStreak: 7)
            )
            try await m.recordAnalyticsEvent(
                .badgeUnlocked(badgeID: "e6", tier: "gold")
            )
            try await m.recordAnalyticsEvent(
                .leaderboardScoreSubmitted(userID: "e7", score: 100)
            )

            let snap = try await m.analyticsSnapshot(
                from: .distantPast, to: .distantFuture
            )
            #expect(snap.eventCount == 7)
        }
    }
#endif
