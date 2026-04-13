//
//  RyzeShape.swift
//  Ryze
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Shape personalizado do Design System RyzeUI.
///
/// `RyzeShape` é um wrapper de `Shape` que fornece formas geométricas comuns:
/// - Círculo perfeito
/// - Cápsula (retângulo com cantos totalmente arredondados)
/// - Retângulo com raio personalizado
/// - Compatível com `.clipShape()` e `.background()`
///
/// ## Uso Básico
/// ```swift
/// RyzeShape(.circle)
///     .ryze(background: .primary)
/// ```
///
/// ## Como Clip Shape
/// ```swift
/// RyzeImage("photo")
///     .ryze(clip: .rounded(radius: 12))
/// ```
///
/// ## Formas Disponíveis
/// - `.circle` - Círculo perfeito
/// - `.capsule` - Cápsula (pill shape)
/// - `.rounded(radius: CGFloat)` - Retângulo com raio personalizado
///
/// - Note: Use com `ryze(clip:)` ou `ryze(background:)` para aplicar formas.
public struct RyzeShape: Shape {
    var base: @Sendable (CGRect) -> Path

    public init<S: Shape>(shape: S) {
        base = shape.path(in:)
    }

    public func path(in rect: CGRect) -> Path {
        base(rect)
    }

    public static var capsule: RyzeShape {
        .init(shape: .capsule)
    }

    public static var circle: RyzeShape {
        .init(shape: .circle)
    }

    public static func rounded(radius: CGFloat) -> RyzeShape {
        .init(shape: .rect(cornerRadius: radius))
    }
}
