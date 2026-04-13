//
//  PrismSkeletonModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

/// Modificador de estado de loading (skeleton) do Design System PrismUI.
///
/// `PrismSkeletonModifier` aplica efeito de skeleton quando `isLoading` está ativo:
/// - Usa `.redacted(reason: .placeholder)` para efeito nativo
/// - Transição `.blurReplace` para animação suave
/// - Animação configurada via `theme.animation`
///
/// ## Uso Básico
/// ```swift
/// PrismText("Conteúdo")
///     .prismSkeleton()  // Aplica skeleton quando isLoading = true
/// ```
///
/// ## Com Estado de Loading
/// ```swift
/// @State var isLoading = true
/// PrismVStack {
///     PrismText("Título")
///     PrismText("Descrição")
/// }
/// .prism(loading: isLoading)
/// ```
///
/// - Note: O modifier lê o ambiente `\.isLoading` para determinar o estado.
public struct PrismSkeletonModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @Environment(\.isLoading) private var isLoading

    init() {}

    public func body(content: Content) -> some View {
        PrismZStack {
            if isLoading {
                content
                    .redacted(reason: .placeholder)
                    .transition(.blurReplace)
            } else {
                content
                    .transition(.blurReplace)
            }
        }
        .animation(theme.animation, value: isLoading)
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prismSkeleton()
            .prismPadding()
            .prism(loading: true)
    }
}

#Preview {
    PrismSkeletonModifier.mocked()
}
