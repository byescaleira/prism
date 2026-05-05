import Foundation
import Testing

@testable import PrismGamification
@testable import PrismIntelligence

// MARK: - Mock Provider

final class MockLangProvider: PrismLanguageIntelligenceProvider, @unchecked Sendable {
    let kind: PrismLanguageIntelligenceProviderKind = .apple
    var available = true
    var responseContent = "Test message"
    var shouldThrow = false
    var lastRequest: PrismLanguageIntelligenceRequest?

    func status() async -> PrismLanguageIntelligenceStatus {
        PrismLanguageIntelligenceStatus(
            provider: .apple,
            isAvailable: available
        )
    }

    func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse {
        lastRequest = request
        if shouldThrow {
            throw PrismIntelligenceError.providerUnavailable("Mock unavailable")
        }
        return PrismLanguageIntelligenceResponse(
            provider: .apple,
            content: responseContent
        )
    }
}

// MARK: - Message Kind Tests

@Suite("MsgKTests")
struct MsgKTests {

    @Test("all cases")
    func allCases() {
        #expect(PrismGamificationMessageKind.allCases.count == 7)
    }

    @Test("raw values")
    func rawValues() {
        #expect(PrismGamificationMessageKind.challengeCompleted.rawValue == "challengeCompleted")
        #expect(PrismGamificationMessageKind.streakMotivation.rawValue == "streakMotivation")
        #expect(PrismGamificationMessageKind.badgeUnlocked.rawValue == "badgeUnlocked")
        #expect(PrismGamificationMessageKind.leaderboardUpdate.rawValue == "leaderboardUpdate")
        #expect(PrismGamificationMessageKind.challengeRecommendation.rawValue == "challengeRecommendation")
        #expect(PrismGamificationMessageKind.challengeProgress.rawValue == "challengeProgress")
        #expect(PrismGamificationMessageKind.streakAtRisk.rawValue == "streakAtRisk")
    }

    @Test("codable roundtrip")
    func codable() throws {
        let data = try JSONEncoder().encode(PrismGamificationMessageKind.badgeUnlocked)
        let decoded = try JSONDecoder().decode(PrismGamificationMessageKind.self, from: data)
        #expect(decoded == .badgeUnlocked)
    }
}

// MARK: - Message Tests

@Suite("GamMsgTests")
struct GamMsgTests {

    @Test("init properties")
    func initProps() {
        let msg = PrismGamificationMessage(
            kind: .challengeCompleted,
            content: "Nice!",
            entityID: "login"
        )
        #expect(msg.kind == .challengeCompleted)
        #expect(msg.content == "Nice!")
        #expect(msg.entityID == "login")
        #expect(!msg.id.isEmpty)
    }

    @Test("equatable")
    func equatable() {
        let a = PrismGamificationMessage(
            id: "1", kind: .streakMotivation, content: "Go!", entityID: "daily"
        )
        let b = PrismGamificationMessage(
            id: "1", kind: .streakMotivation, content: "Go!", entityID: "daily"
        )
        #expect(a == b)
    }

    @Test("identifiable")
    func identifiable() {
        let msg = PrismGamificationMessage(
            id: "abc", kind: .badgeUnlocked, content: "Yay", entityID: "b1"
        )
        #expect(msg.id == "abc")
    }

    @Test("custom id")
    func customID() {
        let msg = PrismGamificationMessage(
            id: "custom-123", kind: .leaderboardUpdate, content: "Up!", entityID: "u1"
        )
        #expect(msg.id == "custom-123")
    }
}

// MARK: - Context Tests

@Suite("GamCtxTests")
struct GamCtxTests {

