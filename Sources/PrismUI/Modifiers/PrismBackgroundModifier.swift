//
//  PrismBackgroundModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Modificador de background padrão do Design System PrismUI.
///
/// `PrismBackgroundModifier` aplica a cor de background do tema:
/// - Usa `theme.color.background` para consistência
/// - Integração automática com light/dark mode
///
/// ## Uso Básico
/// ```swift
/// PrismVStack {
///     PrismText("Conteúdo")
/// }
/// .prismBackground()
/// ```
///
/// - Note: Use como raíz de telas para garantir background consistente.
public struct PrismBackgroundModifier: ViewModifier {
    @Environment(\.theme) private var theme

    public func body(content: Content) -> some View {
        content
            .background(theme.color.background)
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prism(width: .max, height: .max)
            .prismPadding()
            .prismBackground()
    }
}

#Preview {
    PrismBackgroundModifier.mocked()
}
