//
//  PrismFootnoteText.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/07/25.
//

import PrismFoundation
import SwiftUI

/// Texto de nota de rodapé do Design System PrismUI.
///
/// `PrismFootnoteText` é um componente de texto pré-estilizado para conteúdo secundário:
/// - Fonte footnote (menor que body)
/// - Cor de texto secundária automática
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// PrismFootnoteText("Informação adicional ou descrição secundária.")
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismFootnoteText(
///     "Última atualização: hoje",
///     testID: "last_update_label"
/// )
/// ```
///
/// ## Com String Localizada
/// ```swift
/// PrismFootnoteText(PrismUIString.prismPreviewDescription)
/// ```
///
/// - Note: Este componente usa automaticamente `.footnote` font e `.textSecondary` color do tema.
/// - Important: Ideal para legendas, descrições auxiliares e metadados.
public struct PrismFootnoteText: PrismView {
    let content: PrismTextContent?
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ localized: PrismResourceString?,
        _ accessibility: PrismAccessibilityProperties? = nil,
    ) {
        self.content = PrismTextContent(localized?.value)
        self.accessibility = accessibility
    }

    public init(
        _ text: String?,
        _ accessibility: PrismAccessibilityProperties? = nil,
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
        let textView = PrismText(
            content: content,
            accessibility: nil
        )
        .prism(font: .footnote)
        .prism(color: .textSecondary)

        if let accessibility {
            textView.prism(accessibility: accessibility)
        } else {
            textView
        }
    }

    public static func mocked() -> some View {
        PrismFootnoteText(PrismUIString.prismPreviewDescription)
    }
}

#Preview {
    PrismFootnoteText.mocked().prismPadding()
}
