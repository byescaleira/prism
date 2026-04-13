//
//  View.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import PrismFoundation
import SwiftUI

private struct PrismThemeModifier: ViewModifier {
    let theme: PrismTheme

    func body(content: Content) -> some View {
        content
            .environment(\.theme, theme)
            .environment(\.designTokens, theme.tokens)
    }
}

private struct PrismTokensModifier: ViewModifier {
    @Environment(\.theme) private var theme

    let tokens: PrismDesignTokens

    func body(content: Content) -> some View {
        let resolvedTheme = theme.with(tokens: tokens)

        return
            content
            .environment(\.theme, resolvedTheme)
            .environment(\.designTokens, tokens)
    }
}

// MARK: - View Modifiers do Design System PrismUI
///
/// Esta extensão fornece todos os modifiers do Design System PrismUI.
/// Os modifiers seguem a convenção de nomenclatura `prism()` para consistência.
///
/// ## Categorias de Modifiers
///
/// ### Style Modifiers
/// - `prism(background:)` - Aplica cor de fundo
/// - `prism(tint:)` - Aplica cor de tint (botões, links)
/// - `prism(color:)` - Aplica cor de foreground
///
/// ### Environment Modifiers
/// - `prism(theme:)` - Aplica tema do Design System
/// - `prism(locale:)` - Define localização
/// - `prism(colorScheme:)` - Força light/dark mode
/// - `prism(loading:)` - Ativa estado de loading (skeleton)
/// - `prism(disabled:)` - Ativa estado de disabled
///
/// ### Text Modifiers
/// - `prism(alignment:)` - Alinhamento de texto multi-linha
/// - `prism(font:weight:design:)` - Tipografia completa
///
/// ### Size & Spacing Modifiers
/// - `prism(width:height:alignment:)` - Dimensões semânticas
/// - `prismPadding(_:_:)` - Padding com tokens PrismSpacing
///
/// ### Background Modifiers
/// - `prismBackground()` - Background padrão do tema
/// - `prismBackgroundSecondary()` - Background secundário
/// - `prismBackgroundRow()` - Background adaptativo para rows
///
/// ### Effect Modifiers
/// - `prismGlow(for:)` - Efeito de brilho animado
/// - `prismSymbol(effect:options:isActive:)` - Efeitos de símbolo
/// - `prismSkeleton()` - Estado de skeleton/loading
/// - `prismParallax(width:height:)` - Efeito parallax 3D (iOS)
/// - `prismConfetti(amount:seconds:isActive:)` - Chuva de confetti
///
/// ### Shape & Clip Modifiers
/// - `prism(clip:)` - Aplica shape como clip
///
/// ### Screen & Display Modifiers
/// - `prismScreenObserve(minimumWidthScreen:)` - Observa tamanho da tela
/// - `prismBrowser(url:)` - Apresenta browser em sheet
///
/// ### Preview Modifiers
/// - `prismPreview(layout:orientation:colorScheme:locale:)` - Configura preview
///
/// ### Accessibility Modifiers
/// - `prism(_:)` - Aplica propriedades de acessibilidade
///
/// ### Conditional Modifiers
/// - `prism(if:transform:)` - Transformação condicional
/// - `prism(item:transform:)` - Transformação com item opcional
/// - `prism(if:transform:else:)` - Transformação com else
/// - `prism(item:transform:else:)` - Transformação com item e else
///
/// ## Exemplo de Uso Combinado
/// ```swift
/// PrismVStack {
///     PrismText("Título")
///         .prism(font: .headline)
///     PrismText("Descrição")
///         .prism(color: .textSecondary)
/// }
/// .prismPadding()
/// .prismBackgroundSecondary()
/// .prism(clip: .rounded(radius: .medium))
/// .prism(loading: isLoading)
/// ```
extension View {
    public func prism(background style: PrismColor) -> some View {
        self.background(style)
    }

    public func prism(tint color: PrismColor) -> some View {
        self.tint(color)
    }

    public func prism(color: PrismColor) -> some View {
        self.foregroundStyle(color)
    }

    public func prism(theme: PrismThemeProtocol) -> some View {
        self.modifier(
            PrismThemeModifier(
                theme: theme.eraseToAnyTheme()
            )
        )
    }

    public func prism(tokens: PrismDesignTokens) -> some View {
        self.modifier(PrismTokensModifier(tokens: tokens))
    }

    public func prism(locale: PrismLocale) -> some View {
        self.environment(\.locale, locale.rawValue)
    }

    public func prism(colorScheme: ColorScheme? = nil) -> some View {
        self.preferredColorScheme(colorScheme)
    }

    public func prism(loading: Bool) -> some View {
        self.environment(\.isLoading, loading)
    }

    public func prism(disabled: Bool) -> some View {
        self.environment(\.isDisabled, disabled)
    }

