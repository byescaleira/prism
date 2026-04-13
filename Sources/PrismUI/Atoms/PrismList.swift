//
//  PrismList.swift
//  Prism
//
//  Created by Rafael Escaleira on 05/06/25.
//

import SwiftUI

/// Lista de rows do Design System PrismUI.
///
/// `PrismList` é um wrapper do `List` nativo com:
/// - Suporte a seleção múltipla opcional
/// - Integração com `PrismSection` para agrupamentos
/// - Estilo consistente com o Design System
///
/// ## Uso Básico
/// ```swift
/// PrismList {
///     PrismSection {
///         PrismBodyText("Item 1")
///         PrismBodyText("Item 2")
///     }
/// }
/// ```
///
/// ## Com Seleção
/// ```swift
/// @State var selected: Set<String> = []
/// PrismList(selection: $selected) {
///     PrismBodyText("Item 1")
///         .tag("item1")
///     PrismBodyText("Item 2")
///         .tag("item2")
/// }
/// ```
///
/// - Note: Use `PrismSection` dentro da lista para agrupar conteúdo com header/footer.
public struct PrismList<SelectionValue: Hashable>: PrismView {
    let content: any View
    let selection: Binding<Set<SelectionValue>>?

    public init(
        selection: Binding<Set<SelectionValue>>? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.content = content()
        self.selection = selection
    }

    public var body: some View {
        List(selection: selection) {
            AnyView(content)
        }
    }

    public static func mocked() -> some View {
        PrismList {
            PrismBodyText.mocked()
            PrismPrimaryButton.mocked()
            PrismSection.mocked()
            PrismFootnoteText.mocked()
            PrismSecondaryButton.mocked()
        }
    }
}

extension PrismList where SelectionValue == Never {
    public init(@ViewBuilder content: () -> some View) {
        self.content = content()
        self.selection = nil
    }

    public static func mocked() -> some View {
        PrismList {
            PrismBodyText.mocked()
            PrismPrimaryButton.mocked()
            PrismSection.mocked()
            PrismFootnoteText.mocked()
            PrismSecondaryButton.mocked()
        }
    }
}

#Preview {
    PrismList.mocked()
}
