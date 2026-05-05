#if canImport(SwiftData)
    import Foundation
    import SwiftData
    import Testing

    @testable import PrismGamification

    // MARK: - Test Challenge Enum

    enum TC: String, PrismChallenge, CaseIterable {
        case firstLogin
        case tenWorkouts
        case completeProfile

        var title: String {
            switch self {
            case .firstLogin: "First Login"
            case .tenWorkouts: "Ten Workouts"
            case .completeProfile: "Complete Profile"
            }
        }

        var challengeDescription: String { title }

        var type: PrismChallengeType {
            switch self {
            case .firstLogin, .completeProfile: .milestone
            case .tenWorkouts: .counter
            }
        }

        var goal: Int {
            switch self {
            case .firstLogin, .completeProfile: 1
            case .tenWorkouts: 10
            }
        }

        var points: Int {
            switch self {
            case .firstLogin: 10
            case .tenWorkouts: 50
            case .completeProfile: 20
            }
        }

        var category: String? {
            switch self {
            case .firstLogin, .completeProfile: "onboarding"
            case .tenWorkouts: "fitness"
            }
        }

        var iconName: String? {
            switch self {
            case .firstLogin: "person.crop.circle.badge.checkmark"
            case .tenWorkouts: "figure.run"
            case .completeProfile: "person.text.rectangle"
            }
        }
    }

    // MARK: - Helper

    private func makeManager() throws -> PrismChallengeManager {
        let container = try PrismChallengeContainerProvider.makeContainer(inMemory: true)
        return PrismChallengeManager(container: container)
    }

    // MARK: - Types

    @Suite("TypeTests")
    struct TypeTests {

        @Test("counter raw value")
        func counterRaw() {
            #expect(PrismChallengeType.counter.rawValue == "counter")
        }

        @Test("milestone raw value")
        func milestoneRaw() {
            #expect(PrismChallengeType.milestone.rawValue == "milestone")
        }

        @Test("CaseIterable has 2 cases")
        func allCases() {
            #expect(PrismChallengeType.allCases.count == 2)
        }

        @Test("Codable roundtrip")
        func codable() throws {
            let data = try JSONEncoder().encode(PrismChallengeType.counter)
            let decoded = try JSONDecoder().decode(PrismChallengeType.self, from: data)
            #expect(decoded == .counter)
        }
    }

    // MARK: - Protocol

    @Suite("ProtoTests")
    struct ProtoTests {

        @Test("has 3 cases")
        func allCases() {
            #expect(TC.allCases.count == 3)
        }

        @Test("milestone goal is 1")
        func milestoneGoal() {
            #expect(TC.firstLogin.goal == 1)
            #expect(TC.firstLogin.type == .milestone)
        }

        @Test("counter goal > 1")
        func counterGoal() {
            #expect(TC.tenWorkouts.goal == 10)
            #expect(TC.tenWorkouts.type == .counter)
        }

        @Test("metadata")
        func metadata() {
            #expect(TC.firstLogin.title == "First Login")
        }

        @Test("optional props")
        func optionalProps() {
            #expect(TC.firstLogin.category == "onboarding")
            #expect(TC.firstLogin.iconName != nil)
            #expect(TC.firstLogin.points == 10)
        }

        @Test("rawValue")
        func rawValue() {
            #expect(TC.firstLogin.rawValue == "firstLogin")
        }
    }

    // MARK: - Errors

    @Suite("ErrTests")
    struct ErrTests {

        @Test("equatable")
        func equatable() {
            #expect(PrismGamificationError.challengeNotFound("x") == .challengeNotFound("x"))
        }

        @Test("not equal")
        func notEqual() {
            #expect(PrismGamificationError.challengeNotFound("x") != .streakNotFound("x"))
        }

        @Test("description")
        func desc() {
            #expect(PrismGamificationError.challengeNotFound("login").localizedDescription.contains("login"))
        }

        @Test("all have descriptions")
        func allDesc() {
            let errors: [PrismGamificationError] = [
                .challengeNotFound("a"), .challengeAlreadyCompleted("b"),
                .persistenceFailed("c"), .invalidOperation("d"), .streakNotFound("e"),
            ]
            for e in errors { #expect(!e.localizedDescription.isEmpty) }
        }
    }

    // MARK: - Events

    @Suite("EvtTests")
    struct EvtTests {

        @Test("completed")
        func completed() {
            if case .completed(let id, let pts) = PrismChallengeEvent.completed(
                challengeID: "t", points: 10)
            {
                #expect(id == "t")
                #expect(pts == 10)
            } else { #expect(Bool(false)) }
        }

        @Test("progressed")
        func progressed() {
            if case .progressed(let id, let c, let g) = PrismChallengeEvent.progressed(
                challengeID: "x", currentValue: 3, goalValue: 10)
            {
                #expect(id == "x")
                #expect(c == 3)
                #expect(g == 10)
            } else { #expect(Bool(false)) }
        }

        @Test("streakExtended")
        func ext() {
            if case .streakExtended(let id, let s) = PrismChallengeEvent.streakExtended(
                streakID: "d", currentStreak: 5)
            {
                #expect(id == "d")
                #expect(s == 5)
            } else { #expect(Bool(false)) }
        }

        @Test("streakBroken")
        func brk() {
            if case .streakBroken(let id, let p) = PrismChallengeEvent.streakBroken(
                streakID: "d", previousStreak: 7)
            {
                #expect(id == "d")
                #expect(p == 7)
            } else { #expect(Bool(false)) }
        }

        @Test("newRecord")
        func rec() {
            if case .newStreakRecord(let id, let l) = PrismChallengeEvent.newStreakRecord(
                streakID: "d", longestStreak: 30)
            {
                #expect(id == "d")
                #expect(l == 30)
            } else { #expect(Bool(false)) }
        }
    }

    // MARK: - Snapshot

    @Suite("SnapTests")
    struct SnapTests {

        @Test("progress percentage")
        func pct() {
            let s = PrismChallengeSnapshot(
                challengeID: "t", currentValue: 5, goalValue: 10,
                isCompleted: false, typeRawValue: "counter",
                createdAt: .now, updatedAt: .now, completedAt: nil
            )
            #expect(s.progress == 0.5)
        }

        @Test("clamps to 1.0")
        func clamp() {
            let s = PrismChallengeSnapshot(
                challengeID: "t", currentValue: 15, goalValue: 10,
                isCompleted: true, typeRawValue: "counter",
                createdAt: .now, updatedAt: .now, completedAt: .now
            )
            #expect(s.progress == 1.0)
        }

        @Test("zero goal returns 0")
        func zero() {
            let s = PrismChallengeSnapshot(
                challengeID: "t", currentValue: 0, goalValue: 0,
                isCompleted: false, typeRawValue: "counter",
                createdAt: .now, updatedAt: .now, completedAt: nil
            )
            #expect(s.progress == 0)
        }
    }

    // MARK: - Manager

    @Suite("MgrTests")
    struct MgrTests {

        @Test("register creates records")
        func reg() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            let all = try await m.allProgress()
            #expect(all.count == TC.allCases.count)
        }

        @Test("register idempotent")
        func regIdem() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            try await m.register(TC.self)
            #expect(try await m.allProgress().count == TC.allCases.count)
        }

        @Test("increment by 1")
        func inc1() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            let r = try await m.increment(TC.tenWorkouts)
            #expect(r.currentValue == 1)
            #expect(r.isCompleted == false)
        }

        @Test("increment by amount")
        func incN() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            let r = try await m.increment(TC.tenWorkouts, by: 5)
            #expect(r.currentValue == 5)
        }

        @Test("increment completes at goal")
        func incDone() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            let r = try await m.increment(TC.tenWorkouts, by: 10)
            #expect(r.isCompleted == true)
            #expect(r.completedAt != nil)
        }

        @Test("increment clamps")
        func incClamp() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            let r = try await m.increment(TC.tenWorkouts, by: 15)
            #expect(r.currentValue == 10)
        }

        @Test("increment done throws")
        func incThrows() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            try await m.increment(TC.tenWorkouts, by: 10)
            do {
                try await m.increment(TC.tenWorkouts)
                Issue.record("Expected error")
            } catch let e as PrismGamificationError {
                #expect(e == .challengeAlreadyCompleted("tenWorkouts"))
            }
        }

        @Test("increment milestone throws")
        func incMile() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            do {
                try await m.increment(TC.firstLogin)
                Issue.record("Expected error")
            } catch let e as PrismGamificationError {
                if case .invalidOperation = e {} else { Issue.record("Wrong error") }
            }
        }

        @Test("complete milestone")
        func comp() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            let r = try await m.complete(TC.firstLogin)
            #expect(r.isCompleted == true)
            #expect(r.currentValue == 1)
        }

        @Test("complete again throws")
        func compThrows() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            try await m.complete(TC.firstLogin)
            do {
                try await m.complete(TC.firstLogin)
                Issue.record("Expected error")
            } catch let e as PrismGamificationError {
                #expect(e == .challengeAlreadyCompleted("firstLogin"))
            }
        }

        @Test("isCompleted query")
        func isDone() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            #expect(try await m.isCompleted(TC.firstLogin) == false)
            try await m.complete(TC.firstLogin)
            #expect(try await m.isCompleted(TC.firstLogin) == true)
        }

        @Test("progress query")
        func prog() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            try await m.increment(TC.tenWorkouts, by: 3)
            let p = try await m.progress(for: TC.tenWorkouts)
            #expect(p.currentValue == 3)
            #expect(p.goalValue == 10)
        }

        @Test("reset clears")
        func rst() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            try await m.complete(TC.firstLogin)
            try await m.reset(TC.firstLogin)
            let p = try await m.progress(for: TC.firstLogin)
            #expect(p.currentValue == 0)
            #expect(p.isCompleted == false)
        }

        @Test("resetAll clears all")
        func rstAll() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            try await m.complete(TC.firstLogin)
            try await m.complete(TC.completeProfile)
            try await m.increment(TC.tenWorkouts, by: 5)
            try await m.resetAll(TC.self)
            for p in try await m.allProgress() {
                #expect(p.currentValue == 0)
                #expect(p.isCompleted == false)
            }
        }

        @Test("totalPoints")
        func pts() async throws {
            let m = try makeManager()
            try await m.register(TC.self)
            try await m.complete(TC.firstLogin)
            try await m.complete(TC.completeProfile)
            #expect(try await m.totalPoints(TC.self) == 30)
        }

        @Test("not found throws")
        func notFound() async throws {
            let m = try makeManager()
            do {
                _ = try await m.progress(for: TC.firstLogin)
                Issue.record("Expected error")
            } catch let e as PrismGamificationError {
                if case .challengeNotFound = e {} else { Issue.record("Wrong error") }
            }
        }
    }

    // MARK: - Streaks

    @Suite("StrkTests")
    struct StrkTests {

        @Test("first activity")
        func first() async throws {
            let m = try makeManager()
            try await m.recordStreakActivity("daily")
            #expect(try await m.currentStreak("daily") == 1)
        }

        @Test("same day no-op")
        func sameDay() async throws {
            let m = try makeManager()
            try await m.recordStreakActivity("daily")
            try await m.recordStreakActivity("daily")
            let r = try await m.streakRecord("daily")
            #expect(r.currentStreak == 1)
            #expect(r.totalActiveDays == 1)
        }

        @Test("not found throws")
        func notFound() async throws {
            let m = try makeManager()
            do {
                _ = try await m.currentStreak("nope")
                Issue.record("Expected error")
            } catch let e as PrismGamificationError {
                if case .streakNotFound = e {} else { Issue.record("Wrong error") }
            }
        }

        @Test("longest tracked")
        func longest() async throws {
            let m = try makeManager()
            try await m.recordStreakActivity("daily")
            #expect(try await m.longestStreak("daily") == 1)
        }

        @Test("reset preserves longest")
        func rst() async throws {
            let m = try makeManager()
            try await m.recordStreakActivity("daily")
            try await m.resetStreak("daily")
            let r = try await m.streakRecord("daily")
            #expect(r.currentStreak == 0)
            #expect(r.longestStreak == 1)
            #expect(r.lastActivityDate == nil)
        }
    }
#endif
