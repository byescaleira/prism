import SwiftUI

/// Themed list with swipe actions, pull-to-refresh, and empty state.
public struct PrismList<Data: RandomAccessCollection, RowContent: View, EmptyContent: View>: View
where Data.Element: Identifiable {
    @Environment(\.prismTheme) private var theme

    private let data: Data
    private let rowContent: (Data.Element) -> RowContent
    private let emptyContent: EmptyContent

    public init(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder empty: () -> EmptyContent
    ) {
        self.data = data
        self.rowContent = rowContent
        self.emptyContent = empty()
    }

    public var body: some View {
        if data.isEmpty {
            emptyContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(data) { item in
                    rowContent(item)
                        .listRowSeparatorTint(theme.color(.separator))
                }
            }
            .listStyle(.plain)
        }
    }
}

extension PrismList where EmptyContent == PrismLoadingState {

    public init(
        _ data: Data,
        emptyTitle: LocalizedStringKey = "No items",
        emptyIcon: String? = "tray",
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.rowContent = rowContent
        self.emptyContent = PrismLoadingState(.empty(
            title: emptyTitle,
            message: nil,
            icon: emptyIcon
        ))
    }
}
