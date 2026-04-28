import SwiftUI

/// A single emoji reaction with usage count and selection state.
public struct PrismReaction: Identifiable, Sendable, Equatable {
    /// Stable identifier derived from the emoji character.
    public var id: String { emoji }
    /// The emoji character representing this reaction.
    public let emoji: String
    /// How many users chose this reaction.
    public var count: Int
    /// Whether the current user selected this reaction.
    public var isSelected: Bool

    /// Creates a reaction with the given emoji and initial state.
    public init(emoji: String, count: Int = 0, isSelected: Bool = false) {
        self.emoji = emoji
        self.count = count
        self.isSelected = isSelected
    }
}

/// A horizontal emoji strip that lets users pick a reaction with a pop-in animation.
@MainActor
public struct PrismReactionPicker: View {
    @Environment(\.prismTheme) private var theme

    private let emojis: [String]
    private let onSelect: (String) -> Void

    @State private var appeared = false

    /// Creates a picker from a list of emoji strings.
    public init(
        emojis: [String] = ["👍", "❤️", "😂", "😮", "😢", "🙏"],
        onSelect: @escaping (String) -> Void
    ) {
        self.emojis = emojis
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            ForEach(Array(emojis.enumerated()), id: \.offset) { index, emoji in
                Button {
                    onSelect(emoji)
                } label: {
                    Text(emoji)
                        .font(.system(size: 24))
                }
                .buttonStyle(.plain)
                .scaleEffect(appeared ? 1 : 0.01)
                .animation(
                    .spring(response: 0.3, dampingFraction: 0.6)
                        .delay(Double(index) * 0.05),
                    value: appeared
                )
                .accessibilityLabel("React with \(emoji)")
            }
        }
        .padding(.horizontal, SpacingToken.md.rawValue)
        .padding(.vertical, SpacingToken.sm.rawValue)
        .background(.ultraThinMaterial, in: Capsule())
        .onAppear { appeared = true }
        .accessibilityLabel("Reaction picker")
    }
}

/// Displays emoji reactions below a message with counts and selection highlighting.
@MainActor
public struct PrismReactionBar: View {
    @Environment(\.prismTheme) private var theme

    @Binding private var reactions: [PrismReaction]
    private let onLongPress: (() -> Void)?

    /// Creates a reaction bar bound to a list of reactions.
    public init(reactions: Binding<[PrismReaction]>, onLongPress: (() -> Void)? = nil) {
        self._reactions = reactions
        self.onLongPress = onLongPress
    }

    public var body: some View {
        if !reactions.isEmpty {
            HStack(spacing: SpacingToken.xs.rawValue) {
                ForEach(reactions) { reaction in
                    reactionChip(reaction)
                }
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                onLongPress?()
            }
            .accessibilityLabel("Reactions: \(reactions.map { "\($0.emoji) \($0.count)" }.joined(separator: ", "))")
        }
    }

    private func reactionChip(_ reaction: PrismReaction) -> some View {
        Button {
            toggleReaction(reaction)
        } label: {
            HStack(spacing: 2) {
                Text(reaction.emoji)
                    .font(.system(size: 14))
                if reaction.count > 0 {
                    Text("\(reaction.count)")
                        .font(TypographyToken.caption2.font(weight: .medium))
                        .foregroundStyle(
                            reaction.isSelected
                                ? theme.color(.brand)
                                : theme.color(.onSurfaceSecondary)
                        )
                }
            }
            .padding(.horizontal, SpacingToken.sm.rawValue)
            .padding(.vertical, 4)
            .background(
                reaction.isSelected
                    ? theme.color(.brand).opacity(0.15)
                    : theme.color(.surfaceSecondary),
                in: Capsule()
            )
            .overlay(
                reaction.isSelected
                    ? Capsule().stroke(theme.color(.brand), lineWidth: 1)
                    : nil
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(reaction.emoji), \(reaction.count) reactions\(reaction.isSelected ? ", selected" : "")")
    }

    private func toggleReaction(_ reaction: PrismReaction) {
        guard let index = reactions.firstIndex(where: { $0.id == reaction.id }) else { return }
        reactions[index].isSelected.toggle()
        reactions[index].count += reactions[index].isSelected ? 1 : -1
    }
}
