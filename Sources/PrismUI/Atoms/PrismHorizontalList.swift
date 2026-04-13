//
//  PrismHorizontalList.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/07/25.
//

import SwiftUI

/// Lista com scroll horizontal do Design System PrismUI.
///
/// `PrismHorizontalList` é uma lista com rolagem horizontal:
/// - Scroll horizontal com `ScrollViewProxy` para navegação programática
/// - Indicadores de scroll ocultos
/// - Binding de posição para controle do item visível
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// PrismHorizontalList { proxy in
///     ForEach(items) { item in
///         PrismBodyText(item.title)
///     }
/// }
/// ```
///
/// ## Com Scroll Programático
/// ```swift
/// PrismHorizontalList { proxy in
///     ForEach(items) { item in
///         PrismBodyText(item.title)
///             .id(item.id)
///     }
/// }
/// // Em outro lugar: proxy.scrollTo(itemId)
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismHorizontalList(testID: "horizontal_list") { proxy in
///     ForEach(items) { item in
///         ItemView(item: item)
///     }
/// }
/// ```
///
/// - Note: Use `ScrollViewProxy` para scroll programático via `scrollTo(_:)`.
public struct PrismHorizontalList: PrismView {
    let content: (ScrollViewProxy) -> any View
    public var accessibility: PrismAccessibilityProperties?

    @State var position: Int?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> some View
    ) {
        self.accessibility = accessibility
        self.content = content
    }

    public init(
        testID: String,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> some View
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self.content = content
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                AnyView(content(proxy))
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $position)
        }
        .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismHorizontalList { _ in
            PrismHStack.mocked()
            PrismHStack.mocked()
        }
    }
}

#Preview {
    PrismHorizontalList.mocked()
}
