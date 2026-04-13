//
//  RyzeBodyText.swift
//  Ryze
//
//  Created by Rafael Escaleira on 03/07/25.
//

import RyzeFoundation
import SwiftUI

/// Texto de corpo do Design System RyzeUI.
///
/// `RyzeBodyText` é um componente de texto pré-estilizado para conteúdo de corpo:
/// - Fonte body (tamanho e peso padrão do sistema)
/// - Cor de texto primária automática
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// RyzeBodyText("Este é o conteúdo principal do texto.")
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeBodyText(
///     "Descrição do produto",
///     testID: "product_description"
/// )
/// ```
///
/// ## Com String Localizada
/// ```swift
/// RyzeBodyText(RyzeUIString.ryzePreviewDescription)
/// ```
///
/// - Note: Este componente usa automaticamente `.body` font e `.text` color do tema.
/// - Important: Para textos secundários, use `RyzeFootnoteText`.
public struct RyzeBodyText: RyzeView {
    let content: RyzeTextContent?
    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ localized: RyzeResourceString?,
        _ accessibility: RyzeAccessibilityProperties? = nil
    ) {
        self.content = RyzeTextContent(localized?.value)
        self.accessibility = accessibility
    }

    public init(
        _ text: String?,
        _ accessibility: RyzeAccessibilityProperties? = nil
    ) {
        self.content = RyzeTextContent(text)
        self.accessibility = accessibility
    }

    public init(
        _ text: LocalizedStringKey,
        testID: String
    ) {
        self.content = RyzeTextContent(text)
        self.accessibility = RyzeAccessibility.text(text, testID: testID)
    }

    public var body: some View {
        RyzeText(
            content: content,
            accessibility: accessibility
        )
        .ryze(font: .body)
        .ryze(color: .text)
    }

    public static func mocked() -> some View {
        RyzeBodyText(RyzeUIString.ryzePreviewDescription)
    }
}

#Preview {
    RyzeBodyText.mocked().ryzePadding()
}
