//
//  PrismSymbol.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import PrismFoundation
import SwiftUI

/// Símbolo SF Symbols do Design System PrismUI.
///
/// `PrismSymbol` é um wrapper do `Image(systemName:)` nativo com:
/// - Suporte a modos de renderização (monochrome, hierarchical, palette)
/// - Variantes de símbolo (.fill, .circle, .square, etc.)
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
/// - Integração com efeitos de símbolo animados
///
/// ## Uso Básico
/// ```swift
/// PrismSymbol("star.fill")
/// ```
///
/// ## Com Modo de Renderização Hierárquico
/// ```swift
/// PrismSymbol("star.fill", mode: .hierarchical)
///     .prism(color: .primary)
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// PrismSymbol(
///     "person.circle.fill",
///     testID: "profile_icon"
/// )
/// ```
///
/// ## Com Efeito Animado
/// ```swift
/// PrismSymbol("wifi")
///     .prismSymbol(effect: .variableColor.cumulative)
/// ```
///
/// ## Modos de Renderização Disponíveis
/// - `.monochrome` - Cor única
/// - `.hierarchical` - Hierarquia de cores baseada no foregroundStyle
/// - `.palette` - Paleta de cores específica
///
/// ## Variantes Disponíveis
/// - `.fill`, `.circle`, `.square`, `.slash`, `.crop`, etc.
///
/// - Note: Use `PrismSymbol.mocked()` para previews e testes unitários.
public struct PrismSymbol: PrismView {
    @Environment(\.isLoading) var isLoading

    let name: String
    let mode: SymbolRenderingMode
    let variants: SymbolVariants
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ name: String = "infinity",
        mode: SymbolRenderingMode = .monochrome,
        variants: SymbolVariants = .none,
        accessibility: PrismAccessibilityProperties? = nil
    ) {
        self.name = name
        self.mode = mode
        self.variants = variants
        self.accessibility = accessibility
    }

    public init(
        _ name: String,
        testID: String,
        mode: SymbolRenderingMode = .monochrome,
        variants: SymbolVariants = .none
    ) {
        self.name = name
        self.mode = mode
        self.variants = variants
        self.accessibility = PrismAccessibility.image(LocalizedStringKey(name), testID: testID)
    }

    public var body: some View {
        let content = Image(systemName: name)
            .symbolRenderingMode(mode)
            .symbolVariant(variants)
            .prismSkeleton()

        if let accessibility {
            content.prism(accessibility: accessibility)
        } else {
            content
        }
    }

    public static func mocked() -> some View {
        PrismSymbol(
            "wifi",
            variants: .fill
        )
        .prismSymbol(effect: .variableColor.cumulative.dimInactiveLayers.reversing)
    }
}

#Preview {
    PrismSymbol.mocked()
}
