//
//  RyzeSymbol.swift
//  Ryze
//
//  Created by Rafael Escaleira on 06/06/25.
//

import RyzeFoundation
import SwiftUI

/// Símbolo SF Symbols do Design System RyzeUI.
///
/// `RyzeSymbol` é um wrapper do `Image(systemName:)` nativo com:
/// - Suporte a modos de renderização (monochrome, hierarchical, palette)
/// - Variantes de símbolo (.fill, .circle, .square, etc.)
/// - Acessibilidade completa (VoiceOver/TalkBack)
/// - Testes de UI (XCUITest) via testIDs estáveis
/// - Integração com efeitos de símbolo animados
///
/// ## Uso Básico
/// ```swift
/// RyzeSymbol("star.fill")
/// ```
///
/// ## Com Modo de Renderização Hierárquico
/// ```swift
/// RyzeSymbol("star.fill", mode: .hierarchical)
///     .ryze(color: .primary)
/// ```
///
/// ## Com testID para Testes
/// ```swift
/// RyzeSymbol(
///     "person.circle.fill",
///     testID: "profile_icon"
/// )
/// ```
///
/// ## Com Efeito Animado
/// ```swift
/// RyzeSymbol("wifi")
///     .ryzeSymbol(effect: .variableColor.cumulative)
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
/// - Note: Use `RyzeSymbol.mocked()` para previews e testes unitários.
public struct RyzeSymbol: RyzeView {
    @Environment(\.isLoading) var isLoading

    let name: String
    let mode: SymbolRenderingMode
    let variants: SymbolVariants
    public var accessibility: RyzeAccessibilityProperties?

    public init(
        _ name: String = "infinity",
        mode: SymbolRenderingMode = .monochrome,
        variants: SymbolVariants = .none,
        accessibility: RyzeAccessibilityProperties? = nil
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
        self.accessibility = RyzeAccessibility.image(LocalizedStringKey(name), testID: testID)
    }

    public var body: some View {
        let content = Image(systemName: name)
            .symbolRenderingMode(mode)
            .symbolVariant(variants)
            .ryzeSkeleton()

        if let accessibility {
            content.ryze(accessibility: accessibility)
        } else {
            content
        }
    }

    public static func mocked() -> some View {
        RyzeSymbol(
            "wifi",
            variants: .fill
        )
        .ryzeSymbol(effect: .variableColor.cumulative.dimInactiveLayers.reversing)
    }
}

#Preview {
    RyzeSymbol.mocked()
}
