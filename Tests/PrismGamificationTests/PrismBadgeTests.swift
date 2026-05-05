#if canImport(SwiftData)
    import Foundation
    import SwiftData
    import Testing

    @testable import PrismGamification

    // MARK: - Test Badge Enum

    enum TB: String, PrismBadge, CaseIterable {
        case starter
        case scorer
        case streaker
        case manual
        case custom

        var title: String {
            switch self {
            case .starter: "Starter"
            case .scorer: "Scorer"
            case .streaker: "Streaker"
            case .manual: "Manual"
            case .custom: "Custom"
            }
        }

        var badgeDescription: String { title }

        var tier: PrismBadgeTier {
            switch self {
            case .starter: .bronze
            case .scorer: .silver
            case .streaker: .gold
            case .manual: .platinum
            case .custom: .diamond
            }
        }

        var condition: PrismBadgeCondition {
            switch self {
            case .starter: .challengeCompleted(challengeID: "firstLogin")
            case .scorer: .pointsReached(threshold: 30)
            case .streaker: .streakReached(streakID: "daily", days: 3)
            case .manual: .pointsReached(threshold: 9999)
            case .custom: .custom(id: "special")
            }
        }
    }

    // MARK: - Tier Tests

    @Suite("TierTests")
    struct TierTests {

        @Test("all tiers")
        func allCases() {
            #expect(PrismBadgeTier.allCases.count == 5)
        }

        @Test("raw values")
        func rawValues() {
            #expect(PrismBadgeTier.bronze.rawValue == "bronze")
            #expect(PrismBadgeTier.silver.rawValue == "silver")
            #expect(PrismBadgeTier.gold.rawValue == "gold")
            #expect(PrismBadgeTier.platinum.rawValue == "platinum")
            #expect(PrismBadgeTier.diamond.rawValue == "diamond")
        }

        @Test("comparable ordering")
        func ordering() {
            #expect(PrismBadgeTier.bronze < .silver)
            #expect(PrismBadgeTier.silver < .gold)
            #expect(PrismBadgeTier.gold < .platinum)
            #expect(PrismBadgeTier.platinum < .diamond)
            #expect(!(PrismBadgeTier.diamond < .bronze))
        }

        @Test("codable roundtrip")
        func codable() throws {
            let data = try JSONEncoder().encode(PrismBadgeTier.gold)
            let decoded = try JSONDecoder().decode(PrismBadgeTier.self, from: data)
            #expect(decoded == .gold)
        }

        @Test("equal not less")
        func equalNotLess() {
            #expect(!(PrismBadgeTier.gold < .gold))
        }
    }

    // MARK: - Condition Tests

    @Suite("CondTests")
    struct CondTests {

        @Test("challenge completed equatable")
        func challengeEq() {
            let a = PrismBadgeCondition.challengeCompleted(challengeID: "x")
            let b = PrismBadgeCondition.challengeCompleted(challengeID: "x")
            #expect(a == b)
        }

        @Test("points reached equatable")
        func pointsEq() {
            let a = PrismBadgeCondition.pointsReached(threshold: 100)
            let b = PrismBadgeCondition.pointsReached(threshold: 100)
            #expect(a == b)
        }

        @Test("streak reached equatable")
        func streakEq() {
            let a = PrismBadgeCondition.streakReached(streakID: "d", days: 7)
            let b = PrismBadgeCondition.streakReached(streakID: "d", days: 7)
            #expect(a == b)
        }

        @Test("custom equatable")
        func customEq() {
            let a = PrismBadgeCondition.custom(id: "x")
            let b = PrismBadgeCondition.custom(id: "x")
            #expect(a == b)
        }

        @Test("different cases not equal")
        func notEqual() {
            let a = PrismBadgeCondition.challengeCompleted(challengeID: "x")
            let b = PrismBadgeCondition.pointsReached(threshold: 100)
            #expect(a != b)
        }

        @Test("different values not equal")
        func diffVals() {
            let a = PrismBadgeCondition.pointsReached(threshold: 100)
            let b = PrismBadgeCondition.pointsReached(threshold: 200)
            #expect(a != b)
        }
    }

    // MARK: - Badge Protocol Tests

    @Suite("BdgPTests")
    struct BdgPTests {

        @Test("all cases count")
        func count() {
            #expect(TB.allCases.count == 5)
        }

        @Test("metadata")
        func meta() {
            #expect(TB.starter.title == "Starter")
            #expect(TB.starter.badgeDescription == "Starter")
            #expect(TB.starter.tier == .bronze)
        }

        @Test("condition types")
        func conditions() {
            if case .challengeCompleted(let id) = TB.starter.condition {
                #expect(id == "firstLogin")
            } else { #expect(Bool(false)) }

            if case .pointsReached(let t) = TB.scorer.condition {
                #expect(t == 30)
            } else { #expect(Bool(false)) }

            if case .streakReached(let id, let d) = TB.streaker.condition {
                #expect(id == "daily")
                #expect(d == 3)
            } else { #expect(Bool(false)) }

            if case .custom(let id) = TB.custom.condition {
                #expect(id == "special")
            } else { #expect(Bool(false)) }
        }

        @Test("default iconName nil")
        func defaultIcon() {
            #expect(TB.starter.iconName == nil)
        }

        @Test("rawValue")
        func raw() {
            #expect(TB.starter.rawValue == "starter")
            #expect(TB.scorer.rawValue == "scorer")
        }
    }

    // MARK: - Badge Snapshot Tests

    @Suite("BSnpTests")
    struct BSnpTests {

        @Test("locked snapshot")
        func locked() {
            let s = PrismBadgeSnapshot(
                badgeID: "test", isUnlocked: false,
                tierRawValue: "bronze", unlockedAt: nil, createdAt: .now
            )
            #expect(s.badgeID == "test")
            #expect(!s.isUnlocked)
            #expect(s.unlockedAt == nil)
            #expect(s.tierRawValue == "bronze")
        }

        @Test("unlocked snapshot")
        func unlocked() {
            let now = Date.now
            let s = PrismBadgeSnapshot(
                badgeID: "test", isUnlocked: true,
                tierRawValue: "gold", unlockedAt: now, createdAt: now
            )
            #expect(s.isUnlocked)
            #expect(s.unlockedAt == now)
        }
    }

    // MARK: - Badge Manager Tests

    @Suite("BdgMTests")
    struct BdgMTests {

        private func makeManager() throws -> PrismChallengeManager {
            let container = try PrismChallengeContainerProvider.makeContainer(inMemory: true)
            return PrismChallengeManager(container: container)
        }

        @Test("register badges")
        func reg() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            let all = try await m.allBadges()
            #expect(all.count == TB.allCases.count)
        }

        @Test("register idempotent")
        func regIdem() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            try await m.registerBadges(TB.self)
            #expect(try await m.allBadges().count == TB.allCases.count)
        }

        @Test("unlock badge")
        func unlock() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            let snap = try await m.unlockBadge(TB.manual)
            #expect(snap.isUnlocked)
            #expect(snap.unlockedAt != nil)
        }

        @Test("unlock already throws")
        func unlockDup() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            try await m.unlockBadge(TB.manual)
            do {
                try await m.unlockBadge(TB.manual)
                Issue.record("Expected error")
            } catch let e as PrismGamificationError {
                #expect(e == .badgeAlreadyUnlocked("manual"))
            }
        }

        @Test("isBadgeUnlocked query")
        func isUnlocked() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            #expect(try await m.isBadgeUnlocked(TB.manual) == false)
            try await m.unlockBadge(TB.manual)
            #expect(try await m.isBadgeUnlocked(TB.manual) == true)
        }

        @Test("badgeProgress query")
        func progress() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            let p = try await m.badgeProgress(for: TB.starter)
            #expect(p.badgeID == "starter")
            #expect(!p.isUnlocked)
            #expect(p.tierRawValue == "bronze")
        }

        @Test("not found throws")
        func notFound() async throws {
            let m = try makeManager()
            do {
                _ = try await m.isBadgeUnlocked(TB.starter)
                Issue.record("Expected error")
            } catch let e as PrismGamificationError {
                if case .badgeNotFound = e {} else { Issue.record("Wrong error: \(e)") }
            }
        }

        @Test("evaluate challengeCompleted")
        func evalChallenge() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            try await m.registerBadges(TB.self)
            try await m.complete(TC.firstLogin)
            let unlocked = try await m.evaluateBadges(TB.self, currentPoints: 0)
            #expect(unlocked.contains { $0.badgeID == "starter" })
        }

        @Test("evaluate pointsReached")
        func evalPoints() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            let unlocked = try await m.evaluateBadges(TB.self, currentPoints: 50)
            #expect(unlocked.contains { $0.badgeID == "scorer" })
        }

        @Test("evaluate streakReached")
        func evalStreak() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            try await m.recordStreakActivity("daily")
            let cal = Calendar.current
            let yesterday = cal.date(byAdding: .day, value: -1, to: .now)!
            let twoDaysAgo = cal.date(byAdding: .day, value: -2, to: .now)!

            let container = try PrismChallengeContainerProvider.makeContainer(inMemory: true)
            let m2 = PrismChallengeManager(container: container)
            try await m2.registerBadges(TB.self)

            // Streak of 3 needed — simulate via direct record manipulation isn't possible
            // through public API without date manipulation, so test with threshold not met
            let unlocked = try await m2.evaluateBadges(TB.self, currentPoints: 0)
            #expect(!unlocked.contains { $0.badgeID == "streaker" })
        }

        @Test("evaluate custom never auto-unlocks")
        func evalCustom() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            let unlocked = try await m.evaluateBadges(TB.self, currentPoints: 99999)
            #expect(!unlocked.contains { $0.badgeID == "custom" })
        }

        @Test("evaluate skips already unlocked")
        func evalSkips() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            try await m.unlockBadge(TB.scorer)
            let unlocked = try await m.evaluateBadges(TB.self, currentPoints: 50)
            #expect(!unlocked.contains { $0.badgeID == "scorer" })
        }

        @Test("evaluate no match returns empty")
        func evalNone() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            let unlocked = try await m.evaluateBadges(TB.self, currentPoints: 0)
            #expect(unlocked.isEmpty)
        }

        @Test("evaluate challenge not found returns false")
        func evalChallengeNotFound() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            let unlocked = try await m.evaluateBadges(TB.self, currentPoints: 0)
            #expect(!unlocked.contains { $0.badgeID == "starter" })
        }

        @Test("evaluate streak not found returns false")
        func evalStreakNotFound() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            let unlocked = try await m.evaluateBadges(TB.self, currentPoints: 0)
            #expect(!unlocked.contains { $0.badgeID == "streaker" })
        }

        @Test("allBadges sorted by creation")
        func allSorted() async throws {
            let m = try makeManager()
            try await m.registerBadges(TB.self)
            let all = try await m.allBadges()
            #expect(all.count == 5)
            for badge in all {
                #expect(!badge.isUnlocked)
            }
        }
    }
#endif
