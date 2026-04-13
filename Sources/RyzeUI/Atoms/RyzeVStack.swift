//
//  RyzeVStack.swift
//  Ryze
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Container vertical de layouts do Design System RyzeUI.
///
/// `RyzeVStack` é um wrapper do `VStack` nativo com:
/// - Espaçamento semântico via `RyzeSpacing`
/// - Suporte a acessibilidade (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
/// - Integração com o sistema de temas Ryze
///
/// ## Uso Básico
/// ```swift
/// RyzeVStack {
///     RyzeText("Título")
///     RyzeText("Descrição")
/// }
/// ```
///
/// ## Com Espaçamento Personalizado
/// ```swift
/// RyzeVStack(spacing: .large) {
///     RyzeText("Título")
///     RyzeText("Descrição")
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeVStack(
///     alignment: .leading,
///     spacing: .medium,
///     testID: "login_form"
/// ) {
///     RyzeTextField(text: $email, configuration: .email)
///     RyzePrimaryButton("Entrar", testID: "login_button") { }
/// }
/// ```
///
/// ## Alinhamentos Disponíveis
/// - `.leading`, `.center`, `.trailing`
///
/// - Note: O espaçamento usa o sistema de tokens do tema para consistência visual.
public struct RyzeVStack: RyzeView {
    @Environment(\.theme) private var theme

    let alignment: HorizontalAlignment
    let spacing: RyzeSpacing?
    let content: any View

    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ accessibility: RyzeAccessibilityProperties? = nil,
        alignment: HorizontalAlignment = .center,
        spacing: RyzeSpacing? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: RyzeSpacing? = nil,
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = RyzeAccessibility.custom(label: "", testID: testID)
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
        .ryze(accessibility)
    }

    public static func mocked() -> some View {
        RyzeVStack(alignment: .leading) {
            RyzeBodyText.mocked()
            RyzeFootnoteText.mocked()
        }
        .ryze(width: .max)
    }
}

#Preview {
    RyzeVStack.mocked()
}
