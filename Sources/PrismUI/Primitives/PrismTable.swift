import SwiftUI

#if os(macOS)
    /// Themed Table wrapper for macOS with token-based styling.
    ///
    /// ```swift
    /// PrismTable(users) { user in
    ///     Text(user.name)
    /// } columns: {
    ///     TableColumn("Name") { user in Text(user.name) }
    ///     TableColumn("Email") { user in Text(user.email) }
    /// }
    /// ```
    public struct PrismTable<Value: Identifiable, Content: View>: View {
        @Environment(\.prismTheme) private var theme

        private let data: [Value]
        private let content: ([Value]) -> Content

        /// Creates a themed table with data and column content.
        public init(
            _ data: [Value],
            @ViewBuilder content: @escaping ([Value]) -> Content
        ) {
            self.data = data
            self.content = content
        }

        /// The content and behavior of the table.
        public var body: some View {
            content(data)
                .foregroundStyle(theme.color(.onBackground))
                .accessibilityElement(children: .contain)
        }
    }
#endif
