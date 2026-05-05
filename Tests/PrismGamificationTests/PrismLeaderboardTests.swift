#if canImport(SwiftData)
    import Foundation
    import SwiftData
    import Testing

    @testable import PrismGamification

    // MARK: - Period Tests

    @Suite("LbPerTests")
    struct LbPerTests {

        @Test("all cases")
        func allCases() {
            #expect(PrismLeaderboardPeriod.allCases.count == 4)
        }

        @Test("raw values")
        func rawValues() {
            #expect(PrismLeaderboardPeriod.daily.rawValue == "daily")
            #expect(PrismLeaderboardPeriod.weekly.rawValue == "weekly")
            #expect(PrismLeaderboardPeriod.monthly.rawValue == "monthly")
            #expect(PrismLeaderboardPeriod.allTime.rawValue == "allTime")
        }

        @Test("codable roundtrip")
        func codable() throws {
            let data = try JSONEncoder().encode(PrismLeaderboardPeriod.weekly)
            let decoded = try JSONDecoder().decode(PrismLeaderboardPeriod.self, from: data)
            #expect(decoded == .weekly)
        }
    }

    // MARK: - Entry Tests

    @Suite("LbEntTests")
    struct LbEntTests {

        @Test("init properties")
        func initProps() {
            let e = PrismLeaderboardEntry(id: "u1", displayName: "Alice", score: 100, rank: 1)
            #expect(e.id == "u1")
            #expect(e.displayName == "Alice")
            #expect(e.score == 100)
            #expect(e.rank == 1)
        }

        @Test("comparable by rank")
        func comparable() {
            let first = PrismLeaderboardEntry(id: "a", displayName: "A", score: 50, rank: 1)
            let second = PrismLeaderboardEntry(id: "b", displayName: "B", score: 100, rank: 2)
            #expect(first < second)
        }

        @Test("equatable")
        func equatable() {
            let a = PrismLeaderboardEntry(id: "u1", displayName: "A", score: 100, rank: 1)
            let b = PrismLeaderboardEntry(id: "u1", displayName: "A", score: 100, rank: 1)
            #expect(a == b)
        }

        @Test("not equal different rank")
        func notEqual() {
            let a = PrismLeaderboardEntry(id: "u1", displayName: "A", score: 100, rank: 1)
            let b = PrismLeaderboardEntry(id: "u1", displayName: "A", score: 100, rank: 2)
            #expect(a != b)
        }

        @Test("identifiable id")
        func identifiable() {
            let e = PrismLeaderboardEntry(id: "user42", displayName: "X", score: 0, rank: 1)
            #expect(e.id == "user42")
        }

        @Test("sorting array")
        func sorting() {
            let entries = [
                PrismLeaderboardEntry(id: "c", displayName: "C", score: 10, rank: 3),
                PrismLeaderboardEntry(id: "a", displayName: "A", score: 100, rank: 1),
                PrismLeaderboardEntry(id: "b", displayName: "B", score: 50, rank: 2),
            ]
            let sorted = entries.sorted()
            #expect(sorted[0].rank == 1)
            #expect(sorted[1].rank == 2)
            #expect(sorted[2].rank == 3)
        }
    }

    // MARK: - Snapshot Tests

    @Suite("LbSnpTests")
    struct LbSnpTests {

        @Test("snapshot properties")
        func props() {
            let now = Date.now
            let entries = [
                PrismLeaderboardEntry(id: "a", displayName: "A", score: 100, rank: 1)
            ]
            let snap = PrismLeaderboardSnapshot(entries: entries, period: .weekly, generatedAt: now)
            #expect(snap.entries.count == 1)
            #expect(snap.period == .weekly)
            #expect(snap.generatedAt == now)
        }

        @Test("empty snapshot")
        func empty() {
            let snap = PrismLeaderboardSnapshot(entries: [], period: .daily, generatedAt: .now)
            #expect(snap.entries.isEmpty)
        }
    }

    // MARK: - Leaderboard Manager Tests

    @Suite("LbMgrTests")
    struct LbMgrTests {

        private func makeManager() throws -> PrismChallengeManager {
            let container = try PrismChallengeContainerProvider.makeContainer(inMemory: true)
            return PrismChallengeManager(container: container)
        }

        @Test("submit score creates entry")
        func submit() async throws {
            let m = try makeManager()
            let entry = try await m.submitScore(
                userID: "u1", displayName: "Alice", score: 100, period: .weekly
            )
            #expect(entry.id == "u1")
            #expect(entry.displayName == "Alice")
            #expect(entry.score == 100)
            #expect(entry.rank == 1)
        }

        @Test("submit updates existing")
        func submitUpdate() async throws {
            let m = try makeManager()
            try await m.submitScore(userID: "u1", displayName: "Alice", score: 100, period: .weekly)
            let updated = try await m.submitScore(
                userID: "u1", displayName: "Alice2", score: 200, period: .weekly
            )
            #expect(updated.score == 200)
            #expect(updated.displayName == "Alice2")
            let board = try await m.leaderboard(period: .weekly)
            #expect(board.entries.count == 1)
        }

        @Test("update score")
        func updateScore() async throws {
            let m = try makeManager()
            try await m.submitScore(userID: "u1", displayName: "Alice", score: 100, period: .weekly)
            let updated = try await m.updateScore(userID: "u1", score: 200, period: .weekly)
            #expect(updated.score == 200)
        }

        @Test("update not found throws")
        func updateNotFound() async throws {
            let m = try makeManager()
            do {
                try await m.updateScore(userID: "nope", score: 100, period: .weekly)
                Issue.record("Expected error")
            } catch let e as PrismGamificationError {
                if case .leaderboardEntryNotFound = e {} else { Issue.record("Wrong error: \(e)") }
            }
        }

        @Test("leaderboard ranked by score desc")
        func ranking() async throws {
            let m = try makeManager()
            try await m.submitScore(userID: "u1", displayName: "Alice", score: 50, period: .weekly)
            try await m.submitScore(userID: "u2", displayName: "Bob", score: 100, period: .weekly)
            try await m.submitScore(userID: "u3", displayName: "Carol", score: 75, period: .weekly)

            let board = try await m.leaderboard(period: .weekly)
            #expect(board.entries.count == 3)
            #expect(board.entries[0].id == "u2")
            #expect(board.entries[0].rank == 1)
            #expect(board.entries[1].id == "u3")
            #expect(board.entries[1].rank == 2)
            #expect(board.entries[2].id == "u1")
            #expect(board.entries[2].rank == 3)
        }

        @Test("leaderboard respects limit")
        func limit() async throws {
            let m = try makeManager()
            try await m.submitScore(userID: "u1", displayName: "A", score: 100, period: .daily)
            try await m.submitScore(userID: "u2", displayName: "B", score: 90, period: .daily)
            try await m.submitScore(userID: "u3", displayName: "C", score: 80, period: .daily)

            let board = try await m.leaderboard(period: .daily, limit: 2)
            #expect(board.entries.count == 2)
            #expect(board.entries[0].rank == 1)
            #expect(board.entries[1].rank == 2)
        }

        @Test("leaderboard filters by period")
        func filterPeriod() async throws {
            let m = try makeManager()
            try await m.submitScore(userID: "u1", displayName: "A", score: 100, period: .weekly)
            try await m.submitScore(userID: "u2", displayName: "B", score: 200, period: .monthly)

            let weekly = try await m.leaderboard(period: .weekly)
            #expect(weekly.entries.count == 1)
            #expect(weekly.entries[0].id == "u1")

            let monthly = try await m.leaderboard(period: .monthly)
            #expect(monthly.entries.count == 1)
            #expect(monthly.entries[0].id == "u2")
        }

        @Test("rank query")
        func rankQuery() async throws {
            let m = try makeManager()
            try await m.submitScore(userID: "u1", displayName: "A", score: 50, period: .weekly)
            try await m.submitScore(userID: "u2", displayName: "B", score: 100, period: .weekly)

            let r = try await m.rank(for: "u1", period: .weekly)
            #expect(r.rank == 2)
            #expect(r.score == 50)
        }

        @Test("rank not found throws")
        func rankNotFound() async throws {
            let m = try makeManager()
            do {
                _ = try await m.rank(for: "ghost", period: .weekly)
                Issue.record("Expected error")
            } catch let e as PrismGamificationError {
                if case .leaderboardEntryNotFound = e {} else { Issue.record("Wrong error: \(e)") }
            }
        }

        @Test("reset leaderboard")
        func reset() async throws {
            let m = try makeManager()
            try await m.submitScore(userID: "u1", displayName: "A", score: 100, period: .weekly)
            try await m.submitScore(userID: "u2", displayName: "B", score: 200, period: .weekly)
            try await m.resetLeaderboard(period: .weekly)

            let board = try await m.leaderboard(period: .weekly)
            #expect(board.entries.isEmpty)
        }

        @Test("reset only affects period")
        func resetScoped() async throws {
            let m = try makeManager()
            try await m.submitScore(userID: "u1", displayName: "A", score: 100, period: .weekly)
            try await m.submitScore(userID: "u2", displayName: "B", score: 200, period: .monthly)
            try await m.resetLeaderboard(period: .weekly)

            let weekly = try await m.leaderboard(period: .weekly)
            #expect(weekly.entries.isEmpty)

            let monthly = try await m.leaderboard(period: .monthly)
            #expect(monthly.entries.count == 1)
        }

        @Test("empty leaderboard")
        func emptyBoard() async throws {
            let m = try makeManager()
            let board = try await m.leaderboard(period: .allTime)
            #expect(board.entries.isEmpty)
            #expect(board.period == .allTime)
        }

        @Test("submit different periods same user")
        func multiPeriod() async throws {
            let m = try makeManager()
            try await m.submitScore(userID: "u1", displayName: "A", score: 100, period: .daily)
            try await m.submitScore(userID: "u1", displayName: "A", score: 200, period: .weekly)

            let daily = try await m.leaderboard(period: .daily)
            let weekly = try await m.leaderboard(period: .weekly)
            #expect(daily.entries[0].score == 100)
            #expect(weekly.entries[0].score == 200)
        }
    }
#endif
