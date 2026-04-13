//
//  RyzeText.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import RyzeFoundation
import SwiftUI

/// Componente de texto do Design System RyzeUI.
///
/// `RyzeText` é o componente fundamental para exibição de texto, com suporte a:
/// - Loading states (skeleton automático)
/// - Acessibilidade (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) através de testIDs estáveis
/// - Internacionalização via `LocalizedStringKey`
///
/// ## Uso Básico
/// ```swift
/// RyzeText("Hello World")
/// ```
///
/// ## Uso com testID
/// ```swift
/// RyzeText("Bem-vindo", testID: "welcome_text")
/// ```
///
/// ## Uso como Header
/// ```swift
/// RyzeText("Título", testID: "main_header", isHeader: true)
/// ```
///
/// ## Loading State
/// ```swift
/// RyzeText("Carregando...")
///     .ryze(loading: true)  // Exibe skeleton
/// ```
///
/// - Note: Quando `isLoading` está ativo, o texto exibe automaticamente um skeleton.
public struct RyzeText: RyzeView {
    @Environment(\.isLoading) private var isLoading

    let content: RyzeTextContent?
    public var accessibility: RyzeAccessibilityProperties?

    // MARK: - Initialization

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
        _ accessibility: RyzeAccessibilityProperties? = nil,
    ) {
        self.content = RyzeTextContent(text)
        self.accessibility = accessibility
    }

    /// Inicialização rápida com builder de acessibilidade
    public init(
        _ text: String?,
        accessibility: (RyzeAccessibilityConfig) -> RyzeAccessibilityConfig
    ) {
        self.content = RyzeTextContent(text)
        self.accessibility = accessibility(RyzeAccessibilityConfig()).build()
    }

    /// Inicialização com conveniência estática
    public init(
        _ text: LocalizedStringKey,
        testID: String,
        isHeader: Bool = false
    ) {
        self.content = RyzeTextContent(text)
        self.accessibility = RyzeAccessibility.text(text, testID: testID, isHeader: isHeader)
    }

    init(
        content: RyzeTextContent?,
        accessibility: RyzeAccessibilityProperties? = nil
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
                        .ryzeSkeleton()
                } else {
                    Text(verbatim: .ryzePreviewDescription)
                        .ryzeSkeleton()
                }
            } else if let content {
                content.view()
            }
        }

        if let accessibility {
            view.ryze(accessibility: accessibility)
        } else {
            view
        }
    }

    // MARK: - Mock

    public static func mocked() -> some View {
        RyzeText(.ryzePreviewDescription)
    }
}

// MARK: - Previews

#Preview("Default") {
    RyzeText.mocked()
        .ryzePadding()
}

#Preview("With Accessibility") {
    RyzeText("Hello World", testID: "hello_text")
        .ryzePadding()
}

#Preview("As Header") {
    RyzeText("Welcome", testID: "welcome_header", isHeader: true)
        .ryzePadding()
}
