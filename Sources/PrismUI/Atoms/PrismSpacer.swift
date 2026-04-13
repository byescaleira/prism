//
//  PrismSpacer.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/08/25.
//

import PrismFoundation
import SwiftUI

/// Espaçador semântico do Design System PrismUI.
///
/// `PrismSpacer` é um wrapper do `Spacer` nativo com:
/// - Comprimento mínimo configurável via `PrismSpacing`
/// - Integração com o sistema de tokens do tema
/// - Uso consistente de espaçamento em layouts
///
/// ## Uso Básico
/// ```swift
/// PrismHStack {
///     PrismText("Título")
///     PrismSpacer()  // Espaçamento flexível
///     PrismSymbol("star")
/// }
/// ```
///
/// ## Com Tamanho Personalizado
/// ```swift
/// PrismVStack {
///     PrismText("Superior")
///     PrismSpacer(size: .large)  // Mínimo de 24pt
///     PrismText("Inferior")
/// }
/// ```
///
/// ## Tamanhos Disponíveis
/// - `.zero` - Sem espaçamento mínimo (padrão)
/// - `.small`, `.medium`, `.large`, `.extraLarge`, etc.
///
/// - Note: O spacer expande para preencher espaço disponível, mas respeita o mínimo definido.
public struct PrismSpacer: PrismView {
    @Environment(\.theme) var theme

    let size: PrismSpacing?

    public init(size: PrismSpacing? = .zero) {
        self.size = size
    }

    public var body: some View {
        Spacer(minLength: size?.rawValue(for: theme.spacing))
    }

    public static func mocked() -> some View {
        PrismSpacer()
    }
}

#Preview {
    PrismSymbol.mocked()
}
