//
//  RyzeLabel.swift
//  Ryze
//
//  Created by Rafael Escaleira on 04/07/25.
//

import RyzeFoundation
import SwiftUI

/// Label com ícone e texto do Design System RyzeUI.
///
/// `RyzeLabel` é um wrapper do `Label` nativo com:
/// - Símbolo SF Symbols integrado
/// - Suporte a estado de loading (skeleton automático)
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// RyzeLabel("Configurações", symbol: "gear")
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeLabel(
///     "Notificações",
///     testID: "notifications_label",
///     symbol: "bell"
/// )
/// ```
///
/// ## Com Estado de Loading
/// ```swift
/// @State var isLoading = true
/// RyzeLabel("Status", symbol: "checkmark")
///     .ryze(loading: isLoading)  // Exibe skeleton
/// ```
///
/// ## Com String Localizada
/// ```swift
/// RyzeLabel(RyzeUIString.ryzePreviewTitle, symbol: "star")
/// ```
///
/// - Note: Quando `isLoading` está ativo, o label exibe automaticamente um skeleton.
public struct RyzeLabel: RyzeView {
    @Environment(\.isLoading) private var isLoading

    let content: RyzeTextContent?
    let symbol: String

    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ text: String?,
        _ accessibility: RyzeAccessibilityProperties? = nil,
        symbol: String,
    ) {
        self.content = RyzeTextContent(text)
        self.accessibility = accessibility
        self.symbol = symbol
    }

    public init(
        _ localized: RyzeResourceString?,
        _ accessibility: RyzeAccessibilityProperties? = nil,
        symbol: String,
    ) {
        self.content = RyzeTextContent(localized?.value)
        self.accessibility = accessibility
        self.symbol = symbol
    }

    public init(
        _ text: LocalizedStringKey,
        testID: String,
        symbol: String,
    ) {
        self.content = RyzeTextContent(text)
        self.accessibility = RyzeAccessibility.custom(label: text, testID: testID)
        self.symbol = symbol
    }

    private var placeholderText: String {
        .ryzePreviewDescription
    }

    public var body: some View {
        if isLoading {
            let loadingView = labelView(content ?? .string(placeholderText))
                .ryzeSkeleton()

            if let accessibility {
                loadingView.ryze(accessibility: accessibility)
            } else {
                loadingView
            }
        } else if let content {
            let label = labelView(content)

            if let accessibility {
                label.ryze(accessibility: accessibility)
            } else {
                label
            }
        }
    }

    @ViewBuilder
    private func labelView(_ content: RyzeTextContent) -> some View {
        Label {
            content.view()
        } icon: {
            Image(systemName: symbol)
        }
    }

    public static func mocked() -> some View {
        RyzeLabel(
            RyzeUIString.ryzePreviewTitle,
            symbol: "bolt.fill"
        )
    }
}

#Preview {
    RyzeLabel.mocked().ryzePadding()
}
