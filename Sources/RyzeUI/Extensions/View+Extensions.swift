//
//  View.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import RyzeFoundation
import SwiftUI

private struct RyzeThemeModifier: ViewModifier {
    let theme: RyzeTheme

    func body(content: Content) -> some View {
        content
            .environment(\.theme, theme)
            .environment(\.designTokens, theme.tokens)
    }
}

private struct RyzeTokensModifier: ViewModifier {
    @Environment(\.theme) private var theme

    let tokens: RyzeDesignTokens

    func body(content: Content) -> some View {
        let resolvedTheme = theme.with(tokens: tokens)

        return
            content
            .environment(\.theme, resolvedTheme)
            .environment(\.designTokens, tokens)
    }
}

// MARK: - View Modifiers do Design System RyzeUI
///
/// Esta extensão fornece todos os modifiers do Design System RyzeUI.
/// Os modifiers seguem a convenção de nomenclatura `ryze()` para consistência.
///
/// ## Categorias de Modifiers
///
/// ### Style Modifiers
/// - `ryze(background:)` - Aplica cor de fundo
/// - `ryze(tint:)` - Aplica cor de tint (botões, links)
/// - `ryze(color:)` - Aplica cor de foreground
///
/// ### Environment Modifiers
/// - `ryze(theme:)` - Aplica tema do Design System
/// - `ryze(locale:)` - Define localização
/// - `ryze(colorScheme:)` - Força light/dark mode
/// - `ryze(loading:)` - Ativa estado de loading (skeleton)
/// - `ryze(disabled:)` - Ativa estado de disabled
///
/// ### Text Modifiers
/// - `ryze(alignment:)` - Alinhamento de texto multi-linha
/// - `ryze(font:weight:design:)` - Tipografia completa
///
/// ### Size & Spacing Modifiers
/// - `ryze(width:height:alignment:)` - Dimensões semânticas
/// - `ryzePadding(_:_:)` - Padding com tokens RyzeSpacing
///
/// ### Background Modifiers
/// - `ryzeBackground()` - Background padrão do tema
/// - `ryzeBackgroundSecondary()` - Background secundário
/// - `ryzeBackgroundRow()` - Background adaptativo para rows
///
/// ### Effect Modifiers
/// - `ryzeGlow(for:)` - Efeito de brilho animado
/// - `ryzeSymbol(effect:options:isActive:)` - Efeitos de símbolo
/// - `ryzeSkeleton()` - Estado de skeleton/loading
/// - `ryzeParallax(width:height:)` - Efeito parallax 3D (iOS)
/// - `ryzeConfetti(amount:seconds:isActive:)` - Chuva de confetti
///
/// ### Shape & Clip Modifiers
/// - `ryze(clip:)` - Aplica shape como clip
///
/// ### Screen & Display Modifiers
/// - `ryzeScreenObserve(minimumWidthScreen:)` - Observa tamanho da tela
/// - `ryzeBrowser(url:)` - Apresenta browser em sheet
///
/// ### Preview Modifiers
/// - `ryzePreview(layout:orientation:colorScheme:locale:)` - Configura preview
///
/// ### Accessibility Modifiers
/// - `ryze(_:)` - Aplica propriedades de acessibilidade
///
/// ### Conditional Modifiers
/// - `ryze(if:transform:)` - Transformação condicional
/// - `ryze(item:transform:)` - Transformação com item opcional
/// - `ryze(if:transform:else:)` - Transformação com else
/// - `ryze(item:transform:else:)` - Transformação com item e else
///
/// ## Exemplo de Uso Combinado
/// ```swift
/// RyzeVStack {
///     RyzeText("Título")
///         .ryze(font: .headline)
///     RyzeText("Descrição")
///         .ryze(color: .textSecondary)
/// }
/// .ryzePadding()
/// .ryzeBackgroundSecondary()
/// .ryze(clip: .rounded(radius: .medium))
/// .ryze(loading: isLoading)
/// ```
extension View {
    public func ryze(background style: RyzeColor) -> some View {
        self.background(style)
    }

    public func ryze(tint color: RyzeColor) -> some View {
        self.tint(color)
    }

    public func ryze(color: RyzeColor) -> some View {
        self.foregroundStyle(color)
    }

    public func ryze(theme: RyzeThemeProtocol) -> some View {
        self.modifier(
            RyzeThemeModifier(
                theme: theme.eraseToAnyTheme()
            )
        )
    }

    public func ryze(tokens: RyzeDesignTokens) -> some View {
        self.modifier(RyzeTokensModifier(tokens: tokens))
    }

    public func ryze(locale: RyzeLocale) -> some View {
        self.environment(\.locale, locale.rawValue)
    }