    @Test("minimal context")
    func minimal() {
        let ctx = PrismGamificationContext(entityID: "test")
        #expect(ctx.entityID == "test")
        #expect(ctx.challengeTitle == nil)
        #expect(ctx.currentValue == nil)
        #expect(ctx.goalValue == nil)
        #expect(ctx.points == nil)
        #expect(ctx.totalPoints == nil)
        #expect(ctx.currentStreak == nil)
        #expect(ctx.longestStreak == nil)
        #expect(ctx.badgeTitle == nil)
        #expect(ctx.badgeTier == nil)
        #expect(ctx.rank == nil)
        #expect(ctx.previousRank == nil)
        #expect(ctx.score == nil)
        #expect(ctx.completedChallenges == nil)
        #expect(ctx.activeCategories == nil)
    }

    @Test("full context")
    func full() {
        let ctx = PrismGamificationContext(
            entityID: "workout",
            challengeTitle: "Ten Workouts",
            currentValue: 5,
            goalValue: 10,
            points: 50,
            totalPoints: 200,
            currentStreak: 7,
            longestStreak: 14,
            badgeTitle: "Starter",
            badgeTier: "bronze",
            rank: 3,
            previousRank: 5,
            score: 500,
            completedChallenges: 12,
            activeCategories: ["fitness", "health"]
        )
        #expect(ctx.challengeTitle == "Ten Workouts")
        #expect(ctx.currentValue == 5)
        #expect(ctx.goalValue == 10)
        #expect(ctx.points == 50)
        #expect(ctx.totalPoints == 200)
        #expect(ctx.currentStreak == 7)
        #expect(ctx.longestStreak == 14)
        #expect(ctx.badgeTitle == "Starter")
        #expect(ctx.badgeTier == "bronze")
        #expect(ctx.rank == 3)
        #expect(ctx.previousRank == 5)
        #expect(ctx.score == 500)
        #expect(ctx.completedChallenges == 12)
        #expect(ctx.activeCategories == ["fitness", "health"])
    }

    @Test("equatable")
    func equatable() {
        let a = PrismGamificationContext(entityID: "x", points: 10)
        let b = PrismGamificationContext(entityID: "x", points: 10)
        #expect(a == b)
    }

    @Test("not equal")
    func notEqual() {
        let a = PrismGamificationContext(entityID: "x", points: 10)
        let b = PrismGamificationContext(entityID: "x", points: 20)
        #expect(a != b)
    }
}

// MARK: - Prompt Builder Tests

@Suite("PrmBTests")
struct PrmBTests {

    let builder = PrismGamificationPromptBuilder()

    @Test("system instructions not empty")
    func sysInstr() {
        #expect(!builder.systemInstructions.isEmpty)
        #expect(builder.systemInstructions.contains("gamification"))
    }

    @Test("challenge completed prompt")
    func challengeCompleted() {
        let ctx = PrismGamificationContext(
            entityID: "workout", challengeTitle: "Workout", points: 50, totalPoints: 200
        )
        let prompt = builder.prompt(for: .challengeCompleted, context: ctx)
        #expect(prompt.contains("Workout"))
        #expect(prompt.contains("50"))
        #expect(prompt.contains("200"))
        #expect(prompt.contains("celebration"))
    }

    @Test("challenge completed no title falls back to entityID")
    func challengeNoTitle() {
        let ctx = PrismGamificationContext(entityID: "tenWorkouts")
        let prompt = builder.prompt(for: .challengeCompleted, context: ctx)
        #expect(prompt.contains("tenWorkouts"))
    }

    @Test("challenge progress prompt")
    func challengeProgress() {
        let ctx = PrismGamificationContext(
            entityID: "steps", challengeTitle: "Walk", currentValue: 7, goalValue: 10
        )
        let prompt = builder.prompt(for: .challengeProgress, context: ctx)
        #expect(prompt.contains("Walk"))
        #expect(prompt.contains("7/10"))
        #expect(prompt.contains("70%"))
    }

    @Test("streak motivation prompt")
    func streakMotivation() {
        let ctx = PrismGamificationContext(
            entityID: "daily", currentStreak: 14, longestStreak: 30
        )
        let prompt = builder.prompt(for: .streakMotivation, context: ctx)
        #expect(prompt.contains("14"))
        #expect(prompt.contains("30"))
    }

