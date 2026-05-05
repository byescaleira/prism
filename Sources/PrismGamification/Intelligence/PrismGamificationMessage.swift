import Foundation

/// An AI-generated gamification message with metadata.
public struct PrismGamificationMessage: Sendable, Equatable, Identifiable {
    /// Unique identifier.
    public let id: String
    /// The kind of gamification message.
    public let kind: PrismGamificationMessageKind
    /// The generated message text.
    public let content: String
    /// The entity this message relates to (challenge ID, badge ID, etc.).
    public let entityID: String
    /// When this message was generated.
    public let generatedAt: Date

    /// Creates a gamification message.
    public init(
        id: String = UUID().uuidString,
        kind: PrismGamificationMessageKind,
        content: String,
        entityID: String,
        generatedAt: Date = .now
    ) {
        self.id = id
        self.kind = kind
        self.content = content
        self.entityID = entityID
        self.generatedAt = generatedAt
    }
}
