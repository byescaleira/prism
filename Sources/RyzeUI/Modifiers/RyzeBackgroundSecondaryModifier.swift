//
//  RyzeBackgroundSecondaryModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Modificador de background secundário do Design System RyzeUI.
///
/// `RyzeBackgroundSecondaryModifier` aplica a cor de background secundária:
/// - Usa `theme.color.backgroundSecondary` para consistência
/// - Ideal para cards, seções destacadas ou superfícies elevadas
/// - Integração automática com light/dark mode
///
/// ## Uso Básico
/// ```swift
/// RyzeVStack {
///     RyzeText("Conteúdo do card")
/// }
/// .ryzeBackgroundSecondary()
/// ```
///
/// - Note: O background secundário é tipicamente uma variação mais clara/escura do background principal.
public struct RyzeBackgroundSecondaryModifier: ViewModifier {
    @Environment(\.theme) private var theme

    public func body(content: Content) -> some View {
        content
            .background(theme.color.backgroundSecondary)
    }

    static func mocked() -> some View {
        RyzeHStack.mocked()
            .ryze(width: .max, height: .max)
            .ryzePadding()
            .ryzeBackgroundSecondary()
    }
}

#Preview {
    RyzeBackgroundSecondaryModifier.mocked()
}
