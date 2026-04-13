//
//  RyzeSizeModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

/// Modificador de tamanho do Design System RyzeUI.
///
/// `RyzeSizeModifier` aplica dimensões usando tokens semânticos:
/// - Largura e altura via `RyzeSize` tokens
/// - Suporte a `.max` para preenchimento total
/// - Alinhamento configurável
/// - Integração com `theme.size` para consistência
///
/// ## Uso Básico
/// ```swift
/// RyzeShape(.circle)
///     .ryze(width: .large, height: .large)
/// ```
///
/// ## Largura Máxima
/// ```swift
/// RyzeTextField(text: $text)
///     .ryze(width: .max)  // Ocupa toda largura disponível
/// ```
///
/// ## Tamanho Fixo
/// ```swift
/// RyzeSymbol("star")
///     .ryze(width: .medium, height: .medium)
/// ```
///
/// ## Tamanhos Disponíveis
/// - `.small`, `.medium`, `.large`, `.extraLarge`, `.extraExtraLarge`
/// - `.max` - Preenchimento máximo
///
/// - Note: O modifier combina múltiplos `.frame()` calls para suportar `.max` corretamente.
public struct RyzeSizeModifier: ViewModifier {
    @Environment(\.theme) var theme

    let width: RyzeSize?
    let height: RyzeSize?
    let alignment: Alignment

    init(width: RyzeSize?, height: RyzeSize?, alignment: Alignment) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }

    var widthValue: CGFloat? { width?.rawValue(for: theme.size) }
    var heightValue: CGFloat? { height?.rawValue(for: theme.size) }

    public func body(content: Content) -> some View {
        content
            .ryze(if: width == .max && height == .max) {
                $0.frame(
                    maxWidth: widthValue,
                    maxHeight: heightValue,
                    alignment: alignment
                )
            }
            .ryze(if: width == .max && height != .max) {
                $0.frame(
                    maxWidth: widthValue,
                    alignment: alignment
                ).frame(
                    height: heightValue,
                    alignment: alignment
                )
            }
            .ryze(if: width != .max && height == .max) {
                $0.frame(
                    maxHeight: heightValue,
                    alignment: alignment
                ).frame(
                    width: widthValue,
                    alignment: alignment
                )
            }
            .ryze(if: width != .max && height != .max) {
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
            .ryze(width: .medium, height: .medium, alignment: .center)
    }
}

#Preview {
    RyzeSizeModifier.mocked()
}
