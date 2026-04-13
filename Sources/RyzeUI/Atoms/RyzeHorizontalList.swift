//
//  RyzeHorizontalList.swift
//  Ryze
//
//  Created by Rafael Escaleira on 29/07/25.
//

import SwiftUI

/// Lista com scroll horizontal do Design System RyzeUI.
///
/// `RyzeHorizontalList` é uma lista com rolagem horizontal:
/// - Scroll horizontal com `ScrollViewProxy` para navegação programática
/// - Indicadores de scroll ocultos
/// - Binding de posição para controle do item visível
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// RyzeHorizontalList { proxy in
///     ForEach(items) { item in
///         RyzeBodyText(item.title)
///     }
/// }
/// ```
///
/// ## Com Scroll Programático
/// ```swift
/// RyzeHorizontalList { proxy in
///     ForEach(items) { item in
///         RyzeBodyText(item.title)
///             .id(item.id)
///     }
/// }
/// // Em outro lugar: proxy.scrollTo(itemId)
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeHorizontalList(testID: "horizontal_list") { proxy in
///     ForEach(items) { item in
///         ItemView(item: item)
///     }
/// }
/// ```
///
/// - Note: Use `ScrollViewProxy` para scroll programático via `scrollTo(_:)`.
public struct RyzeHorizontalList: RyzeView {
    let content: (ScrollViewProxy) -> any View
    public var accessibility: RyzeAccessibilityProperties?

    @State var position: Int?

    public init(
        _ accessibility: RyzeAccessibilityProperties? = nil,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> some View
    ) {
        self.accessibility = accessibility
        self.content = content
    }

    public init(
        testID: String,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> some View
    ) {
        self.accessibility = RyzeAccessibility.custom(label: "", testID: testID)
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
        .ryze(accessibility)
    }

    public static func mocked() -> some View {
        RyzeHorizontalList { _ in
            RyzeHStack.mocked()
            RyzeHStack.mocked()
        }
    }
}

#Preview {
    RyzeHorizontalList.mocked()
}
