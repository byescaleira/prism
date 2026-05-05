import SwiftUI

/// Inline feedback banner with icon, message, and optional dismiss.
public struct PrismBanner: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let message: LocalizedStringKey
    private let style: Style
    private let onDismiss: (() -> Void)?

    @State private var isVisible = true

    /// Creates a banner with the given message, style, and optional dismiss handler.
    public init(
        _ message: LocalizedStringKey,
        style: Style = .info,
        onDismiss: (() -> Void)? = nil
    ) {
        self.message = message
        self.style = style
        self.onDismiss = onDismiss
    }

    /// The banner view body with icon, message, and optional dismiss button.
    public var body: some View {
        if isVisible {
            HStack(spacing: SpacingToken.md.rawValue) {
                Image(systemName: style.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(style.color(theme))

                Text(message)
                    .font(TypographyToken.subheadline.font)
                    .foregroundStyle(theme.color(.onSurface))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if onDismiss != nil {
                    Button {
                        withAnimation(reduceMotion ? nil : MotionToken.fast.animation) {
                            isVisible = false
                        }
                        onDismiss?()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(theme.color(.onBackgroundSecondary))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(PrismStrings.dismiss)
                }
            }
            .padding(SpacingToken.lg.rawValue)
            .background(style.color(theme).opacity(0.1), in: RadiusToken.md.shape)
            .overlay(
                RadiusToken.md.shape
                    .stroke(style.color(theme).opacity(0.3), lineWidth: 1)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Style

extension PrismBanner {

    /// Visual style for the banner appearance.
    public enum Style: Sendable {
        /// Informational blue banner.
        case info
        /// Success green banner.
        case success
        /// Warning yellow banner.
        case warning
        /// Error red banner.
        case error

        var icon: String {
            switch self {
            case .info: "info.circle.fill"
            case .success: "checkmark.circle.fill"
            case .warning: "exclamationmark.triangle.fill"
            case .error: "xmark.circle.fill"
            }
        }

        @MainActor
        func color(_ theme: any PrismTheme) -> Color {
            switch self {
            case .info: theme.color(.info)
            case .success: theme.color(.success)
            case .warning: theme.color(.warning)
            case .error: theme.color(.error)
            }
        }
    }
}
