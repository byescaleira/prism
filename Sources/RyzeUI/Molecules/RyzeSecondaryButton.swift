//
//  RyzeSecondaryButton.swift
//  Ryze
//
//  Created by Rafael Escaleira on 02/07/25.
//

import RyzeFoundation
import SwiftUI

/// Botão secundário do Design System RyzeUI.
///
/// `RyzeSecondaryButton` é o botão para ações secundárias:
/// - Estilo bordered (borda com fundo semi-transparente)
/// - Cor primária do tema (ou erro para papel destrutivo)
/// - Tamanho grande (.large) com borda em cápsula
/// - Glass effect regular interativo
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// RyzeSecondaryButton("Cancelar") {
///     // Ação de cancelamento
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeSecondaryButton(
///     "Voltar",
///     testID: "back_button"
/// ) {
///     // Navegar para tela anterior
/// }
/// ```
///
/// ## Com Papel Destrutivo
/// ```swift
/// RyzeSecondaryButton(
///     "Sair sem salvar",
///     role: .destructive
/// ) {
///     // Descartar alterações
/// }
/// ```
///
/// ## Com String Localizada
/// ```swift
/// RyzeSecondaryButton(.ryzePreviewTitle) {
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
public struct RyzeSecondaryButton: RyzeView {
    let content: RyzeTextContent?
    let role: ButtonRole?
    let action: () -> Void

    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ text: String?,
        _ accessibility: RyzeAccessibilityProperties? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.content = RyzeTextContent(text)
        self.accessibility = accessibility
        self.role = role
        self.action = action
    }

    public init(
        _ localized: RyzeResourceString?,
        _ accessibility: RyzeAccessibilityProperties? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.content = RyzeTextContent(localized?.value)
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
        self.content = RyzeTextContent(text)
        self.accessibility = RyzeAccessibility.button(text, testID: testID)
        self.role = role
        self.action = action
    }

    public var body: some View {
        RyzeButton(accessibility, role: role, action: action) {
            RyzeText(content: content)
        }
        .buttonStyle(
            RyzeButtonChromeStyle(
                variant: .secondary,
                role: role
            )
        )
    }

    public static func mocked() -> some View {
        RyzeSecondaryButton(
            .ryzePreviewTitle,
            role: .cancel
        ) {

        }
        .ryze(font: .body)
    }
}

#Preview {
    RyzeSecondaryButton.mocked().ryzePadding()
}
