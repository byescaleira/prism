import SwiftUI

#if os(macOS)
    /// Themed menu bar extra content wrapper.
    ///
    /// Use inside a `MenuBarExtra` scene:
    /// ```swift
    /// MenuBarExtra("App", systemImage: "star") {
    ///     PrismMenuBarContent {
    ///         Button("Preferences...") { showPrefs() }
    ///         Divider()
    ///         Button("Quit") { NSApp.terminate(nil) }
    ///     }
    /// }
    /// ```
    public struct PrismMenuBarContent<Content: View>: View {
        @Environment(\.prismTheme) private var theme

        private let content: Content

        /// Creates a menu bar content wrapper with the given content.
        public init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }

        /// The content and behavior of the menu bar content.
        public var body: some View {
            VStack(spacing: 0) {
                content
            }
            .frame(minWidth: 200)
        }
    }

    /// Themed menu bar button with icon and action.
    public struct PrismMenuBarButton: View {
        @Environment(\.prismTheme) private var theme

        private let title: LocalizedStringKey
        private let icon: String?
        private let action: () -> Void

        /// Creates a menu bar button with a title, optional system image, and action.
        public init(
            _ title: LocalizedStringKey,
            systemImage icon: String? = nil,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.icon = icon
            self.action = action
        }

        /// The content and behavior of the menu bar button.
        public var body: some View {
            Button(action: action) {
                if let icon {
                    Label(title, systemImage: icon)
                } else {
                    Text(title)
                }
            }
            .foregroundStyle(theme.color(.onBackground))
        }
    }
#endif
