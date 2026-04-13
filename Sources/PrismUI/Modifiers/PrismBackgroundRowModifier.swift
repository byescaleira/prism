//
//  PrismBackgroundRowModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 31/07/25.
//

import SwiftUI

/// Modificador de background para rows do Design System PrismUI.
///
/// `PrismBackgroundRowModifier` aplica background adaptativo para rows de lista:
/// - Dark mode: Usa `backgroundSecondary` para contraste
/// - Light mode: Usa `background` padrão
/// - Ideal para rows selecionáveis ou destacáveis
///
/// ## Uso Básico
/// ```swift
/// PrismHStack {
///     PrismSymbol("gear")
///     PrismText("Configurações")
/// }
/// .prismBackgroundRow()
/// ```
///
/// - Note: O modifier lê `colorScheme` do ambiente para determinar o background apropriado.
public struct PrismBackgroundRowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        content
            .prism(background: colorScheme == .dark ? .backgroundSecondary : .background)
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prism(width: .max, height: .max)
            .prismPadding()
            .prismBackgroundRow()
    }
}

#Preview {
    PrismBackgroundModifier.mocked()
}