    @Test("streak at risk prompt")
    func streakAtRisk() {
        let ctx = PrismGamificationContext(entityID: "daily", currentStreak: 5)
        let prompt = builder.prompt(for: .streakAtRisk, context: ctx)
        #expect(prompt.contains("5"))
        #expect(prompt.contains("break") || prompt.contains("risk"))
    }

    @Test("badge unlocked prompt")
    func badgeUnlocked() {
        let ctx = PrismGamificationContext(
            entityID: "b1", badgeTitle: "Early Bird", badgeTier: "gold"
        )
        let prompt = builder.prompt(for: .badgeUnlocked, context: ctx)
        #expect(prompt.contains("Early Bird"))
        #expect(prompt.contains("gold"))
    }

    @Test("leaderboard update prompt — moved up")
    func lbUp() {
        let ctx = PrismGamificationContext(
            entityID: "u1", rank: 3, previousRank: 5, score: 500
        )
        let prompt = builder.prompt(for: .leaderboardUpdate, context: ctx)
        #expect(prompt.contains("#3"))
        #expect(prompt.contains("2"))
        #expect(prompt.contains("500"))
    }

    @Test("leaderboard update prompt — moved down")
    func lbDown() {
        let ctx = PrismGamificationContext(
            entityID: "u1", rank: 5, previousRank: 3
        )
        let prompt = builder.prompt(for: .leaderboardUpdate, context: ctx)
        #expect(prompt.contains("dropped"))
    }

    @Test("challenge recommendation prompt")
    func recommendation() {
        let ctx = PrismGamificationContext(
            entityID: "user1", totalPoints: 500, completedChallenges: 10,
            activeCategories: ["fitness", "nutrition"]
        )
        let prompt = builder.prompt(for: .challengeRecommendation, context: ctx)
        #expect(prompt.contains("500"))
        #expect(prompt.contains("10"))
        #expect(prompt.contains("fitness"))
    }

    @Test("all kinds produce non-empty prompts")
    func allKinds() {
        let ctx = PrismGamificationContext(entityID: "test")
        for kind in PrismGamificationMessageKind.allCases {
            let prompt = builder.prompt(for: kind, context: ctx)
            #expect(!prompt.isEmpty)
        }
    }
}

// MARK: - Fallback Tests

@Suite("FallTests")
struct FallTests {

    @Test("challenge completed with points")
    func ccPts() {
        let ctx = PrismGamificationContext(
            entityID: "login", challengeTitle: "First Login", points: 10
        )
        let msg = PrismGamificationFallbacks.message(for: .challengeCompleted, context: ctx)
        #expect(msg.contains("First Login"))
        #expect(msg.contains("+10"))
    }

    @Test("challenge completed no points")
    func ccNoPts() {
        let ctx = PrismGamificationContext(entityID: "login", challengeTitle: "Login")
        let msg = PrismGamificationFallbacks.message(for: .challengeCompleted, context: ctx)
        #expect(msg.contains("Login"))
        #expect(msg.contains("completed"))
    }

    @Test("challenge completed no title")
    func ccNoTitle() {
        let ctx = PrismGamificationContext(entityID: "myChallenge")
        let msg = PrismGamificationFallbacks.message(for: .challengeCompleted, context: ctx)
        #expect(msg.contains("myChallenge"))
    }

    @Test("challenge progress")
    func cp() {
        let ctx = PrismGamificationContext(
            entityID: "steps", challengeTitle: "Walk", currentValue: 5, goalValue: 10
        )
        let msg = PrismGamificationFallbacks.message(for: .challengeProgress, context: ctx)
        #expect(msg.contains("5/10"))
        #expect(msg.contains("Walk"))
    }

    @Test("challenge progress no values")
    func cpNoVals() {
        let ctx = PrismGamificationContext(entityID: "steps", challengeTitle: "Walk")
        let msg = PrismGamificationFallbacks.message(for: .challengeProgress, context: ctx)
        #expect(msg.contains("Walk"))
    }

