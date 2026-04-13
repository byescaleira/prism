//
//  PrismCarousel.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/02/26.
//

import SwiftUI

/// Carrossel de itens com scroll horizontal do Design System PrismUI.
///
/// `PrismCarousel` é um componente de lista horizontal com:
/// - Efeito de escala e opacidade nos itens laterais
/// - Scroll automático opcional (configurável via timer)
/// - Binding de seleção para controle do item visível
/// - Espaçamento semântico via `PrismSpacing`
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
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
/// ## Com Auto Scroll
/// ```swift
/// @State var selected: Int?
/// PrismCarousel(
///     items: items,
///     selection: $selected,
///     isAutoScrolling: true  // Scroll a cada 5 segundos
/// ) { index in
///     CardView(item: items[index])
/// }
/// ```
///
/// ## Com testID para Testes
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
/// ## Personalização
/// ```swift
/// PrismCarousel(
///     items: items,
///     itemWidth: 200,          // Largura de cada item
///     spacing: .medium,        // Espaçamento entre itens
///     minimumScale: 0.9,       // Escala mínima dos itens laterais
///     selection: $selected
/// ) { index in
///     ContentCard(items[index])
/// }
/// ```
///
/// - Note: O auto scroll ocorre a cada 5 segundos e usa animação `.bouncy(duration: 1.2)`.
/// - Important: O carousel usa `.viewAligned` scroll behavior para alinhamento preciso.
public struct PrismCarousel<Item: Identifiable & Equatable, Content: View>: PrismView {
    @Environment(\.theme) var theme

    let items: [Item]
    let itemWidth: CGFloat
    let spacing: PrismSpacing
    let minimumScale: CGFloat
    let isAutoScrolling: Bool
    let content: (Int) -> Content

    @Binding var selection: Int?
    public var accessibility: PrismAccessibilityProperties?

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
            let horizontalInset = (proxy.size.width / 2) - (itemWidth / 2.5) + spacingValue
            let minimumScaleValue = minimumScale

            ScrollView(.horizontal) {
                HStack(spacing: spacingValue) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, _ in
                        content(index)
                            .frame(width: itemWidth)
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
            .padding(.horizontal, -40)
            .animation(.bouncy(duration: 1.2), value: items)
            .prism(if: isAutoScrolling) { $0.onReceive(timer) { _ in autoScroll() } }
        }
        .prism(accessibility)
    }

    func autoScroll() {
        guard !items.isEmpty else { return }

        withAnimation(.bouncy(duration: 1.2)) {
            selection = ((selection ?? .zero) + 1) % items.count
        }
    }
}
