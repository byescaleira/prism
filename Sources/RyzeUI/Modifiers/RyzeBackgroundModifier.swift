//
//  RyzeBackgroundModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Modificador de background padrão do Design System RyzeUI.
///
/// `RyzeBackgroundModifier` aplica a cor de background do tema:
/// - Usa `theme.color.background` para consistência
/// - Integração automática com light/dark mode
///
/// ## Uso Básico
/// ```swift
/// RyzeVStack {
///     RyzeText("Conteúdo")
/// }
/// .ryzeBackground()
/// ```
///
/// - Note: Use como raíz de telas para garantir background consistente.
public struct RyzeBackgroundModifier: ViewModifier {
    @Environment(\.theme) private var theme

    public func body(content: Content) -> some View {
        content
            .background(theme.color.background)
    }

    static func mocked() -> some View {
        RyzeHStack.mocked()
            .ryze(width: .max, height: .max)
            .ryzePadding()
            .ryzeBackground()
    }
}

#Preview {
    RyzeBackgroundModifier.mocked()
}
