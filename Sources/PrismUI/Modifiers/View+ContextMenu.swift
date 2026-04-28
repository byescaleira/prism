import SwiftUI

extension View {

    /// Attaches a themed context menu with a preview.
    public func prismContextMenu<MenuContent: View, Preview: View>(
        @ViewBuilder menu: @escaping () -> MenuContent,
        @ViewBuilder preview: @escaping () -> Preview
    ) -> some View {
        contextMenu(menuItems: menu, preview: preview)
    }

    /// Attaches a themed context menu without a preview.
    public func prismContextMenu<MenuContent: View>(
        @ViewBuilder menu: @escaping () -> MenuContent
    ) -> some View {
        contextMenu(menuItems: menu)
    }
}
