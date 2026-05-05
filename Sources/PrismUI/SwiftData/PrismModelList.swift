import SwiftUI

/// Generic model-aware list that handles empty/loading states.
///
/// Works with any collection (SwiftData @Query results, arrays, etc.)
/// and provides themed empty states and row presentation.
///
/// ```swift
/// @Query var tasks: [Task]
///
/// PrismModelList(
///     tasks,
///     emptyIcon: "checkmark.circle",
///     emptyTitle: "All done!",
///     emptyMessage: "No pending tasks"
/// ) { task in
///     PrismRow(LocalizedStringKey(task.title), icon: "circle")
/// }
/// ```
public struct PrismModelList<Data: RandomAccessCollection, ID: Hashable, RowContent: View>: View {
    @Environment(\.prismTheme) private var theme

    private let data: Data
    private let id: KeyPath<Data.Element, ID>
    private let emptyIcon: String
    private let emptyTitle: LocalizedStringKey
    private let emptyMessage: LocalizedStringKey?
    private let rowContent: (Data.Element) -> RowContent

    /// Creates a model list with an explicit identity key path.
    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        emptyIcon: String = "tray",
        emptyTitle: LocalizedStringKey = "No items",
        emptyMessage: LocalizedStringKey? = nil,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.id = id
        self.emptyIcon = emptyIcon
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.rowContent = rowContent
    }

    /// The view body.
    public var body: some View {
        if data.isEmpty {
            PrismEmptyState(
                icon: emptyIcon,
                title: emptyTitle,
                message: emptyMessage
            )
        } else {
            List {
                ForEach(data, id: id) { item in
                    rowContent(item)
                }
            }
            .listStyle(.plain)
        }
    }
}

extension PrismModelList where Data.Element: Identifiable, ID == Data.Element.ID {

    /// Creates a model list using the element's `Identifiable` conformance.
    public init(
        _ data: Data,
        emptyIcon: String = "tray",
        emptyTitle: LocalizedStringKey = "No items",
        emptyMessage: LocalizedStringKey? = nil,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.id = \.id
        self.emptyIcon = emptyIcon
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.rowContent = rowContent
    }
}

/// Form-style list for model editing with themed sections.
public struct PrismModelForm<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let content: Content

    /// Creates a model form with the given content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The view body.
    public var body: some View {
        Form {
            content
        }
        .scrollContentBackground(.hidden)
        .background(theme.color(.background))
    }
}
