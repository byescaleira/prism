import SwiftUI

/// Full-page empty state with illustration, title, message, and call-to-action.
public struct PrismEmptyState<Action: View>: View {
    @Environment(\.prismTheme) private var theme

    private let icon: String
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let action: Action

    /// Creates an empty state with icon, title, optional message, and action button.
    public init(
        icon: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        @ViewBuilder action: () -> Action
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = action()
    }

    /// The empty state view body with centered icon, title, and call-to-action.
    public var body: some View {
        VStack(spacing: SpacingToken.xl.rawValue) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(theme.color(.onBackgroundTertiary))
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: SpacingToken.sm.rawValue) {
                Text(title)
                    .font(TypographyToken.title2.font(weight: .semibold))
                    .foregroundStyle(theme.color(.onBackground))
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            action
        }
        .padding(SpacingToken.xxl.rawValue)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }
}

extension PrismEmptyState where Action == EmptyView {

    /// Creates an empty state without an action button.
    public init(
        icon: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = EmptyView()
    }
}

/// System-styled empty state wrapping `ContentUnavailableView`.
///
/// Uses Apple's native `ContentUnavailableView` for system-consistent appearance.
///
/// ```swift
/// PrismContentUnavailable(
///     "No Results",
///     systemImage: "magnifyingglass",
///     description: "Try a different search term"
/// )
/// ```
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct PrismContentUnavailable<Actions: View>: View {
    private let title: LocalizedStringKey
    private let systemImage: String
    private let description: LocalizedStringKey?
    private let actions: Actions

    /// Creates a content unavailable view with title, system image, and optional actions.
    public init(
        _ title: LocalizedStringKey,
        systemImage: String,
        description: LocalizedStringKey? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.actions = actions()
    }

    /// The content unavailable view body using system styling.
    public var body: some View {
        if let description {
            ContentUnavailableView {
                Label(title, systemImage: systemImage)
            } description: {
                Text(description)
            } actions: {
                actions
            }
        } else {
            ContentUnavailableView {
                Label(title, systemImage: systemImage)
            } actions: {
                actions
            }
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension PrismContentUnavailable where Actions == EmptyView {

    /// Creates a content unavailable view without action buttons.
    public init(
        _ title: LocalizedStringKey,
        systemImage: String,
        description: LocalizedStringKey? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.actions = EmptyView()
    }
}

/// Search-specific empty state using system `ContentUnavailableView.search`.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct PrismSearchUnavailable: View {
    private let query: String

    /// Creates a search-specific empty state with an optional query string.
    public init(query: String = "") {
        self.query = query
    }

    /// The search unavailable view body using system search empty state.
    public var body: some View {
        if query.isEmpty {
            ContentUnavailableView.search
        } else {
            ContentUnavailableView.search(text: query)
        }
    }
}
