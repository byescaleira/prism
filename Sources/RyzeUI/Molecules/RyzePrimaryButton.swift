//
//  RyzePrimaryButton.swift
//  Ryze
//
//  Created by Rafael Escaleira on 29/06/25.
//

import RyzeFoundation
import SwiftUI

/// Botão primário do Design System RyzeUI.
///
/// `RyzePrimaryButton` é o botão de destaque para ações principais:
/// - Estilo glassProminent (efeito de vidro com profundidade)
/// - Cor primária do tema (ou erro para papel destrutivo)
/// - Tamanho grande (.large) com borda em cápsula
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// RyzePrimaryButton("Entrar") {
///     // Ação de login
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzePrimaryButton(
///     "Confirmar compra",
///     testID: "confirm_purchase_button"
/// ) {
///     // Processar compra
/// }
/// ```
///
/// ## Com Papel Destrutivo
/// ```swift
/// RyzePrimaryButton(
///     "Excluir conta",
///     role: .destructive
/// ) {
///     // Excluir conta do usuário
/// }
/// ```
///
/// ## Com String Localizada
/// ```swift
/// RyzePrimaryButton(.ryzePreviewTitle) {
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
public struct RyzePrimaryButton: RyzeView {
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
                variant: .primary,
                role: role
            )
        )
    }

    public static func mocked() -> some View {
        RyzePrimaryButton(
            .ryzePreviewTitle,
            role: .cancel
        ) {
        }
        .ryze(font: .body)
    }
}

#Preview {
    RyzePrimaryButton.mocked().ryzePadding()
}
