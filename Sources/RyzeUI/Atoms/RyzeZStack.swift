//
//  RyzeZStack.swift
//  Ryze
//
//  Created by Rafael Escaleira on 08/06/25.
//

import SwiftUI

/// Container em camadas (z-axis) do Design System RyzeUI.
///
/// `RyzeZStack` é um wrapper do `ZStack` nativo com:
/// - Empilhamento de views em profundidade (eixo Z)
/// - Alinhamento configurável
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
///
/// ## Uso Básico
/// ```swift
/// RyzeZStack {
///     RyzeShape(.rectangle)
///         .ryze(background: .secondary)
///     RyzeText("Overlay")
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeZStack(
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
public struct RyzeZStack: RyzeView {
    let alignment: Alignment
    let content: any View

    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ accessibility: RyzeAccessibilityProperties? = nil,
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
        self.accessibility = RyzeAccessibility.custom(label: "", testID: testID)
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: alignment) {
            AnyView(content)
        }
        .ryze(accessibility)
    }

    public static func mocked() -> some View {
        RyzeZStack {
            RyzeSymbol.mocked()
        }
    }
}

#Preview {
    RyzeZStack.mocked()
}
