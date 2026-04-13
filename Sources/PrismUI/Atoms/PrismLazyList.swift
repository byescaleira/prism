//
//  PrismLazyList.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

/// Lista com lazy loading do Design System PrismUI.
///
/// `PrismLazyList` é uma lista com carregamento preguiçoso:
/// - Usa `LazyVStack` para performance em listas longas
/// - Scroll vertical automático
/// - Padding automático nas bordas
/// - Espaçamento semântico via `PrismSpacing`
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// PrismLazyList {
///     ForEach(items) { item in
///         PrismBodyText(item.title)
///     }
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismLazyList(testID: "items_list") {
///     ForEach(items) { item in
///         PrismBodyText(item.title)
///     }
/// }
/// ```
///
/// - Note: Ideal para listas longas onde performance é crítica.
public struct PrismLazyList: PrismView {
    @Environment(\.theme) var theme
    let content: any View
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.content = content()
    }

    public init(
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.medium) {
                AnyView(content)
            }
            .prismPadding()
        }
        .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismLazyList {
            PrismText.mocked()
            PrismHStack.mocked()
            PrismText.mocked()
            PrismVStack.mocked()
        }
    }
}

#Preview {
    PrismLazyList.mocked()
}
