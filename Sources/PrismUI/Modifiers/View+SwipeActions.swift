import SwiftUI

/// Themed swipe actions modifier that wraps SwiftUI's native `.swipeActions`.
private struct PrismSwipeActionsModifier: ViewModifier {
    let leading: [PrismSwipeAction]
    let trailing: [PrismSwipeAction]

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing, allowsFullSwipe: trailing.count == 1) {
                ForEach(Array(trailing.enumerated()), id: \.offset) { _, action in
                    swipeButton(action)
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: leading.count == 1) {
                ForEach(Array(leading.enumerated()), id: \.offset) { _, action in
                    swipeButton(action)
                }
            }
    }

    @ViewBuilder
    private func swipeButton(_ action: PrismSwipeAction) -> some View {
        Button(role: action.role) {
            action.handler()
        } label: {
            if let icon = action.icon {
                Label(action.title, systemImage: icon)
            } else {
                Text(action.title)
            }
        }
        .tint(action.tint)
    }
}

// MARK: - Swipe Action

/// Describes a single swipe action with title, icon, tint, and handler.
public struct PrismSwipeAction: @unchecked Sendable {
    let title: LocalizedStringKey
    let icon: String?
    let tint: Color?
    let role: ButtonRole?
    let handler: () -> Void

    /// Creates a swipe action with a title, optional icon, tint, role, and handler.
    public init(
        _ title: LocalizedStringKey,
        icon: String? = nil,
        tint: Color? = nil,
        role: ButtonRole? = nil,
        handler: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.role = role
        self.handler = handler
    }

    /// Creates a destructive delete swipe action.
    public static func delete(handler: @escaping () -> Void) -> PrismSwipeAction {
        PrismSwipeAction(PrismStrings.delete, icon: "trash", tint: .red, role: .destructive, handler: handler)
    }

    /// Creates an archive swipe action.
    public static func archive(handler: @escaping () -> Void) -> PrismSwipeAction {
        PrismSwipeAction(PrismStrings.archive, icon: "archivebox", tint: .orange, handler: handler)
    }

    /// Creates a pin swipe action.
    public static func pin(handler: @escaping () -> Void) -> PrismSwipeAction {
        PrismSwipeAction(PrismStrings.pin, icon: "pin", tint: .yellow, handler: handler)
    }

    /// Creates a flag swipe action.
    public static func flag(handler: @escaping () -> Void) -> PrismSwipeAction {
        PrismSwipeAction(PrismStrings.flag, icon: "flag", tint: .orange, handler: handler)
    }
}

// MARK: - View Extension

extension View {

    /// Adds themed swipe actions to a list row.
    public func prismSwipeActions(
        leading: [PrismSwipeAction] = [],
        trailing: [PrismSwipeAction] = []
    ) -> some View {
        modifier(PrismSwipeActionsModifier(leading: leading, trailing: trailing))
    }
}
