//
//  PrismCarousel.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/02/26.
//

import PrismFoundation
import SwiftUI

/// Horizontal scrolling item carousel for the PrismUI Design System.
///
/// `PrismCarousel` is a horizontal list component with:
/// - Scale and opacity effects on side items
/// - Optional auto-scrolling (configurable via timer)
/// - Selection binding to control the visible item
/// - Semantic spacing via `PrismSpacing`
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// @State var selected: Int?
/// PrismCarousel(
///     items: ["A", "B", "C"],
///     selection: $selected
/// ) { index in
///     PrismText("Item \(index)")
/// }
/// ```
///
/// ## With Auto Scroll
/// ```swift
/// @State var selected: Int?
/// PrismCarousel(
///     items: items,
///     selection: $selected,
///     isAutoScrolling: true  // Scrolls every 5 seconds
/// ) { index in
///     CardView(item: items[index])
/// }
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismCarousel(
///     items: items,
///     testID: "featured_carousel",
///     selection: $selected
/// ) { index in
///     FeaturedCard(item: items[index])
/// }
/// ```
///
/// ## Customization
/// ```swift
/// PrismCarousel(
///     items: items,
///     itemWidth: 200,          // Width of each item
///     spacing: .medium,        // Spacing between items
///     minimumScale: 0.9,       // Minimum scale for side items
///     selection: $selected
/// ) { index in
///     ContentCard(items[index])
/// }
/// ```
///
/// - Note: Auto scroll occurs every 5 seconds using `.bouncy(duration: 1.2)` animation.
/// - Important: The carousel uses `.viewAligned` scroll behavior for precise alignment.
public struct PrismCarousel<Item: Identifiable & Equatable, Content: View>: PrismView {
    @Environment(\.theme) var theme
    @Environment(\.platformContext) private var platformContext
    @Environment(\.analyticsProvider) private var analyticsProvider

    let items: [Item]
    let itemWidth: CGFloat
    let spacing: PrismSpacing
    let minimumScale: CGFloat
    let isAutoScrolling: Bool
    let content: (Int) -> Content

    @Binding var selection: Int?
    public var accessibility: PrismAccessibilityProperties?

    /// The effective item width after platform adjustments.
    ///
    /// On macOS and visionOS with an expansive layout tier, items are scaled up
    /// by 25 % so the carousel fills wider viewports more naturally. When the
    /// caller supplies an explicit `itemWidth` that differs from the default
    /// (160 pt), that value is respected as-is.
    private var resolvedItemWidth: CGFloat {
        let defaultWidth: CGFloat = 160
        guard itemWidth == defaultWidth else { return itemWidth }
        switch platformContext.platform {
        case .macOS, .visionOS:
            return platformContext.layoutTier == .expansive
                ? itemWidth * 1.25
                : itemWidth
        default:
            return itemWidth
        }
    }

    /// Whether auto-scrolling is active for the current platform.
    ///
    /// macOS users typically control scrolling via trackpad or mouse, so
    /// automatic advancement is disabled regardless of the `isAutoScrolling`
    /// flag passed at init time.
    private var resolvedAutoScrolling: Bool {
        platformContext.platform == .macOS ? false : isAutoScrolling
    }

    public enum MockView: View {
        case empty
        public var body: some View {
            PrismText("Carousel Mock")
        }
    }

    public static func mocked() -> MockView {
        .empty
    }

    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var spacingValue: CGFloat {
        spacing.rawValue(for: theme.spacing)
    }

    public init(
        items: [Item],
        _ accessibility: PrismAccessibilityProperties? = nil,
        itemWidth: CGFloat = 160,
        spacing: PrismSpacing = .small,
        minimumScale: CGFloat = 0.85,
        selection: Binding<Int?>,
        isAutoScrolling: Bool = true,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.items = items
        self.accessibility = accessibility
        self.itemWidth = itemWidth
        self.spacing = spacing
        self.minimumScale = minimumScale
        self.isAutoScrolling = isAutoScrolling
        self._selection = selection
        self.content = content
    }

    public init(
        items: [Item],
        testID: String,
        itemWidth: CGFloat = 160,
        spacing: PrismSpacing = .small,
        minimumScale: CGFloat = 0.85,
        selection: Binding<Int?>,
        isAutoScrolling: Bool = true,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.items = items
        self.accessibility = PrismAccessibility.custom(label: "Carousel", testID: testID)
        self.itemWidth = itemWidth
        self.spacing = spacing
        self.minimumScale = minimumScale
        self.isAutoScrolling = isAutoScrolling
        self._selection = selection
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            let width = resolvedItemWidth
            let horizontalInset = (proxy.size.width - width) / 2
            let minimumScaleValue = minimumScale

            ScrollView(.horizontal) {
                HStack(spacing: spacingValue) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, _ in
                        content(index)
                            .frame(width: width)
                            .containerRelativeFrame(.horizontal)
                            .id(index)
                            .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                                let progress = 1 - abs(phase.value)
                                let scale = minimumScaleValue + progress * (1 - minimumScaleValue)
                                let opacity = 0.5 + (0.5 * (1 - abs(phase.value)))

                                return
                                    view
                                    .scaleEffect(scale)
                                    .opacity(opacity)
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, horizontalInset)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selection)
            .padding(.horizontal, -platformContext.contentMargins.horizontal)
            .animation(.bouncy(duration: 1.2), value: items)
            .prism(if: resolvedAutoScrolling) { $0.onReceive(timer) { _ in autoScroll() } }
        }
        .prism(accessibility)
        .onChange(of: selection) { _, newIndex in
            trackScroll(to: newIndex)
        }
    }

    private func trackScroll(to index: Int?) {
        guard let analyticsProvider, let index else { return }
        let testID = (accessibility ?? PrismAccessibility.custom(label: "Carousel", testID: "")).testID
        analyticsProvider.track(.carouselScroll(testID: testID, index: index))
    }

    func autoScroll() {
        guard !items.isEmpty else { return }

        withAnimation(.bouncy(duration: 1.2)) {
            selection = ((selection ?? .zero) + 1) % items.count
        }
    }
}