    public func prism(alignment: TextAlignment) -> some View {
        self.multilineTextAlignment(alignment)
    }

    public func prism(
        font: Font = .body,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil
    ) -> some View {
        self.font(font)
            .fontWeight(weight)
            .fontDesign(design)
    }

    public func prism(
        width: PrismSize? = nil,
        height: PrismSize? = nil,
        alignment: Alignment = .center
    ) -> some View {
        self.modifier(
            PrismSizeModifier(
                width: width,
                height: height,
                alignment: alignment
            )
        )
    }

    public func prismPadding(
        _ edges: Edge.Set = .all,
        _ spacing: PrismSpacing = .medium
    ) -> some View {
        self.modifier(PrismSpacingModifier(edges: edges, spacing: spacing))
    }

    public func prismPadding(
        _ spacing: PrismSpacing = .medium
    ) -> some View {
        self.modifier(PrismSpacingModifier(edges: .all, spacing: spacing))
    }

    public func prismBackground() -> some View {
        self.modifier(PrismBackgroundModifier())
    }

    public func prismBackgroundSecondary() -> some View {
        self.modifier(PrismBackgroundSecondaryModifier())
    }

    public func prismBackgroundRow() -> some View {
        self.modifier(PrismBackgroundRowModifier())
    }

    public func prismGlow(for color: Color? = nil) -> some View {
        self.modifier(PrismGlowModifier(color: color))
    }

    public func prismSymbol<T: IndefiniteSymbolEffect & SymbolEffect>(
        effect: T,
        options: SymbolEffectOptions = .default,
        isActive: Bool = true
    ) -> some View {
        self.symbolEffect(
            effect,
            options: options,
            isActive: isActive
        )
    }

    @ViewBuilder
    public func prism<Content: View>(
        if condition: Bool,
        transition: AnyTransition = .scale,
        animation: Animation? = .linear,
        transform: (Self) -> Content
    ) -> some View {
        PrismZStack {
            if condition {
                transform(self)
                    .transition(transition)
            } else {
                self
            }
        }
        .animation(animation, value: condition)
    }

    @ViewBuilder
    public func prism<Content: View, Value>(
        item value: Value?,
        transform: (Self, Value) -> Content
    ) -> some View {
        if let value { transform(self, value) } else { self }
    }

    @ViewBuilder
    public func prism<Content: View, ElseContent: View>(
        if condition: Bool,
        transform: (Self) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        if condition { transform(self) } else if let `else` { `else`(self) } else { self }
    }

    @ViewBuilder
    public func prism<Content: View, Value, ElseContent: View>(
        item value: Value?,
        transform: (Self, Value) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        if let value { transform(self, value) } else if let `else` { `else`(self) } else { self }
    }

    public func prismSkeleton() -> some View {
        self.modifier(PrismSkeletonModifier())
    }

    @ViewBuilder
    public func prismParallax(width: PrismSize? = nil, height: PrismSize?) -> some View {
        #if os(iOS)
            self.modifier(PrismParallaxModifier(width: width, height: height))
        #else
            self
        #endif
    }

    public func prism(clip shape: PrismShape) -> some View {
        self.clipShape(shape)
    }

    public func prismPreview(
        layout: PreviewLayout,
        orientation: InterfaceOrientation,
        colorScheme: ColorScheme,
        locale: PrismLocale
    ) -> some View {
        self
            .prismPadding(.extraLarge)
            .prismBackground()
            .prism(locale: locale)
            .previewLayout(layout)
            .previewInterfaceOrientation(orientation)
            .preferredColorScheme(colorScheme)
            .previewDisplayName(
                .prismPreviewDisplayName(
                    Self.self,
                    scheme: colorScheme,
                    locale: locale
                )
            )
    }

    @ViewBuilder
    public func prism(_ accessibility: PrismAccessibilityProperties?) -> some View {
        if let accessibility {
            self.modifier(PrismAccessibilityModifier(properties: accessibility))
        } else {
            self
        }
    }

    public func prismScreenObserve(minimumWidthScreen: CGFloat = 430) -> some View {
        self.modifier(PrismScreenModifier(minimumWidthScreen: minimumWidthScreen))
    }

    public func prismConfetti(
        amount: Int = 30,
        seconds: Int = 4,
        isActive: Bool
    ) -> some View {
        self.modifier(
            PrismConfettiModifier(
                amount: amount,
                seconds: seconds,
                isActive: isActive
            )
        )
    }

    public func prismBrowser(url: Binding<URL?>) -> some View {
        self.sheet(
            isPresented: Binding(
                get: { url.wrappedValue != nil },
                set: { isPresented in
                    if !isPresented {
                        url.wrappedValue = nil
                    }
                }
            )
        ) {
            if let currentURL = url.wrappedValue {
                PrismBrowser(url: currentURL)
            }
        }
    }
}
