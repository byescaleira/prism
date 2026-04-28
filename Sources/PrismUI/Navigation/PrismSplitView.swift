import SwiftUI

/// Themed master-detail navigation with NavigationSplitView.
///
/// Provides two-column (sidebar + detail) and three-column layouts
/// following Apple HIG split view patterns.
///
/// ```swift
/// PrismSplitView {
///     List(items) { item in
///         NavigationLink(value: item) { Text(item.name) }
///     }
/// } detail: {
///     Text("Select an item")
/// }
/// ```
public struct PrismSplitView<Sidebar: View, Detail: View>: View {
    @Environment(\.prismTheme) private var theme

    private let columnVisibility: NavigationSplitViewVisibility?
    private let sidebar: Sidebar
    private let detail: Detail

    public init(
        columnVisibility: NavigationSplitViewVisibility? = nil,
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder detail: () -> Detail
    ) {
        self.columnVisibility = columnVisibility
        self.sidebar = sidebar()
        self.detail = detail()
    }

    public var body: some View {
        if let columnVisibility {
            NavigationSplitView(columnVisibility: .constant(columnVisibility)) {
                sidebar
            } detail: {
                detail
            }
        } else {
            NavigationSplitView {
                sidebar
            } detail: {
                detail
            }
        }
    }
}

/// Three-column split view (sidebar, content, detail).
public struct PrismThreeColumnView<Sidebar: View, Content: View, Detail: View>: View {
    private let sidebar: Sidebar
    private let content: Content
    private let detail: Detail

    public init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> Content,
        @ViewBuilder detail: () -> Detail
    ) {
        self.sidebar = sidebar()
        self.content = content()
        self.detail = detail()
    }

    public var body: some View {
        NavigationSplitView {
            sidebar
        } content: {
            content
        } detail: {
            detail
        }
    }
}
