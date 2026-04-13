//
//  RyzeLazyList.swift
//  Ryze
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

/// Lista com lazy loading do Design System RyzeUI.
///
/// `RyzeLazyList` é uma lista com carregamento preguiçoso:
/// - Usa `LazyVStack` para performance em listas longas
/// - Scroll vertical automático
/// - Padding automático nas bordas
/// - Espaçamento semântico via `RyzeSpacing`
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// RyzeLazyList {
///     ForEach(items) { item in
///         RyzeBodyText(item.title)
///     }
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeLazyList(testID: "items_list") {
///     ForEach(items) { item in
///         RyzeBodyText(item.title)
///     }
/// }
/// ```
///
/// - Note: Ideal para listas longas onde performance é crítica.
public struct RyzeLazyList: RyzeView {
    @Environment(\.theme) var theme
    let content: any View
    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ accessibility: RyzeAccessibilityProperties? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.content = content()
    }

    public init(
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = RyzeAccessibility.custom(label: "", testID: testID)
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.medium) {
                AnyView(content)
            }
            .ryzePadding()
        }
        .ryze(accessibility)
    }

    public static func mocked() -> some View {
        RyzeLazyList {
            RyzeText.mocked()
            RyzeHStack.mocked()
            RyzeText.mocked()
            RyzeVStack.mocked()
        }
    }
}

#Preview {
    RyzeLazyList.mocked()
}
