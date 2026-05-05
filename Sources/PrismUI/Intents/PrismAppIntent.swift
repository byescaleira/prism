import SwiftUI

/// Protocol for views that can represent App Intent results in themed UI.
///
/// Conform to this to render App Intent responses with PrismUI components.
///
/// ```swift
/// struct TaskResult: PrismIntentResult {
///     let title: String
///     let isComplete: Bool
///
///     var intentView: some View {
///         PrismRow(LocalizedStringKey(title), icon: isComplete ? "checkmark.circle.fill" : "circle")
///     }
/// }
/// ```
@MainActor
public protocol PrismIntentResult {
    associatedtype IntentView: View
    @ViewBuilder var intentView: IntentView { get }
}

/// Themed snippet view for App Intent results displayed in Shortcuts/Siri.
public struct PrismIntentSnippet<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let content: Content

    /// Creates a snippet view wrapping the given content for App Intent display.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The snippet body with themed padding, surface background, and elevation.
    public var body: some View {
        content
            .padding(SpacingToken.lg.rawValue)
            .background(theme.color(.surface), in: RadiusToken.lg.shape)
            .prismElevation(.low)
    }
}

/// Confirmation dialog view styled for App Intent confirmations.
public struct PrismIntentConfirmation: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let icon: String

    /// Creates a confirmation view with title, optional message, and icon.
    public init(
        _ title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        icon: String = "checkmark.circle.fill"
    ) {
        self.title = title
        self.message = message
        self.icon = icon
    }

    /// The confirmation body with icon, title, and optional message.
    public var body: some View {
        VStack(spacing: SpacingToken.md.rawValue) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(theme.color(.success))
                .symbolRenderingMode(.hierarchical)

            Text(title)
                .font(TypographyToken.headline.font)
                .foregroundStyle(theme.color(.onBackground))

            if let message {
                Text(message)
                    .font(TypographyToken.subheadline.font)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(SpacingToken.xl.rawValue)
    }
}
