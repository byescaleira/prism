import SwiftUI

/// Toolbar placement presets.
public enum PrismToolbarPlacement: Sendable {
    /// Represents leading toolbar placement.
    case leading
    /// Represents trailing toolbar placement.
    case trailing
    /// Represents principal (center) toolbar placement.
    case principal
    /// Represents primary action toolbar placement.
    case primaryAction
    /// Represents secondary action toolbar placement.
    case secondaryAction
    /// Represents navigation toolbar placement.
    case navigation
    /// Represents status bar toolbar placement.
    case status

    var placement: ToolbarItemPlacement {
        switch self {
        case .leading: .navigation
        case .trailing: .primaryAction
        case .principal: .principal
        case .primaryAction: .primaryAction
        case .secondaryAction: .secondaryAction
        case .navigation: .navigation
        case .status: .status
        }
    }
}

/// Themed toolbar button.
public struct PrismToolbarButton: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    private let icon: String
    private let action: () -> Void

    /// Creates a toolbar button with a title, system image, and action.
    public init(
        _ title: LocalizedStringKey,
        systemImage icon: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    /// The content and behavior of the toolbar button.
    public var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
        }
        .foregroundStyle(theme.color(.interactive))
    }
}

/// Toolbar menu with themed styling.
public struct PrismToolbarMenu<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let icon: String
    private let content: Content

    /// Creates a toolbar menu with a system image icon and menu content.
    public init(
        systemImage icon: String = "ellipsis.circle",
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.content = content()
    }

    /// The content and behavior of the toolbar menu.
    public var body: some View {
        Menu {
            content
        } label: {
            Image(systemName: icon)
                .foregroundStyle(theme.color(.interactive))
        }
    }
}
