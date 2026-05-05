#if canImport(GameKit)
import GameKit

// MARK: - Player

/// Represents the local Game Center player with identity and authentication state.
public struct PrismGameCenterPlayer: Sendable {
    /// The unique player identifier assigned by Game Center.
    public let id: String
    /// The player's display name visible to other players.
    public let displayName: String
    /// The player's alias (gamertag).
    public let alias: String
    /// Whether the player is currently authenticated with Game Center.
    public let isAuthenticated: Bool

    /// Creates a new Game Center player descriptor with the given identity.
    public init(id: String, displayName: String, alias: String, isAuthenticated: Bool) {
        self.id = id
        self.displayName = displayName
        self.alias = alias
        self.isAuthenticated = isAuthenticated
    }
}

// MARK: - Leaderboard Score

/// A single score entry from a Game Center leaderboard.
public struct PrismLeaderboardScore: Sendable {
    /// The player identifier who achieved this score.
    public let playerID: String
    /// The display name of the player.
    public let displayName: String
    /// The raw numeric score value.
    public let value: Int
    /// The player's rank on the leaderboard.
    public let rank: Int
    /// The formatted score string provided by Game Center, if available.
    public let formattedValue: String?
    /// The date when the score was submitted.
    public let date: Date

    /// Creates a new leaderboard score entry with the given player and score data.
    public init(playerID: String, displayName: String, value: Int, rank: Int, formattedValue: String? = nil, date: Date) {
        self.playerID = playerID
        self.displayName = displayName
        self.value = value
        self.rank = rank
        self.formattedValue = formattedValue
        self.date = date
    }
}

// MARK: - Leaderboard Scope

/// The player scope used when querying leaderboard scores.
public enum PrismLeaderboardScope: Sendable {
    /// Scores from all players worldwide.
    case global
    /// Scores from the player's Game Center friends only.
    case friends
}

// MARK: - Leaderboard Time Scope

/// The time range filter for leaderboard score queries.
public enum PrismLeaderboardTimeScope: Sendable, CaseIterable {
    /// Scores submitted today.
    case today
    /// Scores submitted in the past week.
    case week
    /// All scores ever submitted.
    case allTime
}

// MARK: - Achievement

/// Represents a Game Center achievement with progress tracking.
public struct PrismAchievement: Sendable {
    /// The unique achievement identifier registered in App Store Connect.
    public let id: String
    /// The localized achievement title.
    public let title: String
    /// The completion percentage from 0 to 100.
    public let percentComplete: Double
    /// Whether the achievement has been fully completed.
    public let isCompleted: Bool
    /// Whether to show a completion banner when the achievement is earned.
    public let showsCompletionBanner: Bool

    /// Creates a new achievement with the given identifier and progress.
    public init(id: String, title: String, percentComplete: Double, isCompleted: Bool, showsCompletionBanner: Bool) {
        self.id = id
        self.title = title
        self.percentComplete = percentComplete
        self.isCompleted = isCompleted
        self.showsCompletionBanner = showsCompletionBanner
    }
}

// MARK: - Match Request

/// Configuration for finding a real-time or turn-based multiplayer match.
public struct PrismMatchRequest: Sendable {
    /// The minimum number of players required for the match.
    public let minPlayers: Int
    /// The maximum number of players allowed in the match.
    public let maxPlayers: Int
    /// An optional group number to match players within the same group.
    public let playerGroup: Int?
    /// The default number of players when presenting the matchmaker UI.
    public let defaultNumberOfPlayers: Int

    /// Creates a new match request with the given player count constraints.
    public init(minPlayers: Int, maxPlayers: Int, playerGroup: Int? = nil, defaultNumberOfPlayers: Int) {
        self.minPlayers = minPlayers
        self.maxPlayers = maxPlayers
        self.playerGroup = playerGroup
        self.defaultNumberOfPlayers = defaultNumberOfPlayers
    }
}

// MARK: - Match Status

/// The current status of a Game Center multiplayer match.
public enum PrismMatchStatus: Sendable, CaseIterable {
    /// The match status is unknown.
    case unknown
    /// The match is open and accepting players.
    case open
    /// The match has ended.
    case ended
    /// The match is currently looking for players.
    case matching
}

// MARK: - Game Center Client

/// Observable client that wraps GameKit APIs for authentication, leaderboards, achievements, and matchmaking.
///
/// Usage:
/// ```swift
/// let client = PrismGameCenterClient()
/// let player = try await client.authenticate()
/// try await client.submitScore(value: 1500, leaderboardID: "com.game.highscores")
/// ```
@MainActor @Observable
public final class PrismGameCenterClient {
    /// The currently authenticated local player, or nil if not authenticated.
    public private(set) var localPlayer: PrismGameCenterPlayer?
    /// Whether the local player is currently authenticated with Game Center.
    public private(set) var isAuthenticated: Bool = false

    /// Creates a new Game Center client.
    public init() {}

