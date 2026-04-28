import SwiftUI

/// Themed tab view with SF Symbol icons and badge support.
public struct PrismTabView<Selection: Hashable, Content: View>: View {
    @Binding private var selection: Selection
    private let content: Content

    public init(
        selection: Binding<Selection>,
        @ViewBuilder content: () -> Content
    ) {
        self._selection = selection
        self.content = content()
    }

    public var body: some View {
        TabView(selection: $selection) {
            content
        }
    }
}

// MARK: - Tab Item Modifier

extension View {

    /// Configures a tab item with icon and title.
    public func prismTab<V: Hashable>(
        _ title: LocalizedStringKey,
        icon: String,
        tag: V,
        badge: Int? = nil
    ) -> some View {
        self
            .tag(tag)
            .tabItem {
                Label(title, systemImage: icon)
            }
            .badge(badge ?? 0)
    }
}
