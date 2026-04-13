//
//  RyzeSpacingModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Modificador de padding semântico do Design System RyzeUI.
///
/// `RyzeSpacingModifier` aplica padding usando tokens semânticos:
/// - Edges configuráveis (`.all`, `.horizontal`, `.vertical`, etc.)
/// - Spacing via `RyzeSpacing` tokens
/// - Integração com `theme.spacing` para consistência
///
/// ## Uso Básico
/// ```swift
/// RyzeText("Conteúdo")
///     .ryzePadding()  // .medium em todos os lados
/// ```
///
/// ## Padding Horizontal
/// ```swift
/// RyzeTextField(text: $text)
///     .ryzePadding(.horizontal, .large)
/// ```
///
/// ## Padding Personalizado
/// ```swift
/// RyzeVStack {
///     RyzeText("Título")
///     RyzeText("Conteúdo")
/// }
/// .ryzePadding(.all, .extraLarge)
/// ```
///
/// ## Tokens Disponíveis
/// - `.zero`, `.small`, `.medium`, `.large`, `.extraLarge`, `.extraExtraLarge`
/// - `.negative(.medium)` - Padding negativo (outdent)
///
/// - Note: Use `.negative()` para criar efeitos de sobreposição ou compensar padding pai.
public struct RyzeSpacingModifier: ViewModifier {
    @Environment(\.theme) private var theme
    private let edges: Edge.Set
    private let spacing: RyzeSpacing

    init(
        edges: Edge.Set,
        spacing: RyzeSpacing
    ) {
        self.edges = edges
        self.spacing = spacing
    }

    public func body(content: Content) -> some View {
        content.padding(
            edges,
            spacing.rawValue(for: theme.spacing)
        )
    }

    static func mocked() -> some View {
        RyzeHStack.mocked()
            .ryzePadding()
    }
}

#Preview {
    RyzeSpacingModifier.mocked()
}
