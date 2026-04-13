//
//  RyzeHStack.swift
//  Ryze
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Container horizontal de layouts do Design System RyzeUI.
///
/// `RyzeHStack` é um wrapper do `HStack` nativo com:
/// - Espaçamento semântico via `RyzeSpacing`
/// - Suporte a acessibilidade (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
/// - Integração com o sistema de temas Ryze
///
/// ## Uso Básico
/// ```swift
/// RyzeHStack {
///     RyzeSymbol("star")
///     RyzeText("Avaliação")
/// }
/// ```
///
/// ## Com Espaçamento Personalizado
/// ```swift
/// RyzeHStack(spacing: .small) {
///     RyzeAvatar()
///     RyzeVStack {
///         RyzeText("Nome")
///         RyzeText("Cargo")
///     }
/// }
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeHStack(
///     alignment: .center,
///     spacing: .medium,
///     testID: "user_info_row"
/// ) {
///     RyzeSymbol("person.circle")
///     RyzeText("Perfil", testID: "profile_label")
/// }
/// ```
///
/// ## Alinhamentos Disponíveis
/// - `.top`, `.center`, `.bottom`, `.firstTextBaseline`, `.lastTextBaseline`
///
/// - Note: O espaçamento usa o sistema de tokens do tema para consistência visual.
public struct RyzeHStack: RyzeView {
    @Environment(\.theme) private var theme

    let alignment: VerticalAlignment
    let spacing: RyzeSpacing?
    let content: any View

    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ accessibility: RyzeAccessibilityProperties? = nil,
        alignment: VerticalAlignment = .center,
        spacing: RyzeSpacing? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public init(
        alignment: VerticalAlignment = .center,
        spacing: RyzeSpacing? = nil,
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = RyzeAccessibility.custom(label: "", testID: testID)
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(
            alignment: alignment,
            spacing: spacing?.rawValue(for: theme.spacing)
        ) {
            AnyView(content)
        }
        .ryze(accessibility)
    }

    public static func mocked() -> some View {
        RyzeHStack(
            alignment: .center,
            spacing: .medium
        ) {
            RyzeSymbol.mocked()
                .ryzePadding()
            RyzeVStack.mocked()
        }
    }
}

#Preview {
    RyzeHStack.mocked()
}
