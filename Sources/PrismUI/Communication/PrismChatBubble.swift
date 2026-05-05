import SwiftUI

/// Visual style for chat bubble appearance.
public enum PrismBubbleStyle: String, Sendable, CaseIterable {
    /// Solid background fill using theme color.
    case filled
    /// Transparent background with a border stroke.
    case outlined
    /// Translucent material background for a frosted-glass look.
    case glass
}

/// A single chat message bubble with sender alignment, timestamp, and delivery status.
@MainActor
public struct PrismChatBubble: View {
    @Environment(\.prismTheme) private var theme

    private let text: String
    private let timestamp: Date
    private let isOutgoing: Bool
    private let style: PrismBubbleStyle
    private let status: PrismMessageStatus?

    /// Creates a chat bubble positioned by sender direction.
    public init(
        text: String,
        timestamp: Date = .now,
        isOutgoing: Bool = true,
        style: PrismBubbleStyle = .filled,
        status: PrismMessageStatus? = nil
    ) {
        self.text = text
        self.timestamp = timestamp
        self.isOutgoing = isOutgoing
        self.style = style
        self.status = status
    }

    /// The chat bubble view body with styled background and delivery status.
    public var body: some View {
        HStack {
            if isOutgoing { Spacer(minLength: 48) }

            VStack(alignment: isOutgoing ? .trailing : .leading, spacing: 4) {
                Text(text)
                    .font(TypographyToken.body.font)
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(isOutgoing ? .trailing : .leading)

                HStack(spacing: 4) {
                    Text(timestamp, style: .time)
                        .font(TypographyToken.caption2.font)
                        .foregroundStyle(secondaryTextColor)

                    if let status, isOutgoing {
                        PrismReadReceiptIndicator(status: status)
                    }
                }
            }
            .padding(.horizontal, SpacingToken.md.rawValue)
            .padding(.vertical, SpacingToken.sm.rawValue)
            .background {
                if useMaterial {
                    bubbleShape.fill(.ultraThinMaterial)
                } else {
                    bubbleShape.fill(bubbleBackgroundColor)
                }
            }
            .overlay(bubbleOverlay)

            if !isOutgoing { Spacer(minLength: 48) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Styling

    private var bubbleShape: UnevenRoundedRectangle {
        let large: CGFloat = RadiusToken.lg.rawValue
        let small: CGFloat = RadiusToken.sm.rawValue
        if isOutgoing {
            return UnevenRoundedRectangle(
                topLeadingRadius: large,
                bottomLeadingRadius: large,
                bottomTrailingRadius: small,
                topTrailingRadius: large
            )
        } else {
            return UnevenRoundedRectangle(
                topLeadingRadius: large,
                bottomLeadingRadius: small,
                bottomTrailingRadius: large,
                topTrailingRadius: large
            )
        }
    }

    private var bubbleBackgroundColor: Color {
        switch style {
        case .filled:
            return isOutgoing ? theme.color(.brand) : theme.color(.surfaceSecondary)
        case .outlined:
            return theme.color(.background).opacity(0.01)
        case .glass:
            return theme.color(.surfaceSecondary).opacity(0.3)
        }
    }

    private var useMaterial: Bool {
        style == .glass
    }

    @ViewBuilder
    private var bubbleOverlay: some View {
        if style == .outlined {
            bubbleShape
                .stroke(theme.color(.border), lineWidth: 1)
        }
    }

    private var textColor: Color {
        switch style {
        case .filled where isOutgoing:
            return theme.color(.onBrand)
        default:
            return theme.color(.onSurface)
        }
    }

    private var secondaryTextColor: Color {
        switch style {
        case .filled where isOutgoing:
            return theme.color(.onBrand).opacity(0.7)
        default:
            return theme.color(.onSurfaceSecondary)
        }
    }

    private var accessibilityDescription: String {
        let direction = isOutgoing ? "Sent" : "Received"
        let statusText = status.map { ", \($0.rawValue)" } ?? ""
        return "\(direction) message: \(text)\(statusText)"
    }
}
