//
//  RyzeSpacer.swift
//  Ryze
//
//  Created by Rafael Escaleira on 01/08/25.
//

import RyzeFoundation
import SwiftUI

/// Espaçador semântico do Design System RyzeUI.
///
/// `RyzeSpacer` é um wrapper do `Spacer` nativo com:
/// - Comprimento mínimo configurável via `RyzeSpacing`
/// - Integração com o sistema de tokens do tema
/// - Uso consistente de espaçamento em layouts
///
/// ## Uso Básico
/// ```swift
/// RyzeHStack {
///     RyzeText("Título")
///     RyzeSpacer()  // Espaçamento flexível
///     RyzeSymbol("star")
/// }
/// ```
///
/// ## Com Tamanho Personalizado
/// ```swift
/// RyzeVStack {
///     RyzeText("Superior")
///     RyzeSpacer(size: .large)  // Mínimo de 24pt
///     RyzeText("Inferior")
/// }
/// ```
///
/// ## Tamanhos Disponíveis
/// - `.zero` - Sem espaçamento mínimo (padrão)
/// - `.small`, `.medium`, `.large`, `.extraLarge`, etc.
///
/// - Note: O spacer expande para preencher espaço disponível, mas respeita o mínimo definido.
public struct RyzeSpacer: RyzeView {
    @Environment(\.theme) var theme

    let size: RyzeSpacing?

    public init(size: RyzeSpacing? = .zero) {
        self.size = size
    }

    public var body: some View {
        Spacer(minLength: size?.rawValue(for: theme.spacing))
    }

    public static func mocked() -> some View {
        RyzeSpacer()
    }
}

#Preview {
    RyzeSymbol.mocked()
}
