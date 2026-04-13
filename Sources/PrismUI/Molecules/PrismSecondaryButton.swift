//
//  PrismSecondaryButton.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/07/25.
//

import PrismFoundation
import SwiftUI

/// Botão secundário do Design System PrismUI.
///
/// `PrismSecondaryButton` é o botão para ações secundárias:
/// - Estilo bordered (borda com fundo semi-transparente)
/// - Cor primária do tema (ou erro para papel destrutivo)
/// - Tamanho grande (.large) com borda em cápsula
/// - Glass effect regular interativo
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// PrismSecondaryButton("Cancelar") {
///     // Ação de cancelamento
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismSecondaryButton(
///     "Voltar",
///     testID: "back_button"
/// ) {
///     // Navegar para tela anterior
/// }
/// ```
///
/// ## Com Papel Destrutivo
/// ```swift
/// PrismSecondaryButton(
///     "Sair sem salvar",
///     role: .destructive
/// ) {
///     // Descartar alterações
/// }
/// ```
///
/// ## Com String Localizada
/// ```swift
/// PrismSecondaryButton(.prismPreviewTitle) {
///     // Ação secundária
/// }
/// ```
///
/// ## Roles Disponíveis
/// - `.none` - Cor primária padrão
/// - `.destructive` - Cor de erro (vermelho)
/// - `.cancel` - Cor primária (para ações de cancelamento)
///
/// - Note: O botão usa automaticamente `.bordered` buttonStyle com `.glassEffect(.regular.interactive())`.
/// - Important: Use para ações secundárias que não são o foco principal da tela.
public struct PrismSecondaryButton: PrismView {
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
                variant: .secondary,
                role: role
            )
        )
    }

    public static func mocked() -> some View {
        PrismSecondaryButton(
            .prismPreviewTitle,
            role: .cancel
        ) {

        }
        .prism(font: .body)
    }
}

#Preview {
    PrismSecondaryButton.mocked().prismPadding()
}
