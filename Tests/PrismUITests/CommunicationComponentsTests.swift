import SwiftUI
import Testing

@testable import PrismUI

@Suite("Communication Components")
struct CommunicationComponentsTests {

    // MARK: - PrismBubbleStyle

    @Test
    func bubbleStyleHasThreeCases() {
        let cases: [PrismBubbleStyle] = [.filled, .outlined, .glass]
        #expect(cases.count == 3)
        #expect(PrismBubbleStyle.allCases.count == 3)
    }

    @Test
    func bubbleStyleRawValues() {
        #expect(PrismBubbleStyle.filled.rawValue == "filled")
        #expect(PrismBubbleStyle.outlined.rawValue == "outlined")
        #expect(PrismBubbleStyle.glass.rawValue == "glass")
    }

    // MARK: - PrismMessageStatus

    @Test
    func messageStatusHasFiveCases() {
        let cases: [PrismMessageStatus] = [.sending, .sent, .delivered, .read, .failed]
        #expect(cases.count == 5)
        #expect(PrismMessageStatus.allCases.count == 5)
    }

    @Test
    func messageStatusRawValues() {
        #expect(PrismMessageStatus.sending.rawValue == "sending")
        #expect(PrismMessageStatus.sent.rawValue == "sent")
        #expect(PrismMessageStatus.delivered.rawValue == "delivered")
        #expect(PrismMessageStatus.read.rawValue == "read")
        #expect(PrismMessageStatus.failed.rawValue == "failed")
    }

    // MARK: - PrismMessage

