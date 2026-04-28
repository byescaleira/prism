import SwiftUI

/// Paged horizontal carousel with optional page indicators.
public struct PrismCarousel<Data: RandomAccessCollection, Content: View>: View
where Data.Element: Identifiable {
    private let data: Data
    private let spacing: SpacingToken
    private let showIndicators: Bool
    private let content: (Data.Element) -> Content

    @State private var currentIndex = 0

    public init(
        _ data: Data,
        spacing: SpacingToken = .md,
        showIndicators: Bool = true,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.showIndicators = showIndicators
        self.content = content
    }

    public var body: some View {
        VStack(spacing: SpacingToken.sm.rawValue) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: spacing.rawValue) {
                    ForEach(data) { item in
                        content(item)
                            .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)

            if showIndicators && data.count > 1 {
                pageIndicators
            }
        }
    }

    private var pageIndicators: some View {
        HStack(spacing: SpacingToken.xs.rawValue) {
            ForEach(0..<min(data.count, 10), id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
        .accessibilityHidden(true)
    }
}
