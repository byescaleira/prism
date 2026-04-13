//
//  RyzeBackgroundRowModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 31/07/25.
//

import SwiftUI

/// Modificador de background para rows do Design System RyzeUI.
///
/// `RyzeBackgroundRowModifier` aplica background adaptativo para rows de lista:
/// - Dark mode: Usa `backgroundSecondary` para contraste
/// - Light mode: Usa `background` padrão
/// - Ideal para rows selecionáveis ou destacáveis
///
/// ## Uso Básico
/// ```swift
/// RyzeHStack {
///     RyzeSymbol("gear")
///     RyzeText("Configurações")
/// }
/// .ryzeBackgroundRow()
/// ```
///
/// - Note: O modifier lê `colorScheme` do ambiente para determinar o background apropriado.
public struct RyzeBackgroundRowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        content
            .ryze(background: colorScheme == .dark ? .backgroundSecondary : .background)
    }

    static func mocked() -> some View {
        RyzeHStack.mocked()
            .ryze(width: .max, height: .max)
            .ryzePadding()
            .ryzeBackgroundRow()
    }
}

#Preview {
    RyzeBackgroundModifier.mocked()
}
