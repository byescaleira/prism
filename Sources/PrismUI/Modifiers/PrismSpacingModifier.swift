//
//  PrismSpacingModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Modificador de padding semântico do Design System PrismUI.
///
/// `PrismSpacingModifier` aplica padding usando tokens semânticos:
/// - Edges configuráveis (`.all`, `.horizontal`, `.vertical`, etc.)
/// - Spacing via `PrismSpacing` tokens
/// - Integração com `theme.spacing` para consistência
///
/// ## Uso Básico
/// ```swift
/// PrismText("Conteúdo")
///     .prismPadding()  // .medium em todos os lados
/// ```
///
/// ## Padding Horizontal
/// ```swift
/// PrismTextField(text: $text)
///     .prismPadding(.horizontal, .large)
/// ```
///
/// ## Padding Personalizado
/// ```swift
/// PrismVStack {
///     PrismText("Título")
///     PrismText("Conteúdo")
/// }
/// .prismPadding(.all, .extraLarge)
/// ```
///
/// ## Tokens Disponíveis
/// - `.zero`, `.small`, `.medium`, `.large`, `.extraLarge`, `.extraExtraLarge`
/// - `.negative(.medium)` - Padding negativo (outdent)
///
/// - Note: Use `.negative()` para criar efeitos de sobreposição ou compensar padding pai.
public struct PrismSpacingModifier: ViewModifier {
    @Environment(\.theme) private var theme
    private let edges: Edge.Set
    private let spacing: PrismSpacing

    init(
        edges: Edge.Set,
        spacing: PrismSpacing
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
        PrismHStack.mocked()
            .prismPadding()
    }
}

#Preview {
    PrismSpacingModifier.mocked()
}
