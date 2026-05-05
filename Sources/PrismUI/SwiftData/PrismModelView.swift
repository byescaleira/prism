#if canImport(SwiftData)
import SwiftUI
import SwiftData

/// Generic CRUD list for SwiftData persistent models with swipe-to-delete and toolbar add button.
@MainActor
public struct PrismModelView<Model: PersistentModel>: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.modelContext) private var modelContext

    private let title: String
    private let emptyIcon: String
    private let emptyTitle: LocalizedStringKey
    private let emptyMessage: LocalizedStringKey?
    private let sortDescriptors: [SortDescriptor<Model>]
    private let filterPredicate: Predicate<Model>?
    private let rowContent: (Model) -> AnyView
    private let detailContent: ((Model) -> AnyView)?
    private let makeNew: (() -> Model)?

    /// Creates a model view with CRUD scaffolding.
    public init(
        title: String,
        emptyIcon: String = "tray",
        emptyTitle: LocalizedStringKey = "No items",
        emptyMessage: LocalizedStringKey? = nil,
        sortDescriptors: [SortDescriptor<Model>] = [],
        filterPredicate: Predicate<Model>? = nil,
        @ViewBuilder rowContent: @escaping (Model) -> some View,
        makeNew: (() -> Model)? = nil
    ) {
        self.title = title
        self.emptyIcon = emptyIcon
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.sortDescriptors = sortDescriptors
        self.filterPredicate = filterPredicate
        self.rowContent = { AnyView(rowContent($0)) }
        self.detailContent = nil
        self.makeNew = makeNew
    }

    /// Creates a model view with CRUD scaffolding and a detail view.
    public init(
        title: String,
        emptyIcon: String = "tray",
        emptyTitle: LocalizedStringKey = "No items",
        emptyMessage: LocalizedStringKey? = nil,
        sortDescriptors: [SortDescriptor<Model>] = [],
        filterPredicate: Predicate<Model>? = nil,
        @ViewBuilder rowContent: @escaping (Model) -> some View,
        @ViewBuilder detailContent: @escaping (Model) -> some View,
        makeNew: (() -> Model)? = nil
    ) {
        self.title = title
        self.emptyIcon = emptyIcon
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.sortDescriptors = sortDescriptors
        self.filterPredicate = filterPredicate
        self.rowContent = { AnyView(rowContent($0)) }
        self.detailContent = { AnyView(detailContent($0)) }
        self.makeNew = makeNew
    }

    /// The view body.
    public var body: some View {
        PrismModelViewContent(
            title: title,
            emptyIcon: emptyIcon,
            emptyTitle: emptyTitle,
            emptyMessage: emptyMessage,
            sortDescriptors: sortDescriptors,
            filterPredicate: filterPredicate,
            rowContent: rowContent,
            detailContent: detailContent,
            makeNew: makeNew
        )
    }
}

/// Internal content view that owns the @Query for dynamic fetching.
@MainActor
struct PrismModelViewContent<Model: PersistentModel>: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Model]

    let title: String
    let emptyIcon: String
    let emptyTitle: LocalizedStringKey
    let emptyMessage: LocalizedStringKey?
    let sortDescriptors: [SortDescriptor<Model>]
    let filterPredicate: Predicate<Model>?
    let rowContent: (Model) -> AnyView
    let detailContent: ((Model) -> AnyView)?
    let makeNew: (() -> Model)?

    init(
        title: String,
        emptyIcon: String,
        emptyTitle: LocalizedStringKey,
        emptyMessage: LocalizedStringKey?,
        sortDescriptors: [SortDescriptor<Model>],
        filterPredicate: Predicate<Model>?,
        rowContent: @escaping (Model) -> AnyView,
        detailContent: ((Model) -> AnyView)?,
        makeNew: (() -> Model)?
    ) {
        self.title = title
        self.emptyIcon = emptyIcon
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.sortDescriptors = sortDescriptors
        self.filterPredicate = filterPredicate
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.makeNew = makeNew

        if let predicate = filterPredicate {
            _items = Query(filter: predicate, sort: sortDescriptors)
        } else {
            _items = Query(sort: sortDescriptors)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    PrismEmptyState(
                        icon: emptyIcon,
                        title: emptyTitle,
                        message: emptyMessage
                    )
                } else {
                    List {
                        ForEach(items) { item in
                            if let detail = detailContent {
                                NavigationLink {
                                    detail(item)
                                } label: {
                                    rowContent(item)
                                }
                            } else {
                                rowContent(item)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(title)
            .toolbar {
                if let factory = makeNew {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            let newItem = factory()
                            modelContext.insert(newItem)
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add item")
                    }
                }
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

/// Detail view showing model properties via reflection.
@MainActor
public struct PrismModelDetailView<Model: PersistentModel>: View {
    @Environment(\.prismTheme) private var theme

    private let model: Model
    private let title: String

    /// Creates a detail view for a persistent model.
    public init(_ model: Model, title: String = "Details") {
        self.model = model
        self.title = title
    }

    /// The view body.
    public var body: some View {
        Form {
            let mirror = Mirror(reflecting: model)
            ForEach(Array(mirror.children.enumerated()), id: \.offset) { _, child in
                if let label = child.label {
                    LabeledContent {
                        Text(String(describing: child.value))
                    } label: {
                        Text(label.hasPrefix("_") ? String(label.dropFirst()) : label)
                    }
                }
            }
        }
        .navigationTitle(title)
        .scrollContentBackground(.hidden)
        .background(theme.color(.background))
    }
}
#endif
