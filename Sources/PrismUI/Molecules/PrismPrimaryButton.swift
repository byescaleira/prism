//
//  PrismPrimaryButton.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/06/25.
//

import PrismFoundation
import SwiftUI

/// Botão primário do Design System PrismUI.
///
/// `PrismPrimaryButton` é o botão de destaque para ações principais:
/// - Estilo glassProminent (efeito de vidro com profundidade)
/// - Cor primária do tema (ou erro para papel destrutivo)
/// - Tamanho grande (.large) com borda em cápsula
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// PrismPrimaryButton("Entrar") {
///     // Ação de login
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismPrimaryButton(
///     "Confirmar compra",
///     testID: "confirm_purchase_button"
/// ) {
///     // Processar compra
/// }
/// ```
///
/// ## Com Papel Destrutivo
/// ```swift
/// PrismPrimaryButton(
///     "Excluir conta",
///     role: .destructive
/// ) {
///     // Excluir conta do usuário
/// }
/// ```
///
/// ## Com String Localizada
/// ```swift
/// PrismPrimaryButton(.prismPreviewTitle) {
///     // Ação
/// }
/// ```
///
/// ## Roles Disponíveis
/// - `.none` - Cor primária padrão
/// - `.destructive` - Cor de erro (vermelho)
/// - `.cancel` - Cor primária (para ações de cancelamento)
///
/// - Note: O botão usa automaticamente `.glassProminent` buttonStyle e `.capsule` borderShape.
/// - Important: Use para a ação principal em telas (CTA - Call to Action).
public struct PrismPrimaryButton: PrismView {
    let content: PrismTextContent?
    let role: ButtonRole?
    let action: () -> Void

    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ text: String?,
        _ accessibility: PrismAccessibilityProperties? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = accessibility
        self.role = role
        self.action = action
    }

    public init(
        _ localized: PrismResourceString?,
        _ accessibility: PrismAccessibilityProperties? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.content = PrismTextContent(localized?.value)
        self.accessibility = accessibility
        self.role = role
        self.action = action
    }

    public init(
        _ text: LocalizedStringKey,
        testID: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = PrismAccessibility.button(text, testID: testID)
        self.role = role
        self.action = action
    }

    public var body: some View {
        PrismButton(accessibility, role: role, action: action) {
            PrismText(content: content)
        }
        .buttonStyle(
            PrismButtonChromeStyle(
                variant: .primary,
                role: role
            )
        )
    }

    public static func mocked() -> some View {
        PrismPrimaryButton(
            .prismPreviewTitle,
            role: .cancel
        ) {
        }
        .prism(font: .body)
    }
}

#Preview {
    PrismPrimaryButton.mocked().prismPadding()
}