    @Test("streak motivation")
    func sm() {
        let ctx = PrismGamificationContext(entityID: "daily", currentStreak: 7)
        let msg = PrismGamificationFallbacks.message(for: .streakMotivation, context: ctx)
        #expect(msg.contains("7"))
    }

    @Test("streak at risk")
    func sar() {
        let ctx = PrismGamificationContext(entityID: "daily", currentStreak: 3)
        let msg = PrismGamificationFallbacks.message(for: .streakAtRisk, context: ctx)
        #expect(msg.contains("3"))
        #expect(msg.contains("risk"))
    }

    @Test("badge unlocked with tier")
    func bu() {
        let ctx = PrismGamificationContext(
            entityID: "b1", badgeTitle: "Expert", badgeTier: "gold"
        )
        let msg = PrismGamificationFallbacks.message(for: .badgeUnlocked, context: ctx)
        #expect(msg.contains("Gold"))
        #expect(msg.contains("Expert"))
    }

    @Test("badge unlocked no tier")
    func buNoTier() {
        let ctx = PrismGamificationContext(entityID: "b1", badgeTitle: "Expert")
        let msg = PrismGamificationFallbacks.message(for: .badgeUnlocked, context: ctx)
        #expect(msg.contains("Expert"))
        #expect(msg.contains("unlocked"))
    }

    @Test("leaderboard update with rank")
    func lu() {
        let ctx = PrismGamificationContext(entityID: "u1", rank: 2)
        let msg = PrismGamificationFallbacks.message(for: .leaderboardUpdate, context: ctx)
        #expect(msg.contains("#2"))
    }

    @Test("leaderboard update no rank")
    func luNoRank() {
        let ctx = PrismGamificationContext(entityID: "u1")
        let msg = PrismGamificationFallbacks.message(for: .leaderboardUpdate, context: ctx)
        #expect(msg.contains("leaderboard"))
    }

    @Test("recommendation")
    func rec() {
        let ctx = PrismGamificationContext(entityID: "user1")
        let msg = PrismGamificationFallbacks.message(for: .challengeRecommendation, context: ctx)
        #expect(!msg.isEmpty)
    }
}

// MARK: - Intelligence Actor Tests

@Suite("GamIntTests")
struct GamIntTests {

    @Test("generate message")
    func generate() async throws {
        let mock = MockLangProvider()
        mock.responseContent = "You did it!"
        let intel = PrismGamificationIntelligence(provider: mock)
        let ctx = PrismGamificationContext(entityID: "login", challengeTitle: "Login")
        let msg = try await intel.generateMessage(kind: .challengeCompleted, context: ctx)
        #expect(msg.content == "You did it!")
        #expect(msg.kind == .challengeCompleted)
        #expect(msg.entityID == "login")
    }

    @Test("generate uses system prompt")
    func sysPrompt() async throws {
        let mock = MockLangProvider()
        let intel = PrismGamificationIntelligence(provider: mock)
        let ctx = PrismGamificationContext(entityID: "test")
        _ = try await intel.generateMessage(kind: .streakMotivation, context: ctx)
        #expect(mock.lastRequest?.systemPrompt?.contains("gamification") == true)
    }

    @Test("generate uses temperature")
    func temp() async throws {
        let mock = MockLangProvider()
        let intel = PrismGamificationIntelligence(provider: mock)
        let ctx = PrismGamificationContext(entityID: "test")
        _ = try await intel.generateMessage(kind: .streakMotivation, context: ctx)
        #expect(mock.lastRequest?.options.temperature == 0.7)
    }

    @Test("generate uses max tokens")
    func maxTok() async throws {
        let mock = MockLangProvider()
        let intel = PrismGamificationIntelligence(provider: mock)
        let ctx = PrismGamificationContext(entityID: "test")
        _ = try await intel.generateMessage(kind: .streakMotivation, context: ctx)
        #expect(mock.lastRequest?.options.maximumResponseTokens == 100)
    }

