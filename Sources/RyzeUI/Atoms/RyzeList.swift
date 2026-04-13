//
//  RyzeList.swift
//  Ryze
//
//  Created by Rafael Escaleira on 05/06/25.
//

import SwiftUI

/// Lista de rows do Design System RyzeUI.
///
/// `RyzeList` é um wrapper do `List` nativo com:
/// - Suporte a seleção múltipla opcional
/// - Integração com `RyzeSection` para agrupamentos
/// - Estilo consistente com o Design System
///
/// ## Uso Básico
/// ```swift
/// RyzeList {
///     RyzeSection {
///         RyzeBodyText("Item 1")
///         RyzeBodyText("Item 2")
///     }
/// }
/// ```
///
/// ## Com Seleção
/// ```swift
/// @State var selected: Set<String> = []
/// RyzeList(selection: $selected) {
///     RyzeBodyText("Item 1")
///         .tag("item1")
///     RyzeBodyText("Item 2")
///         .tag("item2")
/// }
/// ```
///
/// - Note: Use `RyzeSection` dentro da lista para agrupar conteúdo com header/footer.
public struct RyzeList<SelectionValue: Hashable>: RyzeView {
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
        RyzeList {
            RyzeBodyText.mocked()
            RyzePrimaryButton.mocked()
            RyzeSection.mocked()
            RyzeFootnoteText.mocked()
            RyzeSecondaryButton.mocked()
        }
    }
}

extension RyzeList where SelectionValue == Never {
    public init(@ViewBuilder content: () -> some View) {
        self.content = content()
        self.selection = nil
    }

    public static func mocked() -> some View {
        RyzeList {
            RyzeBodyText.mocked()
            RyzePrimaryButton.mocked()
            RyzeSection.mocked()
            RyzeFootnoteText.mocked()
            RyzeSecondaryButton.mocked()
        }
    }
}

#Preview {
    RyzeList.mocked()
}