    @Test
    func messageStoresAllProperties() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let msg = PrismMessage(
            text: "Hello",
            sender: "Alice",
            timestamp: date,
            isOutgoing: true,
            status: .delivered
        )
        #expect(msg.text == "Hello")
        #expect(msg.sender == "Alice")
        #expect(msg.timestamp == date)
        #expect(msg.isOutgoing == true)
        #expect(msg.status == .delivered)
        #expect(msg.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
    }

    @Test
    func messageDefaultValues() {
        let msg = PrismMessage(text: "Hi", sender: "Bob")
        #expect(msg.isOutgoing == false)
        #expect(msg.status == .sent)
    }

    @Test
    func messageEquality() {
        let id = UUID()
        let date = Date.now
        let a = PrismMessage(id: id, text: "Hi", sender: "A", timestamp: date, isOutgoing: true, status: .sent)
        let b = PrismMessage(id: id, text: "Hi", sender: "A", timestamp: date, isOutgoing: true, status: .sent)
        #expect(a == b)
    }

    // MARK: - PrismChatBubble

    @Test @MainActor
    func chatBubbleIsView() {
        let bubble = PrismChatBubble(text: "Test", timestamp: .now, isOutgoing: true)
        #expect(bubble is any View)
    }

    @Test @MainActor
    func chatBubbleAcceptsAllStyles() {
        for style in PrismBubbleStyle.allCases {
            let bubble = PrismChatBubble(text: "Hi", style: style)
            #expect(bubble is any View)
        }
    }

    @Test @MainActor
    func chatBubbleAcceptsStatus() {
        let bubble = PrismChatBubble(text: "Msg", status: .read)
        #expect(bubble is any View)
    }

    // MARK: - PrismMessageList

    @Test @MainActor
    func messageListIsView() {
        let messages = [PrismMessage(text: "Hello", sender: "Alice")]
        let list = PrismMessageList(messages: messages)
        #expect(list is any View)
    }

    @Test @MainActor
    func messageListAcceptsBubbleStyle() {
        let list = PrismMessageList(messages: [], bubbleStyle: .outlined)
        #expect(list is any View)
    }

    // MARK: - PrismMessageGroup

    @Test
    func messageGroupDerivesSenderFromMessages() {
        let msg = PrismMessage(text: "Hi", sender: "Alice", isOutgoing: false)
        let group = PrismMessageGroup(sender: "Alice", isOutgoing: false, messages: [msg])
        #expect(group.sender == "Alice")
        #expect(group.isOutgoing == false)
        #expect(group.messages.count == 1)
        #expect(group.id == msg.id)
    }

    // MARK: - PrismTypingIndicator

    @Test @MainActor
    func typingIndicatorIsView() {
        let indicator = PrismTypingIndicator()
        #expect(indicator is any View)
    }

    @Test @MainActor
    func typingIndicatorAcceptsCustomDotSize() {
        let indicator = PrismTypingIndicator(dotSize: 12, color: .red)
        #expect(indicator is any View)
    }

    // MARK: - PrismTypingBubble

    @Test @MainActor
    func typingBubbleIsView() {
        let bubble = PrismTypingBubble(sender: "Alice")
        #expect(bubble is any View)
    }

    // MARK: - PrismReaction

    @Test
    func reactionStoresEmojiAndCount() {
        let reaction = PrismReaction(emoji: "👍", count: 5, isSelected: true)
        #expect(reaction.emoji == "👍")
        #expect(reaction.count == 5)
        #expect(reaction.isSelected == true)
        #expect(reaction.id == "👍")
    }

    @Test
    func reactionDefaultValues() {
        let reaction = PrismReaction(emoji: "❤️")
        #expect(reaction.count == 0)
        #expect(reaction.isSelected == false)
    }

    @Test
    func reactionEquality() {
        let a = PrismReaction(emoji: "😂", count: 3, isSelected: false)
        let b = PrismReaction(emoji: "😂", count: 3, isSelected: false)
        #expect(a == b)
    }

    // MARK: - PrismReactionPicker

    @Test @MainActor
    func reactionPickerIsView() {
        let picker = PrismReactionPicker { _ in }
        #expect(picker is any View)
    }

    @Test @MainActor
    func reactionPickerAcceptsCustomEmojis() {
        let picker = PrismReactionPicker(emojis: ["🔥", "💯"]) { _ in }
        #expect(picker is any View)
    }

    // MARK: - PrismThread

    @Test
    func threadStoresRootAndReplies() {
        let root = PrismMessage(text: "Root", sender: "Alice", isOutgoing: false)
        let reply = PrismMessage(text: "Reply", sender: "Bob", isOutgoing: true)
        let thread = PrismThread(rootMessage: root, replies: [reply])
        #expect(thread.rootMessage == root)
        #expect(thread.replies.count == 1)
        #expect(thread.replyCount == 1)
    }

    @Test
    func threadCustomReplyCount() {
        let root = PrismMessage(text: "Root", sender: "A", isOutgoing: false)
        let thread = PrismThread(rootMessage: root, replies: [], replyCount: 42)
        #expect(thread.replyCount == 42)
        #expect(thread.replies.isEmpty)
    }

    @Test
    func threadEquality() {
        let id = UUID()
        let root = PrismMessage(id: UUID(), text: "R", sender: "A", timestamp: .now, isOutgoing: false, status: .sent)
        let a = PrismThread(id: id, rootMessage: root, replies: [])
        let b = PrismThread(id: id, rootMessage: root, replies: [])
        #expect(a == b)
    }

    // MARK: - PrismThreadView

    @Test @MainActor
    func threadViewIsView() {
        let root = PrismMessage(text: "Root", sender: "Alice")
        let thread = PrismThread(rootMessage: root)
        let view = PrismThreadView(thread: thread)
        #expect(view is any View)
    }

    @Test @MainActor
    func threadViewAcceptsExpandedFlag() {
        let root = PrismMessage(text: "Root", sender: "Alice")
        let thread = PrismThread(rootMessage: root, replies: [PrismMessage(text: "Reply", sender: "Bob")])
        let view = PrismThreadView(thread: thread, expanded: true)
        #expect(view is any View)
    }

    // MARK: - PrismReadReceipt

    @Test
    func readReceiptStoresUserIdAndReadAt() {
        let date = Date(timeIntervalSince1970: 2_000_000)
        let receipt = PrismReadReceipt(userId: "u1", name: "Alice", readAt: date)
        #expect(receipt.userId == "u1")
        #expect(receipt.name == "Alice")
        #expect(receipt.readAt == date)
        #expect(receipt.id == "u1")
    }

    @Test
    func readReceiptEquality() {
        let date = Date.now
        let a = PrismReadReceipt(userId: "u1", name: "A", readAt: date)
        let b = PrismReadReceipt(userId: "u1", name: "A", readAt: date)
        #expect(a == b)
    }

    // MARK: - PrismReadReceiptIndicator

    @Test @MainActor
    func readReceiptIndicatorIsView() {
        let indicator = PrismReadReceiptIndicator(status: .read)
        #expect(indicator is any View)
    }

    @Test @MainActor
    func readReceiptIndicatorHandlesAllStatuses() {
        for status in PrismMessageStatus.allCases {
            let indicator = PrismReadReceiptIndicator(status: status)
            #expect(indicator is any View)
        }
    }

    // MARK: - PrismReadReceiptList

    @Test @MainActor
    func readReceiptListIsView() {
        let receipts = [
            PrismReadReceipt(userId: "u1", name: "Alice"),
            PrismReadReceipt(userId: "u2", name: "Bob"),
        ]
        let list = PrismReadReceiptList(receipts: receipts)
        #expect(list is any View)
    }

    // MARK: - Sendable conformance

    @Test
    func messageIsSendable() {
        let msg: any Sendable = PrismMessage(text: "Hi", sender: "A")
        #expect(msg is PrismMessage)
    }

    @Test
    func reactionIsSendable() {
        let reaction: any Sendable = PrismReaction(emoji: "👍")
        #expect(reaction is PrismReaction)
    }

    @Test
    func threadIsSendable() {
        let root = PrismMessage(text: "R", sender: "A")
        let thread: any Sendable = PrismThread(rootMessage: root)
        #expect(thread is PrismThread)
    }

    @Test
    func readReceiptIsSendable() {
        let receipt: any Sendable = PrismReadReceipt(userId: "u1", name: "A")
        #expect(receipt is PrismReadReceipt)
    }
}
