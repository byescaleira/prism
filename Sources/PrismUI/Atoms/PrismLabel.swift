//
//  PrismLabel.swift
//  Prism
//
//  Created by Rafael Escaleira on 04/07/25.
//

import PrismFoundation
import SwiftUI

/// Label com ícone e texto do Design System PrismUI.
///
/// `PrismLabel` é um wrapper do `Label` nativo com:
/// - Símbolo SF Symbols integrado
/// - Suporte a estado de loading (skeleton automático)
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// PrismLabel("Configurações", symbol: "gear")
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismLabel(
///     "Notificações",
///     testID: "notifications_label",
///     symbol: "bell"
/// )
/// ```
///
/// ## Com Estado de Loading
/// ```swift
/// @State var isLoading = true
/// PrismLabel("Status", symbol: "checkmark")
///     .prism(loading: isLoading)  // Exibe skeleton
/// ```
///
/// ## Com String Localizada
/// ```swift
/// PrismLabel(PrismUIString.prismPreviewTitle, symbol: "star")
/// ```
///
/// - Note: Quando `isLoading` está ativo, o label exibe automaticamente um skeleton.
public struct PrismLabel: PrismView {
    @Environment(\.isLoading) private var isLoading

    let content: PrismTextContent?
    let symbol: String

    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ text: String?,
        _ accessibility: PrismAccessibilityProperties? = nil,
        symbol: String,
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = accessibility
        self.symbol = symbol
    }

    public init(
        _ localized: PrismResourceString?,
        _ accessibility: PrismAccessibilityProperties? = nil,
        symbol: String,
    ) {
        self.content = PrismTextContent(localized?.value)
        self.accessibility = accessibility
        self.symbol = symbol
    }

    public init(
        _ text: LocalizedStringKey,
        testID: String,
        symbol: String,
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = PrismAccessibility.custom(label: text, testID: testID)
        self.symbol = symbol
    }

    private var placeholderText: String {
        .prismPreviewDescription
    }

    public var body: some View {
        if isLoading {
            let loadingView = labelView(content ?? .string(placeholderText))
                .prismSkeleton()

            if let accessibility {
                loadingView.prism(accessibility: accessibility)
            } else {
                loadingView
            }
        } else if let content {
            let label = labelView(content)

            if let accessibility {
                label.prism(accessibility: accessibility)
            } else {
                label
            }
        }
    }

    @ViewBuilder
    private func labelView(_ content: PrismTextContent) -> some View {
        Label {
            content.view()
        } icon: {
            Image(systemName: symbol)
        }
    }

    public static func mocked() -> some View {
        PrismLabel(
            PrismUIString.prismPreviewTitle,
            symbol: "bolt.fill"
        )
    }
}

#Preview {
    PrismLabel.mocked().prismPadding()
}
