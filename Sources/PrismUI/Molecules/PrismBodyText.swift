//
//  PrismBodyText.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/07/25.
//

import PrismFoundation
import SwiftUI

/// Texto de corpo do Design System PrismUI.
///
/// `PrismBodyText` é um componente de texto pré-estilizado para conteúdo de corpo:
/// - Fonte body (tamanho e peso padrão do sistema)
/// - Cor de texto primária automática
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// PrismBodyText("Este é o conteúdo principal do texto.")
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismBodyText(
///     "Descrição do produto",
///     testID: "product_description"
/// )
/// ```
///
/// ## Com String Localizada
/// ```swift
/// PrismBodyText(PrismUIString.prismPreviewDescription)
/// ```
///
/// - Note: Este componente usa automaticamente `.body` font e `.text` color do tema.
/// - Important: Para textos secundários, use `PrismFootnoteText`.
public struct PrismBodyText: PrismView {
    let content: PrismTextContent?
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ localized: PrismResourceString?,
        _ accessibility: PrismAccessibilityProperties? = nil
    ) {
        self.content = PrismTextContent(localized?.value)
        self.accessibility = accessibility
    }

    public init(
        _ text: String?,
        _ accessibility: PrismAccessibilityProperties? = nil
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = accessibility
    }

    public init(
        _ text: LocalizedStringKey,
        testID: String
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = PrismAccessibility.text(text, testID: testID)
    }

    public var body: some View {
        PrismText(
            content: content,
            accessibility: accessibility
        )
        .prism(font: .body)
        .prism(color: .text)
    }

    public static func mocked() -> some View {
        PrismBodyText(PrismUIString.prismPreviewDescription)
    }
}

#Preview {
    PrismBodyText.mocked().prismPadding()
}
