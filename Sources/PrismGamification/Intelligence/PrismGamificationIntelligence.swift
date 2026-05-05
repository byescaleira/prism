import Foundation
import PrismIntelligence

/// On-device AI-powered gamification message generator.
///
/// Uses Apple Intelligence (FoundationModels) for local processing to create
/// personalized, context-aware messages for challenges, streaks, badges,
/// and leaderboard events.
///
/// ```swift
/// let intelligence = PrismGamificationIntelligence()
///
/// let message = try await intelligence.generateMessage(
///     kind: .challengeCompleted,
///     context: PrismGamificationContext(
///         entityID: "tenWorkouts",
///         challengeTitle: "Ten Workouts",
///         points: 50,
///         totalPoints: 120
///     )
/// )
/// print(message.content) // "You crushed 10 workouts and earned 50 points! 💪"
/// ```
public actor PrismGamificationIntelligence {
    private let provider: any PrismLanguageIntelligenceProvider
    private let promptBuilder: PrismGamificationPromptBuilder

    /// Creates a gamification intelligence instance with Apple Intelligence.
    ///
    /// - Parameter configuration: Apple Intelligence configuration. Defaults to system general model.
    public init(
        configuration: PrismAppleIntelligenceConfiguration = .init()
    ) {
        self.provider = PrismAppleIntelligenceProvider(configuration: configuration)
        self.promptBuilder = PrismGamificationPromptBuilder()
    }

    /// Creates a gamification intelligence instance with a custom provider.
    ///
    /// - Parameter provider: Any language intelligence provider (Apple, remote, or custom).
    public init(provider: any PrismLanguageIntelligenceProvider) {
        self.provider = provider
        self.promptBuilder = PrismGamificationPromptBuilder()
    }

    /// Whether the underlying language model is available on this device.
    public func isAvailable() async -> Bool {
        let status = await provider.status()
        return status.isAvailable
    }

    /// Generates a personalized gamification message.
    ///
    /// - Parameters:
    ///   - kind: The type of gamification message to generate.
    ///   - context: Contextual data about the user's achievement or progress.
    /// - Returns: A ``PrismGamificationMessage`` with AI-generated content.
    public func generateMessage(
        kind: PrismGamificationMessageKind,
        context: PrismGamificationContext
    ) async throws -> PrismGamificationMessage {
        let prompt = promptBuilder.prompt(for: kind, context: context)
        let request = PrismLanguageIntelligenceRequest(
            prompt: prompt,
            systemPrompt: promptBuilder.systemInstructions,
            options: PrismLanguageGenerationOptions(
                temperature: 0.7,
                maximumResponseTokens: 100
            )
        )
        let response = try await provider.generate(request)
        return PrismGamificationMessage(
            kind: kind,
            content: response.content,
            entityID: context.entityID
        )
    }

    /// Generates messages for multiple events in a single batch.
    ///
    /// - Parameter items: Pairs of message kind and context.
    /// - Returns: Successfully generated messages. Failed generations are skipped.
    public func generateMessages(
        _ items: [(kind: PrismGamificationMessageKind, context: PrismGamificationContext)]
    ) async -> [PrismGamificationMessage] {
        var results: [PrismGamificationMessage] = []
        for item in items {
            if let message = try? await generateMessage(kind: item.kind, context: item.context) {
                results.append(message)
            }
        }
        return results
    }

    /// Generates a fallback message when AI is unavailable.
    ///
    /// - Parameters:
    ///   - kind: The type of gamification message.
    ///   - context: Contextual data.
    /// - Returns: A ``PrismGamificationMessage`` with a static fallback.
    public func fallbackMessage(
        kind: PrismGamificationMessageKind,
        context: PrismGamificationContext
    ) -> PrismGamificationMessage {
        let content = PrismGamificationFallbacks.message(for: kind, context: context)
        return PrismGamificationMessage(
            kind: kind,
            content: content,
            entityID: context.entityID
        )
    }

    /// Generates a message with automatic fallback if AI is unavailable.
    ///
    /// - Parameters:
    ///   - kind: The type of gamification message.
    ///   - context: Contextual data.
    /// - Returns: AI-generated message if available, static fallback otherwise.
    public func messageWithFallback(
        kind: PrismGamificationMessageKind,
        context: PrismGamificationContext
    ) async -> PrismGamificationMessage {
        guard await isAvailable() else {
            return fallbackMessage(kind: kind, context: context)
        }
        do {
            return try await generateMessage(kind: kind, context: context)
        } catch {
            return fallbackMessage(kind: kind, context: context)
        }
    }
}
