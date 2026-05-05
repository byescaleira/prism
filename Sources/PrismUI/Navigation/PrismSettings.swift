import SwiftUI

/// Themed settings/preferences view.
///
/// ```swift
/// PrismSettingsView {
///     PrismSettingsSection("General") {
///         Toggle("Dark Mode", isOn: $darkMode)
///     }
///     PrismSettingsSection("Notifications") {
///         Toggle("Push", isOn: $push)
///     }
/// }
/// ```
public struct PrismSettingsView<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let content: Content

    /// Creates a settings view wrapping the given content in a grouped form.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The content and behavior of the settings view.
    public var body: some View {
        Form {
            content
        }
        .formStyle(.grouped)
        .background(theme.color(.background))
    }
}

/// Themed settings section with header.
public struct PrismSettingsSection<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    private let footer: LocalizedStringKey?
    private let content: Content

    /// Creates a settings section with a title, optional footer, and content.
    public init(
        _ title: LocalizedStringKey,
        footer: LocalizedStringKey? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content()
    }

    /// The content and behavior of the settings section.
    public var body: some View {
        if let footer {
            Section {
                content
            } header: {
                Text(title)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            } footer: {
                Text(footer)
                    .foregroundStyle(theme.color(.onBackgroundTertiary))
            }
        } else {
            Section {
                content
            } header: {
                Text(title)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }
        }
    }
}

extension View {

    /// Opens the system Settings app (iOS) or app preferences (macOS).
    #if os(iOS) || os(visionOS)
        public func prismOpenSettings() -> some View {
            self.environment(
                \.openURL,
                OpenURLAction { url in
                    return .systemAction
                })
        }
    #endif
}