    /// Authenticates the local player with Game Center.
    ///
    /// Sets the `GKLocalPlayer.local.authenticateHandler` and waits for authentication to complete.
    /// - Returns: The authenticated `PrismGameCenterPlayer`.
    /// - Throws: An error if authentication fails.
    @discardableResult
    public func authenticate() async throws -> PrismGameCenterPlayer {
        try await withCheckedThrowingContinuation { continuation in
            GKLocalPlayer.local.authenticateHandler = { viewController, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let local = GKLocalPlayer.local
                guard local.isAuthenticated else {
                    continuation.resume(throwing: GKError(.notAuthenticated))
                    return
                }
                let player = PrismGameCenterPlayer(
                    id: local.gamePlayerID,
                    displayName: local.displayName,
                    alias: local.alias,
                    isAuthenticated: true
                )
                continuation.resume(returning: player)
            }
        }
    }

    /// Submits a score to the specified leaderboard.
    ///
    /// - Parameters:
    ///   - value: The numeric score value to submit.
    ///   - leaderboardID: The identifier of the leaderboard in App Store Connect.
    public func submitScore(value: Int, leaderboardID: String) async throws {
        try await GKLeaderboard.submitScore(
            value,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID]
        )
    }

    /// Loads scores from the specified leaderboard.
    ///
    /// - Parameters:
    ///   - leaderboardID: The leaderboard identifier.
    ///   - scope: Whether to load global or friends-only scores.
    ///   - timeScope: The time range filter (today, week, or all time).
    ///   - range: The range of ranks to load (e.g., `1..<26` for the top 25).
    /// - Returns: An array of `PrismLeaderboardScore` entries.
    public func loadScores(leaderboardID: String, scope: PrismLeaderboardScope, timeScope: PrismLeaderboardTimeScope, range: Range<Int>) async throws -> [PrismLeaderboardScore] {
        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
        guard let leaderboard = leaderboards.first else { return [] }

        let playerScope: GKLeaderboard.PlayerScope = switch scope {
        case .global: .global
        case .friends: .friendsOnly
        }

        let gkTimeScope: GKLeaderboard.TimeScope = switch timeScope {
        case .today: .today
        case .week: .week
        case .allTime: .allTime
        }

        let nsRange = NSRange(location: range.lowerBound, length: range.count)
        let (_, entries, _) = try await leaderboard.loadEntries(for: playerScope, timeScope: gkTimeScope, range: nsRange)

        return entries.enumerated().map { index, entry in
            PrismLeaderboardScore(
                playerID: entry.player.gamePlayerID,
                displayName: entry.player.displayName,
                value: entry.score,
                rank: entry.rank,
                formattedValue: entry.formattedScore,
                date: entry.date
            )
        }
    }

    /// Reports progress on an achievement.
    ///
    /// - Parameters:
    ///   - id: The achievement identifier registered in App Store Connect.
    ///   - percentComplete: The completion percentage (0 to 100).
    public func reportAchievement(id: String, percentComplete: Double) async throws {
        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        try await GKAchievement.report([achievement])
    }

    /// Loads all achievements for the local player.
    ///
    /// - Returns: An array of `PrismAchievement` with current progress.
    public func loadAchievements() async throws -> [PrismAchievement] {
        let gkAchievements = try await GKAchievement.loadAchievements()
        return gkAchievements.map { achievement in
            PrismAchievement(
                id: achievement.identifier,
                title: achievement.identifier,
                percentComplete: achievement.percentComplete,
                isCompleted: achievement.isCompleted,
                showsCompletionBanner: achievement.showsCompletionBanner
            )
        }
    }

    /// Resets all achievements for the local player.
    public func resetAchievements() async throws {
        try await GKAchievement.resetAchievements()
    }

    /// Finds a match using the specified match request configuration.
    ///
    /// - Parameter request: The match configuration specifying player count and grouping.
    public func findMatch(request: PrismMatchRequest) async throws {
        let gkRequest = GKMatchRequest()
        gkRequest.minPlayers = request.minPlayers
        gkRequest.maxPlayers = request.maxPlayers
        gkRequest.defaultNumberOfPlayers = request.defaultNumberOfPlayers
        if let group = request.playerGroup {
            gkRequest.playerGroup = group
        }
        _ = try await GKMatchmaker.shared().findMatch(for: gkRequest)
    }

    /// Presents the Game Center leaderboard UI for the specified leaderboard.
    ///
    /// - Parameter id: The leaderboard identifier to display.
    public func showLeaderboard(id: String) {
        let viewController = GKGameCenterViewController(leaderboardID: id, playerScope: .global, timeScope: .allTime)
        presentGameCenterViewController(viewController)
    }

    /// Presents the Game Center achievements UI.
    public func showAchievements() {
        let viewController = GKGameCenterViewController(state: .achievements)
        presentGameCenterViewController(viewController)
    }

    // MARK: - Private

    private func presentGameCenterViewController(_ viewController: GKGameCenterViewController) {
        #if canImport(UIKit)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else { return }
        rootVC.present(viewController, animated: true)
        #elseif canImport(AppKit)
        guard let window = NSApplication.shared.mainWindow else { return }
        window.contentViewController?.presentAsSheet(viewController)
        #endif
    }
}
#endif
