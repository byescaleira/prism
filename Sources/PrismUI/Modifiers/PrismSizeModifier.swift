//
//  PrismSizeModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

/// Modificador de tamanho do Design System PrismUI.
///
/// `PrismSizeModifier` aplica dimensões usando tokens semânticos:
/// - Largura e altura via `PrismSize` tokens
/// - Suporte a `.max` para preenchimento total
/// - Alinhamento configurável
/// - Integração com `theme.size` para consistência
///
/// ## Uso Básico
/// ```swift
/// PrismShape(.circle)
///     .prism(width: .large, height: .large)
/// ```
///
/// ## Largura Máxima
/// ```swift
/// PrismTextField(text: $text)
///     .prism(width: .max)  // Ocupa toda largura disponível
/// ```
///
/// ## Tamanho Fixo
/// ```swift
/// PrismSymbol("star")
///     .prism(width: .medium, height: .medium)
/// ```
///
/// ## Tamanhos Disponíveis
/// - `.small`, `.medium`, `.large`, `.extraLarge`, `.extraExtraLarge`
/// - `.max` - Preenchimento máximo
///
/// - Note: O modifier combina múltiplos `.frame()` calls para suportar `.max` corretamente.
public struct PrismSizeModifier: ViewModifier {
    @Environment(\.theme) var theme

    let width: PrismSize?
    let height: PrismSize?
    let alignment: Alignment

    init(width: PrismSize?, height: PrismSize?, alignment: Alignment) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }

    var widthValue: CGFloat? { width?.rawValue(for: theme.size) }
    var heightValue: CGFloat? { height?.rawValue(for: theme.size) }

    public func body(content: Content) -> some View {
        content
            .prism(if: width == .max && height == .max) {
                $0.frame(
                    maxWidth: widthValue,
                    maxHeight: heightValue,
                    alignment: alignment
                )
            }
            .prism(if: width == .max && height != .max) {
                $0.frame(
                    maxWidth: widthValue,
                    alignment: alignment
                ).frame(
                    height: heightValue,
                    alignment: alignment
                )
            }
            .prism(if: width != .max && height == .max) {
                $0.frame(
                    maxHeight: heightValue,
                    alignment: alignment
                ).frame(
                    width: widthValue,
                    alignment: alignment
                )
            }
            .prism(if: width != .max && height != .max) {
                $0.frame(
                    width: widthValue,
                    height: heightValue,
                    alignment: alignment
                )
            }
    }

    static func mocked() -> some View {
        Image(systemName: "square.and.arrow.up")
            .resizable()
            .scaledToFit()
            .prism(width: .medium, height: .medium, alignment: .center)
    }
}

#Preview {
    PrismSizeModifier.mocked()
}
