//
//  PrismVStack.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Container vertical de layouts do Design System PrismUI.
///
/// `PrismVStack` é um wrapper do `VStack` nativo com:
/// - Espaçamento semântico via `PrismSpacing`
/// - Suporte a acessibilidade (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
/// - Integração com o sistema de temas Prism
///
/// ## Uso Básico
/// ```swift
/// PrismVStack {
///     PrismText("Título")
///     PrismText("Descrição")
/// }
/// ```
///
/// ## Com Espaçamento Personalizado
/// ```swift
/// PrismVStack(spacing: .large) {
///     PrismText("Título")
///     PrismText("Descrição")
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismVStack(
///     alignment: .leading,
///     spacing: .medium,
///     testID: "login_form"
/// ) {
///     PrismTextField(text: $email, configuration: .email)
///     PrismPrimaryButton("Entrar", testID: "login_button") { }
/// }
/// ```
///
/// ## Alinhamentos Disponíveis
/// - `.leading`, `.center`, `.trailing`
///
/// - Note: O espaçamento usa o sistema de tokens do tema para consistência visual.
public struct PrismVStack: PrismView {
    @Environment(\.theme) private var theme

    let alignment: HorizontalAlignment
    let spacing: PrismSpacing?
    let content: any View

    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        alignment: HorizontalAlignment = .center,
        spacing: PrismSpacing? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public init(
        alignment: HorizontalAlignment = .center,
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
        VStack(
            alignment: alignment,
            spacing: spacing?.rawValue(for: theme.spacing)
        ) {
            AnyView(content)
        }
        .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismVStack(alignment: .leading) {
            PrismBodyText.mocked()
            PrismFootnoteText.mocked()
        }
        .prism(width: .max)
    }
}

#Preview {
    PrismVStack.mocked()
}