    @Test("isAvailable true")
    func availTrue() async {
        let mock = MockLangProvider()
        mock.available = true
        let intel = PrismGamificationIntelligence(provider: mock)
        #expect(await intel.isAvailable())
    }

    @Test("isAvailable false")
    func availFalse() async {
        let mock = MockLangProvider()
        mock.available = false
        let intel = PrismGamificationIntelligence(provider: mock)
        #expect(await intel.isAvailable() == false)
    }

    @Test("generate throws when provider fails")
    func genThrows() async throws {
        let mock = MockLangProvider()
        mock.shouldThrow = true
        let intel = PrismGamificationIntelligence(provider: mock)
        let ctx = PrismGamificationContext(entityID: "test")
        do {
            _ = try await intel.generateMessage(kind: .challengeCompleted, context: ctx)
            Issue.record("Expected error")
        } catch {
            #expect(error is PrismIntelligenceError)
        }
    }

    @Test("batch generate")
    func batch() async {
        let mock = MockLangProvider()
        mock.responseContent = "Msg"
        let intel = PrismGamificationIntelligence(provider: mock)
        let items: [(kind: PrismGamificationMessageKind, context: PrismGamificationContext)] = [
            (.challengeCompleted, PrismGamificationContext(entityID: "a")),
            (.streakMotivation, PrismGamificationContext(entityID: "b")),
            (.badgeUnlocked, PrismGamificationContext(entityID: "c")),
        ]
        let msgs = await intel.generateMessages(items)
        #expect(msgs.count == 3)
    }

    @Test("batch skips failures")
    func batchSkips() async {
        let mock = MockLangProvider()
        mock.shouldThrow = true
        let intel = PrismGamificationIntelligence(provider: mock)
        let items: [(kind: PrismGamificationMessageKind, context: PrismGamificationContext)] = [
            (.challengeCompleted, PrismGamificationContext(entityID: "a")),
        ]
        let msgs = await intel.generateMessages(items)
        #expect(msgs.isEmpty)
    }

    @Test("fallback message")
    func fallback() async {
        let mock = MockLangProvider()
        let intel = PrismGamificationIntelligence(provider: mock)
        let ctx = PrismGamificationContext(
            entityID: "login", challengeTitle: "Login", points: 10
        )
        let msg = await intel.fallbackMessage(kind: .challengeCompleted, context: ctx)
        #expect(msg.content.contains("Login"))
        #expect(msg.kind == .challengeCompleted)
    }

    @Test("messageWithFallback uses AI when available")
    func withFallbackAI() async {
        let mock = MockLangProvider()
        mock.available = true
        mock.responseContent = "AI message"
        let intel = PrismGamificationIntelligence(provider: mock)
        let ctx = PrismGamificationContext(entityID: "test")
        let msg = await intel.messageWithFallback(kind: .streakMotivation, context: ctx)
        #expect(msg.content == "AI message")
    }

    @Test("messageWithFallback uses fallback when unavailable")
    func withFallbackStatic() async {
        let mock = MockLangProvider()
        mock.available = false
        let intel = PrismGamificationIntelligence(provider: mock)
        let ctx = PrismGamificationContext(entityID: "daily", currentStreak: 5)
        let msg = await intel.messageWithFallback(kind: .streakMotivation, context: ctx)
        #expect(msg.content.contains("5"))
    }

    @Test("messageWithFallback uses fallback on error")
    func withFallbackErr() async {
        let mock = MockLangProvider()
        mock.available = true
        mock.shouldThrow = true
        let intel = PrismGamificationIntelligence(provider: mock)
        let ctx = PrismGamificationContext(entityID: "daily", currentStreak: 3)
        let msg = await intel.messageWithFallback(kind: .streakMotivation, context: ctx)
        #expect(msg.content.contains("3"))
    }
}
