//
//  PrismShape.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Shape personalizado do Design System PrismUI.
///
/// `PrismShape` é um wrapper de `Shape` que fornece formas geométricas comuns:
/// - Círculo perfeito
/// - Cápsula (retângulo com cantos totalmente arredondados)
/// - Retângulo com raio personalizado
/// - Compatível com `.clipShape()` e `.background()`
///
/// ## Uso Básico
/// ```swift
/// PrismShape(.circle)
///     .prism(background: .primary)
/// ```
///
/// ## Como Clip Shape
/// ```swift
/// PrismImage("photo")
///     .prism(clip: .rounded(radius: 12))
/// ```
///
/// ## Formas Disponíveis
/// - `.circle` - Círculo perfeito
/// - `.capsule` - Cápsula (pill shape)
/// - `.rounded(radius: CGFloat)` - Retângulo com raio personalizado
///
/// - Note: Use com `prism(clip:)` ou `prism(background:)` para aplicar formas.
public struct PrismShape: Shape {
    var base: @Sendable (CGRect) -> Path

    public init<S: Shape>(shape: S) {
        base = shape.path(in:)
    }

    public func path(in rect: CGRect) -> Path {
        base(rect)
    }

    public static var capsule: PrismShape {
        .init(shape: .capsule)
    }

    public static var circle: PrismShape {
        .init(shape: .circle)
    }

    public static func rounded(radius: CGFloat) -> PrismShape {
        .init(shape: .rect(cornerRadius: radius))
    }
}
