//
//  PrismText.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import PrismFoundation
import SwiftUI

/// Componente de texto do Design System PrismUI.
///
/// `PrismText` é o componente fundamental para exibição de texto, com suporte a:
/// - Loading states (skeleton automático)
/// - Acessibilidade (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) através de testIDs estáveis
/// - Internacionalização via `LocalizedStringKey`
///
/// ## Uso Básico
/// ```swift
/// PrismText("Hello World")
/// ```
///
/// ## Uso com testID
/// ```swift
/// PrismText("Bem-vindo", testID: "welcome_text")
/// ```
///
/// ## Uso como Header
/// ```swift
/// PrismText("Título", testID: "main_header", isHeader: true)
/// ```
///
/// ## Loading State
/// ```swift
/// PrismText("Carregando...")
///     .prism(loading: true)  // Exibe skeleton
/// ```
///
/// - Note: Quando `isLoading` está ativo, o texto exibe automaticamente um skeleton.
public struct PrismText: PrismView {
    @Environment(\.isLoading) private var isLoading

    let content: PrismTextContent?
    public var accessibility: PrismAccessibilityProperties?

    // MARK: - Initialization

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
        _ accessibility: PrismAccessibilityProperties? = nil,
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = accessibility
    }

    /// Inicialização rápida com builder de acessibilidade
    public init(
        _ text: String?,
        accessibility: (PrismAccessibilityConfig) -> PrismAccessibilityConfig
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = accessibility(PrismAccessibilityConfig()).build()
    }

    /// Inicialização com conveniência estática
    public init(
        _ text: LocalizedStringKey,
        testID: String,
        isHeader: Bool = false
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = PrismAccessibility.text(text, testID: testID, isHeader: isHeader)
    }

    init(
        content: PrismTextContent?,
        accessibility: PrismAccessibilityProperties? = nil
    ) {
        self.content = content
        self.accessibility = accessibility
    }

    // MARK: - Body

    @ViewBuilder
    public var body: some View {
        let view = Group {
            if isLoading {
                if let content {
                    content.view()
                        .prismSkeleton()
                } else {
                    Text(verbatim: .prismPreviewDescription)
                        .prismSkeleton()
                }
            } else if let content {
                content.view()
            }
        }

        if let accessibility {
            view.prism(accessibility: accessibility)
        } else {
            view
        }
    }

    // MARK: - Mock

    public static func mocked() -> some View {
        PrismText(.prismPreviewDescription)
    }
}

// MARK: - Previews

#Preview("Default") {
    PrismText.mocked()
        .prismPadding()
}

#Preview("With Accessibility") {
    PrismText("Hello World", testID: "hello_text")
        .prismPadding()
}

#Preview("As Header") {
    PrismText("Welcome", testID: "welcome_header", isHeader: true)
        .prismPadding()
}