    public func ryze(colorScheme: ColorScheme? = nil) -> some View {
        self.preferredColorScheme(colorScheme)
    }

    public func ryze(loading: Bool) -> some View {
        self.environment(\.isLoading, loading)
    }

    public func ryze(disabled: Bool) -> some View {
        self.environment(\.isDisabled, disabled)
    }

    public func ryze(alignment: TextAlignment) -> some View {
        self.multilineTextAlignment(alignment)
    }

    public func ryze(
        font: Font = .body,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil
    ) -> some View {
        self.font(font)
            .fontWeight(weight)
            .fontDesign(design)
    }

    public func ryze(
        width: RyzeSize? = nil,
        height: RyzeSize? = nil,
        alignment: Alignment = .center
    ) -> some View {
        self.modifier(
            RyzeSizeModifier(
                width: width,
                height: height,
                alignment: alignment
            )
        )
    }

    public func ryzePadding(
        _ edges: Edge.Set = .all,
        _ spacing: RyzeSpacing = .medium
    ) -> some View {
        self.modifier(RyzeSpacingModifier(edges: edges, spacing: spacing))
    }

    public func ryzePadding(
        _ spacing: RyzeSpacing = .medium
    ) -> some View {
        self.modifier(RyzeSpacingModifier(edges: .all, spacing: spacing))
    }

    public func ryzeBackground() -> some View {
        self.modifier(RyzeBackgroundModifier())
    }

    public func ryzeBackgroundSecondary() -> some View {
        self.modifier(RyzeBackgroundSecondaryModifier())
    }

    public func ryzeBackgroundRow() -> some View {
        self.modifier(RyzeBackgroundRowModifier())
    }

    public func ryzeGlow(for color: Color? = nil) -> some View {
        self.modifier(RyzeGlowModifier(color: color))
    }

    public func ryzeSymbol<T: IndefiniteSymbolEffect & SymbolEffect>(
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
    public func ryze<Content: View>(
        if condition: Bool,
        transition: AnyTransition = .scale,
        animation: Animation? = .linear,
        transform: (Self) -> Content
    ) -> some View {
        RyzeZStack {
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
    public func ryze<Content: View, Value>(
        item value: Value?,
        transform: (Self, Value) -> Content
    ) -> some View {
        if let value { transform(self, value) } else { self }
    }

    @ViewBuilder
    public func ryze<Content: View, ElseContent: View>(
        if condition: Bool,
        transform: (Self) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        if condition { transform(self) } else if let `else` { `else`(self) } else { self }
    }

    @ViewBuilder
    public func ryze<Content: View, Value, ElseContent: View>(
        item value: Value?,
        transform: (Self, Value) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        if let value { transform(self, value) } else if let `else` { `else`(self) } else { self }
    }

    public func ryzeSkeleton() -> some View {
        self.modifier(RyzeSkeletonModifier())
    }

    @ViewBuilder
    public func ryzeParallax(width: RyzeSize? = nil, height: RyzeSize?) -> some View {
        #if os(iOS)
            self.modifier(RyzeParallaxModifier(width: width, height: height))
        #else
            self
        #endif
    }

    public func ryze(clip shape: RyzeShape) -> some View {
        self.clipShape(shape)
    }

    public func ryzePreview(
        layout: PreviewLayout,
        orientation: InterfaceOrientation,
        colorScheme: ColorScheme,
        locale: RyzeLocale
    ) -> some View {
        self
            .ryzePadding(.extraLarge)
            .ryzeBackground()
            .ryze(locale: locale)
            .previewLayout(layout)
            .previewInterfaceOrientation(orientation)
            .preferredColorScheme(colorScheme)
            .previewDisplayName(
                .ryzePreviewDisplayName(
                    Self.self,
                    scheme: colorScheme,
                    locale: locale
                )
            )
    }

    @ViewBuilder
    public func ryze(_ accessibility: RyzeAccessibilityProperties?) -> some View {
        if let accessibility {
            self.modifier(RyzeAccessibilityModifier(properties: accessibility))
        } else {
            self
        }
    }

    public func ryzeScreenObserve(minimumWidthScreen: CGFloat = 430) -> some View {
        self.modifier(RyzeScreenModifier(minimumWidthScreen: minimumWidthScreen))
    }

    public func ryzeConfetti(
        amount: Int = 30,
        seconds: Int = 4,
        isActive: Bool
    ) -> some View {
        self.modifier(
            RyzeConfettiModifier(
                amount: amount,
                seconds: seconds,
                isActive: isActive
            )
        )
    }

    public func ryzeBrowser(url: Binding<URL?>) -> some View {
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
                RyzeBrowser(url: currentURL)
            }
        }
    }
}
