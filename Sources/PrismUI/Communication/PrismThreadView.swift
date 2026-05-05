import SwiftUI

/// A conversation thread with a root message and its replies.
public struct PrismThread: Identifiable, Sendable, Equatable {
    /// Unique identifier for this thread.
    public let id: UUID
    /// The original message that started the thread.
    public let rootMessage: PrismMessage
    /// Ordered replies to the root message.
    public let replies: [PrismMessage]
    /// Total number of replies (may differ from loaded replies for pagination).
    public let replyCount: Int

    /// Creates a thread from a root message and its replies.
    public init(
        id: UUID = UUID(),
        rootMessage: PrismMessage,
        replies: [PrismMessage] = [],
        replyCount: Int? = nil
    ) {
        self.id = id
        self.rootMessage = rootMessage
        self.replies = replies
        self.replyCount = replyCount ?? replies.count
    }
}

/// Displays a root message with indented, collapsible replies.
@MainActor
public struct PrismThreadView: View {
    @Environment(\.prismTheme) private var theme

    private let thread: PrismThread
    private let bubbleStyle: PrismBubbleStyle

    @State private var isExpanded: Bool

    /// Creates a thread view that can expand and collapse replies.
    public init(thread: PrismThread, bubbleStyle: PrismBubbleStyle = .filled, expanded: Bool = false) {
        self.thread = thread
        self.bubbleStyle = bubbleStyle
        self._isExpanded = State(initialValue: expanded)
    }

    /// The thread view body with root message and collapsible replies.
    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
            PrismChatBubble(
                text: thread.rootMessage.text,
                timestamp: thread.rootMessage.timestamp,
                isOutgoing: thread.rootMessage.isOutgoing,
                style: bubbleStyle,
                status: thread.rootMessage.status
            )

            if thread.replyCount > 0 {
                replyToggle

                if isExpanded {
                    repliesList
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Thread with \(thread.replyCount) replies")
    }

    // MARK: - Subviews

    private var replyToggle: some View {
        Button {
            isExpanded.toggle()
        } label: {
            HStack(spacing: SpacingToken.xs.rawValue) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 12, weight: .semibold))

                Text("\(thread.replyCount) \(thread.replyCount == 1 ? "reply" : "replies")")
                    .font(TypographyToken.caption.font(weight: .medium))
            }
            .foregroundStyle(theme.color(.brand))
            .padding(.leading, SpacingToken.lg.rawValue)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(thread.replyCount) replies, \(isExpanded ? "collapse" : "expand")")
        .accessibilityHint("Double-tap to \(isExpanded ? "collapse" : "expand") replies")
    }

    private var repliesList: some View {
        VStack(spacing: 2) {
            ForEach(thread.replies) { reply in
                PrismChatBubble(
                    text: reply.text,
                    timestamp: reply.timestamp,
                    isOutgoing: reply.isOutgoing,
                    style: bubbleStyle,
                    status: reply.status
                )
            }
        }
        .padding(.leading, SpacingToken.xl.rawValue)
    }
}
