import SwiftUI

/// Themed drag indicator overlay for draggable content.
///
/// ```swift
/// PrismCard { Text("Drag me") }
///     .prismDraggable(item)
/// ```
private struct PrismDraggableModifier<T: Transferable>: ViewModifier {
    @Environment(\.prismTheme) private var theme
    let item: T
    @State private var isDragging = false

    func body(content: Content) -> some View {
        content
            .draggable(item) {
                content
                    .opacity(0.8)
                    .scaleEffect(0.95)
                    .prismElevation(.high)
            }
    }
}

/// Themed drop target with visual indicator.
private struct PrismDropTargetModifier<T: Transferable>: ViewModifier {
    @Environment(\.prismTheme) private var theme
    let type: T.Type
    let action: @Sendable ([T]) -> Bool
    @State private var isTargeted = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if isTargeted {
                    RoundedRectangle(cornerRadius: RadiusToken.md.rawValue)
                        .stroke(theme.color(.interactive), lineWidth: 2)
                        .background(
                            theme.color(.interactive).opacity(0.08),
                            in: RadiusToken.md.shape
                        )
                }
            }
            .dropDestination(for: type) { items, _ in
                action(items)
            } isTargeted: { targeted in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isTargeted = targeted
                }
            }
    }
}

/// Reorderable list with drag handles.
public struct PrismReorderableList<Data: RandomAccessCollection & MutableCollection, ID: Hashable, Content: View>: View
where Data.Index == Int {
    @Environment(\.prismTheme) private var theme

    @Binding private var data: Data
    private let id: KeyPath<Data.Element, ID>
    private let content: (Data.Element) -> Content

    public init(
        _ data: Binding<Data>,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self._data = data
        self.id = id
        self.content = content
    }

    public var body: some View {
        List {
            ForEach(data, id: id) { item in
                content(item)
            }
            .onMove { from, to in
                data.move(fromOffsets: from, toOffset: to)
            }
        }
        .listStyle(.plain)
    }
}

extension PrismReorderableList where Data.Element: Identifiable, ID == Data.Element.ID {

    public init(
        _ data: Binding<Data>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self._data = data
        self.id = \.id
        self.content = content
    }
}

extension View {

    /// Makes view draggable with themed preview.
    public func prismDraggable<T: Transferable>(_ item: T) -> some View {
        modifier(PrismDraggableModifier(item: item))
    }

    /// Makes view a themed drop target.
    public func prismDropTarget<T: Transferable>(
        for type: T.Type,
        action: @Sendable @escaping ([T]) -> Bool
    ) -> some View {
        modifier(PrismDropTargetModifier(type: type, action: action))
    }
}
