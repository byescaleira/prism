//
//  PrismZStack.swift
//  Prism
//
//  Created by Rafael Escaleira on 08/06/25.
//

import SwiftUI

/// Container em camadas (z-axis) do Design System PrismUI.
///
/// `PrismZStack` é um wrapper do `ZStack` nativo com:
/// - Empilhamento de views em profundidade (eixo Z)
/// - Alinhamento configurável
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// PrismZStack {
///     PrismShape(.rectangle)
///         .prism(background: .secondary)
///     PrismText("Overlay")
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismZStack(
///     alignment: .topLeading,
///     testID: "card_overlay"
/// ) {
///     BackgroundImage()
///     OverlayContent()
/// }
/// ```
///
/// ## Alinhamentos Disponíveis
/// - `.topLeading`, `.top`, `.topTrailing`
/// - `.leading`, `.center`, `.trailing`
/// - `.bottomLeading`, `.bottom`, `.bottomTrailing`
///
/// - Note: Views são empilhadas na ordem declarada (primeira view no fundo).
public struct PrismZStack: PrismView {
    let alignment: Alignment
    let content: any View

    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.alignment = alignment
        self.content = content()
    }

    public init(
        alignment: Alignment = .center,
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: alignment) {
            AnyView(content)
        }
        .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismZStack {
            PrismSymbol.mocked()
        }
    }
}

#Preview {
    PrismZStack.mocked()
}
