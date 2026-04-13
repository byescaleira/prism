//
//  PrismGlowModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 25/04/25.
//

import SwiftUI

/// Modificador de efeito glow (brilho animado) do Design System PrismUI.
///
/// `PrismGlowModifier` aplica um brilho animado com gradiente angular:
/// - Animação contínua de gradiente angular (6s por ciclo)
/// - Cores dinâmicas baseadas no tema ou cor personalizada
/// - Blur de 20pt para efeito suave
/// - Ideal para estados de destaque ou celebração
///
/// ## Uso Básico
/// ```swift
/// PrismText("Destaque")
///     .prismGlow()
/// ```
///
/// ## Com Cor Personalizada
/// ```swift
/// PrismSymbol("star.fill")
///     .prismGlow(for: .yellow)
/// ```
///
/// ## Efeito
/// O glow usa um gradiente angular animado que:
/// - Gira 360° continuamente
/// - Alterna entre cor principal e 60% de opacidade
/// - Cria efeito de "luz em movimento"
///
/// - Note: O modifier usa `TimelineView` para animação suave e eficiente.
public struct PrismGlowModifier: ViewModifier {
    @Environment(\.theme) var theme
    let color: Color?

    var colors: [Color] {
        guard let color else {
            return [
                theme.color.primary,
                theme.color.secondary,
                theme.color.primary,
                theme.color.secondary,
            ]
        }

        return [
            color,
            color.opacity(0.6),
            color,
            color.opacity(0.6),
        ]
    }

    init(color: Color? = nil) {
        self.color = color
    }

    public func body(content: Content) -> some View {
        content
            .background(animatedAngularGradient)
    }

    private var animatedAngularGradient: some View {
        TimelineView(.animation) { ctx in
            let date = ctx.date.timeIntervalSinceReferenceDate
            let period = 6.0
            let progress = date.truncatingRemainder(dividingBy: period) / period
            let angle = progress * 360

            angularGradient(angle: angle)
        }
    }

    private func angularGradient(angle: Double) -> some View {
        AngularGradient(
            colors: colors,
            center: .center,
            startAngle: .degrees(angle),
            endAngle: .degrees(angle + 360)
        )
        .blur(radius: 20)
        .prismPadding()
        .prismPadding(.negative(.medium))
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prismPadding()
            .prismGlow()
            .prismPadding()
    }
}

#Preview {
    PrismGlowModifier.mocked()
}
