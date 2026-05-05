import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - Game Center Tests

@Suite("PrismGameCenter")
struct PrismGameCenterTests {

    @Test("PrismGameCenterPlayer stores properties correctly")
    func playerProperties() {
        let player = PrismGameCenterPlayer(
            id: "player_001",
            displayName: "John Doe",
            alias: "johnd",
            isAuthenticated: true
        )
        #expect(player.id == "player_001")
        #expect(player.displayName == "John Doe")
        #expect(player.alias == "johnd")
        #expect(player.isAuthenticated == true)
    }

    @Test("PrismGameCenterPlayer unauthenticated state")
    func playerUnauthenticated() {
        let player = PrismGameCenterPlayer(
            id: "player_002",
            displayName: "Guest",
            alias: "guest",
            isAuthenticated: false
        )
        #expect(player.isAuthenticated == false)
    }

    @Test("PrismLeaderboardScore stores properties correctly")
    func leaderboardScoreProperties() {
        let date = Date()
        let score = PrismLeaderboardScore(
            playerID: "player_001",
            displayName: "John Doe",
            value: 15000,
            rank: 1,
            formattedValue: "15,000",
            date: date
        )
        #expect(score.playerID == "player_001")
        #expect(score.displayName == "John Doe")
        #expect(score.value == 15000)
        #expect(score.rank == 1)
        #expect(score.formattedValue == "15,000")
        #expect(score.date == date)
    }

    @Test("PrismLeaderboardScore defaults formattedValue to nil")
    func leaderboardScoreDefaults() {
        let score = PrismLeaderboardScore(
            playerID: "p1",
            displayName: "Test",
            value: 100,
            rank: 5,
            date: Date()
        )
        #expect(score.formattedValue == nil)
    }

    @Test("PrismLeaderboardScope has 2 cases")
    func leaderboardScopeCases() {
        let scopes: [PrismLeaderboardScope] = [.global, .friends]
        #expect(scopes.count == 2)
    }

    @Test("PrismLeaderboardScope global and friends are distinct")
    func leaderboardScopeDistinct() {
        let global = PrismLeaderboardScope.global
        let friends = PrismLeaderboardScope.friends
        if case .global = global {} else { #expect(Bool(false), "Expected global") }
        if case .friends = friends {} else { #expect(Bool(false), "Expected friends") }
    }

    @Test("PrismLeaderboardTimeScope has 3 cases")
    func leaderboardTimeScopeCaseCount() {
        #expect(PrismLeaderboardTimeScope.allCases.count == 3)
    }

    @Test("PrismLeaderboardTimeScope includes all expected cases")
    func leaderboardTimeScopeCases() {
        let cases = PrismLeaderboardTimeScope.allCases
        #expect(cases.contains(.today))
        #expect(cases.contains(.week))
        #expect(cases.contains(.allTime))
    }

    @Test("PrismAchievement stores properties correctly")
    func achievementProperties() {
        let achievement = PrismAchievement(
            id: "achievement_first_win",
            title: "First Victory",
            percentComplete: 100.0,
            isCompleted: true,
            showsCompletionBanner: true
        )
        #expect(achievement.id == "achievement_first_win")
        #expect(achievement.title == "First Victory")
        #expect(achievement.percentComplete == 100.0)
        #expect(achievement.isCompleted == true)
        #expect(achievement.showsCompletionBanner == true)
    }

    @Test("PrismAchievement partial progress")
    func achievementPartialProgress() {
        let achievement = PrismAchievement(
            id: "achievement_collector",
            title: "Collector",
            percentComplete: 45.5,
            isCompleted: false,
            showsCompletionBanner: false
        )
        #expect(achievement.percentComplete == 45.5)
        #expect(achievement.isCompleted == false)
        #expect(achievement.showsCompletionBanner == false)
    }

    @Test("PrismMatchRequest stores properties correctly")
    func matchRequestProperties() {
        let request = PrismMatchRequest(
            minPlayers: 2,
            maxPlayers: 4,
            playerGroup: 42,
            defaultNumberOfPlayers: 2
        )
        #expect(request.minPlayers == 2)
        #expect(request.maxPlayers == 4)
        #expect(request.playerGroup == 42)
        #expect(request.defaultNumberOfPlayers == 2)
    }

    @Test("PrismMatchRequest defaults playerGroup to nil")
    func matchRequestDefaults() {
        let request = PrismMatchRequest(
            minPlayers: 2,
            maxPlayers: 8,
            defaultNumberOfPlayers: 4
        )
        #expect(request.playerGroup == nil)
    }

    @Test("PrismMatchStatus has 4 cases")
    func matchStatusCaseCount() {
        #expect(PrismMatchStatus.allCases.count == 4)
    }

    @Test("PrismMatchStatus includes all expected cases")
    func matchStatusCases() {
        let cases = PrismMatchStatus.allCases
        #expect(cases.contains(.unknown))
        #expect(cases.contains(.open))
        #expect(cases.contains(.ended))
        #expect(cases.contains(.matching))
    }
}
