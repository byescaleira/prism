import SwiftUI

/// Responsive grid that adapts column count to available width.
public struct PrismGrid<Data: RandomAccessCollection, Content: View>: View
where Data.Element: Identifiable {

    private let data: Data
    private let minItemWidth: CGFloat
    private let spacing: SpacingToken
    private let content: (Data.Element) -> Content

    /// Creates a responsive grid with the given data and minimum item width.
    public init(
        _ data: Data,
        minItemWidth: CGFloat = 280,
        spacing: SpacingToken = .lg,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.minItemWidth = minItemWidth
        self.spacing = spacing
        self.content = content
    }

    /// The content and behavior of the grid.
    public var body: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: minItemWidth),
                    spacing: spacing.rawValue
                )
            ],
            spacing: spacing.rawValue
        ) {
            ForEach(data) { item in
                content(item)
            }
        }
    }
}
