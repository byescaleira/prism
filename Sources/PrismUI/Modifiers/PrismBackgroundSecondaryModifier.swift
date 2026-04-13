//
//  PrismBackgroundSecondaryModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Modificador de background secundário do Design System PrismUI.
///
/// `PrismBackgroundSecondaryModifier` aplica a cor de background secundária:
/// - Usa `theme.color.backgroundSecondary` para consistência
/// - Ideal para cards, seções destacadas ou superfícies elevadas
/// - Integração automática com light/dark mode
///
/// ## Uso Básico
/// ```swift
/// PrismVStack {
///     PrismText("Conteúdo do card")
/// }
/// .prismBackgroundSecondary()
/// ```
///
/// - Note: O background secundário é tipicamente uma variação mais clara/escura do background principal.
public struct PrismBackgroundSecondaryModifier: ViewModifier {
    @Environment(\.theme) private var theme

    public func body(content: Content) -> some View {
        content
            .background(theme.color.backgroundSecondary)
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prism(width: .max, height: .max)
            .prismPadding()
            .prismBackgroundSecondary()
    }
}

#Preview {
    PrismBackgroundSecondaryModifier.mocked()
}
