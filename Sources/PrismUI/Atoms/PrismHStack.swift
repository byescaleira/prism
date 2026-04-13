//
//  PrismHStack.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Container horizontal de layouts do Design System PrismUI.
///
/// `PrismHStack` é um wrapper do `HStack` nativo com:
/// - Espaçamento semântico via `PrismSpacing`
/// - Suporte a acessibilidade (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
/// - Integração com o sistema de temas Prism
///
/// ## Uso Básico
/// ```swift
/// PrismHStack {
///     PrismSymbol("star")
///     PrismText("Avaliação")
/// }
/// ```
///
/// ## Com Espaçamento Personalizado
/// ```swift
/// PrismHStack(spacing: .small) {
///     PrismAvatar()
///     PrismVStack {
///         PrismText("Nome")
///         PrismText("Cargo")
///     }
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismHStack(
///     alignment: .center,
///     spacing: .medium,
///     testID: "user_info_row"
/// ) {
///     PrismSymbol("person.circle")
///     PrismText("Perfil", testID: "profile_label")
/// }
/// ```
///
/// ## Alinhamentos Disponíveis
/// - `.top`, `.center`, `.bottom`, `.firstTextBaseline`, `.lastTextBaseline`
///
/// - Note: O espaçamento usa o sistema de tokens do tema para consistência visual.
public struct PrismHStack: PrismView {
    @Environment(\.theme) private var theme

    let alignment: VerticalAlignment
    let spacing: PrismSpacing?
    let content: any View

    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        alignment: VerticalAlignment = .center,
        spacing: PrismSpacing? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public init(
        alignment: VerticalAlignment = .center,
        spacing: PrismSpacing? = nil,
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(
            alignment: alignment,
            spacing: spacing?.rawValue(for: theme.spacing)
        ) {
            AnyView(content)
        }
        .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismHStack(
            alignment: .center,
            spacing: .medium
        ) {
            PrismSymbol.mocked()
                .prismPadding()
            PrismVStack.mocked()
        }
    }
}

#Preview {
    PrismHStack.mocked()
}
