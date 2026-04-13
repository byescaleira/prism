//
//  RyzeFootnoteText.swift
//  Ryze
//
//  Created by Rafael Escaleira on 03/07/25.
//

import RyzeFoundation
import SwiftUI

/// Texto de nota de rodapé do Design System RyzeUI.
///
/// `RyzeFootnoteText` é um componente de texto pré-estilizado para conteúdo secundário:
/// - Fonte footnote (menor que body)
/// - Cor de texto secundária automática
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// RyzeFootnoteText("Informação adicional ou descrição secundária.")
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeFootnoteText(
///     "Última atualização: hoje",
///     testID: "last_update_label"
/// )
/// ```
///
/// ## Com String Localizada
/// ```swift
/// RyzeFootnoteText(RyzeUIString.ryzePreviewDescription)
/// ```
///
/// - Note: Este componente usa automaticamente `.footnote` font e `.textSecondary` color do tema.
/// - Important: Ideal para legendas, descrições auxiliares e metadados.
public struct RyzeFootnoteText: RyzeView {
    let content: RyzeTextContent?
    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ localized: RyzeResourceString?,
        _ accessibility: RyzeAccessibilityProperties? = nil,
    ) {
        self.content = RyzeTextContent(localized?.value)
        self.accessibility = accessibility
    }

    public init(
        _ text: String?,
        _ accessibility: RyzeAccessibilityProperties? = nil,
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
        let textView = RyzeText(
            content: content,
            accessibility: nil
        )
        .ryze(font: .footnote)
        .ryze(color: .textSecondary)

        if let accessibility {
            textView.ryze(accessibility: accessibility)
        } else {
            textView
        }
    }

    public static func mocked() -> some View {
        RyzeFootnoteText(RyzeUIString.ryzePreviewDescription)
    }
}

#Preview {
    RyzeFootnoteText.mocked().ryzePadding()
}
