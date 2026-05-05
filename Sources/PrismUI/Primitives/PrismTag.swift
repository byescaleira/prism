import SwiftUI

/// Small badge/chip for status indicators, labels, and categories.
public struct PrismTag: View {
    @Environment(\.prismTheme) private var theme

    private let text: LocalizedStringKey
    private let style: Style
    private let icon: String?

    /// Creates a tag with text, style, and optional icon.
    public init(
        _ text: LocalizedStringKey,
        style: Style = .default,
        icon: String? = nil
    ) {
        self.text = text
        self.style = style
        self.icon = icon
    }

    /// The content and behavior of the tag.
    public var body: some View {
        HStack(spacing: SpacingToken.xs.rawValue) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(TypographyToken.caption.font(weight: .medium))
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, SpacingToken.sm.rawValue)
        .padding(.vertical, SpacingToken.xs.rawValue)
        .background(backgroundColor, in: Capsule())
        .accessibilityElement(children: .combine)
    }

    private var foregroundColor: Color {
        switch style {
        case .default: theme.color(.onBackgroundSecondary)
        case .success: theme.color(.success)
        case .warning: theme.color(.warning)
        case .error: theme.color(.error)
        case .info: theme.color(.info)
        case .brand: theme.color(.onBrand)
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .default: theme.color(.surfaceSecondary)
        case .success: theme.color(.success).opacity(0.12)
        case .warning: theme.color(.warning).opacity(0.12)
        case .error: theme.color(.error).opacity(0.12)
        case .info: theme.color(.info).opacity(0.12)
        case .brand: theme.color(.brand)
        }
    }
}

// MARK: - Style

extension PrismTag {

    /// Semantic style variants for the tag.
    public enum Style: Sendable {
        /// Represents a neutral default tag style.
        case `default`
        /// Represents a success/positive tag style.
        case success
        /// Represents a warning/caution tag style.
        case warning
        /// Represents an error/negative tag style.
        case error
        /// Represents an informational tag style.
        case info
        /// Represents a branded/accent tag style.
        case brand
    }
}
