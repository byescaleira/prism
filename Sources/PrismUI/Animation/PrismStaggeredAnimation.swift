import SwiftUI

/// Stagger animation style.
public enum PrismStaggerStyle: Sendable {
    /// Items slide up from below.
    case slideUp
    /// Items slide in from the right.
    case slideLeft
    /// Items fade in without movement.
    case fadeIn
    /// Items scale up from a smaller size.
    case scaleIn
    /// Items slide in from the left.
    case slideRight
}

/// Staggered animation for lists — each item animates in with a delay.
///
/// ```swift
/// PrismStaggeredList(items: items) { item, index in
///     PrismCard { Text(item.name) }
/// }
/// ```
@MainActor
public struct PrismStaggeredList<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let staggerDelay: Double
    let spring: PrismSpringConfig
    let animation: PrismStaggerStyle
    let content: (Item, Int) -> Content

    /// Creates a staggered list with configurable delay, spring, and animation style.
    public init(
        items: [Item],
        staggerDelay: Double = 0.05,
        spring: PrismSpringConfig = .gentle,
        animation: PrismStaggerStyle = .slideUp,
        @ViewBuilder content: @escaping (Item, Int) -> Content
    ) {
        self.items = items
        self.staggerDelay = staggerDelay
        self.spring = spring
        self.animation = animation
        self.content = content
    }

    /// The staggered list body rendering items with delayed entrance animations.
    public var body: some View {
        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            StaggeredItemView(
                index: index,
                delay: staggerDelay,
                spring: spring,
                style: animation
            ) {
                content(item, index)
            }
        }
    }
}

@MainActor
private struct StaggeredItemView<Content: View>: View {
    @State private var isVisible = false

    let index: Int
    let delay: Double
    let spring: PrismSpringConfig
    let style: PrismStaggerStyle
    let content: Content

    init(
        index: Int,
        delay: Double,
        spring: PrismSpringConfig,
        style: PrismStaggerStyle,
        @ViewBuilder content: () -> Content
    ) {
        self.index = index
        self.delay = delay
        self.spring = spring
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(x: xOffset, y: yOffset)
            .scaleEffect(isVisible || style != .scaleIn ? 1 : 0.7)
            .onAppear {
                withAnimation(spring.animation.delay(Double(index) * delay)) {
                    isVisible = true
                }
            }
    }

    private var xOffset: CGFloat {
        guard !isVisible else { return 0 }
        switch style {
        case .slideLeft: return 30
        case .slideRight: return -30
        default: return 0
        }
    }

    private var yOffset: CGFloat {
        guard !isVisible else { return 0 }
        switch style {
        case .slideUp: return 20
        default: return 0
        }
    }
}

/// Modifier to apply staggered entrance to any view.
private struct PrismStaggerModifier: ViewModifier {
    @State private var isVisible = false

    let index: Int
    let delay: Double
    let spring: PrismSpringConfig

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 15)
            .onAppear {
                withAnimation(spring.animation.delay(Double(index) * delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {

    /// Staggers this view's entrance animation based on index.
    public func prismStagger(
        index: Int,
        delay: Double = 0.05,
        spring: PrismSpringConfig = .gentle
    ) -> some View {
        modifier(PrismStaggerModifier(index: index, delay: delay, spring: spring))
    }
}
