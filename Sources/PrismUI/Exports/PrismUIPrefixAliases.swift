//
//  PrismUIPrefixAliases.swift
//  PrismUI
//
//  Created by Rafael Escaleira on 09/04/26.
//
//  Arquivo de typealiases para personalização de prefixo do Design System.
//
//  PARA USAR: Copie este arquivo para seu projeto e altere o prefixo "Nova"
//  para o prefixo desejado. Exemplo:
//
//  ```swift
//  // No seu projeto:
//  public typealias AppButton = PrismButton
//  public typealias AppText = PrismText
//  // etc...
//  ```
//

import PrismFoundation
import SwiftUI

// MARK: - Atoms

public typealias NovaButton = PrismButton
public typealias NovaText = PrismText
public typealias NovaTextField = PrismTextField
public typealias NovaSymbol = PrismSymbol
public typealias NovaSpacer = PrismSpacer
public typealias NovaVStack = PrismVStack
public typealias NovaHStack = PrismHStack
public typealias NovaZStack = PrismZStack
public typealias NovaAdaptiveStack = PrismAdaptiveStack
public typealias NovaLazyList = PrismLazyList
public typealias NovaList = PrismList
public typealias NovaHorizontalList = PrismHorizontalList
public typealias NovaAsyncImage = PrismAsyncImage
public typealias NovaShape = PrismShape
public typealias NovaSection = PrismSection
public typealias NovaLabel = PrismLabel
public typealias NovaTabView = PrismTabView

// MARK: - Molecules

public typealias NovaTag = PrismTag
public typealias NovaCarousel = PrismCarousel
public typealias NovaPrimaryButton = PrismPrimaryButton
public typealias NovaSecondaryButton = PrismSecondaryButton
public typealias NovaBodyText = PrismBodyText
public typealias NovaFootnoteText = PrismFootnoteText
public typealias NovaCurrencyTextField = PrismCurrencyTextField
public typealias NovaNavigationView = PrismNavigationView
public typealias NovaAdaptiveScreen = PrismAdaptiveScreen
public typealias NovaScaffold = PrismScaffold
public typealias NovaBrowserView = PrismBrowserView
public typealias NovaVideoView = PrismVideoView

// MARK: - Accessibility

public typealias NovaAccessibilityProperties = PrismAccessibilityProperties
public typealias NovaAccessibilityConfig = PrismAccessibilityConfig
public typealias NovaAccessibility = PrismAccessibility
public typealias NovaAccessibilityAction = PrismAccessibilityAction
public typealias NovaAccessibilityBuilder = PrismAccessibilityBuilder
public typealias NovaAccessibilityHint = PrismAccessibilityHint

// MARK: - Styles & Tokens

public typealias NovaColor = PrismColor
public typealias NovaSpacing = PrismSpacing
public typealias NovaRadius = PrismRadius
public typealias NovaSize = PrismSize
public typealias NovaLayoutTier = PrismLayoutTier
public typealias NovaPlatform = PrismPlatform
public typealias NovaPlatformContext = PrismPlatformContext
public typealias NovaNavigationModel = PrismNavigationModel
public typealias NovaGradient = PrismGradient
public typealias NovaSemanticColors = PrismSemanticColors
public typealias NovaDesignTokens = PrismDesignTokens
public typealias NovaButtonVariant = PrismButtonVariant
public typealias NovaAdaptiveStackStyle = PrismAdaptiveStackStyle
public typealias NovaSpacingToken = SpacingToken
public typealias NovaRadiusToken = RadiusToken
public typealias NovaFontSizeToken = FontSizeToken
public typealias NovaMotionToken = MotionToken
public typealias NovaBreakpoint = Breakpoint

// MARK: - Protocols

public typealias NovaThemeProtocol = PrismThemeProtocol
public typealias NovaColorProtocol = PrismColorProtocol
public typealias NovaSpacingProtocol = PrismSpacingProtocol
public typealias NovaRadiusProtocol = PrismRadiusProtocol
public typealias NovaSizeProtocol = PrismSizeProtocol
public typealias NovaFontProtocol = PrismFontProtocol
public typealias NovaFontFamilyProtocol = PrismFontFamilyProtocol
public typealias NovaTextFieldMask = PrismTextFieldMask
public typealias NovaTextFieldConfiguration = PrismTextFieldConfiguration
public typealias NovaUIMock = PrismUIMock

// MARK: - Errors & Enums

public typealias NovaUIError = PrismUIError
public typealias NovaTextInputAutocapitalization = PrismTextInputAutocapitalization
public typealias NovaTextFieldContentType = PrismTextFieldContentType

// MARK: - View Modifiers Extensions

extension View {
    // MARK: - Accessibility

    /// Aplica prefixo personalizado às propriedades de acessibilidade
    public func nova(accessibility properties: PrismAccessibilityProperties) -> some View {
        prism(accessibility: properties)
    }

    /// Atalho para definir apenas testID com prefixo personalizado
    public func nova(testID: String) -> some View {
        prism(testID: testID)
    }

    /// Aplica propriedades de acessibilidade usando builder pattern com prefixo personalizado
    public func nova(accessibility builder: (PrismAccessibilityConfig) -> PrismAccessibilityConfig) -> some View {
        prism(accessibility: builder)
    }

    // MARK: - Style Modifiers

    /// Aplica cor de fundo com prefixo personalizado
    public func nova(background style: PrismColor) -> some View {
        prism(background: style)
    }

    /// Aplica cor de tint com prefixo personalizado
    public func nova(tint color: PrismColor) -> some View {
        prism(tint: color)
    }

    /// Aplica cor de foreground com prefixo personalizado
    public func nova(color: PrismColor) -> some View {
        prism(color: color)
    }

    // MARK: - Environment Modifiers

    /// Aplica tema com prefixo personalizado
    public func nova(theme: PrismThemeProtocol) -> some View {
        prism(theme: theme)
    }

    /// Aplica locale com prefixo personalizado
    public func nova(locale: PrismLocale) -> some View {
        prism(locale: locale)
    }

    /// Aplica color scheme com prefixo personalizado
    public func nova(colorScheme: ColorScheme? = nil) -> some View {
        prism(colorScheme: colorScheme)
    }

    /// Aplica estado de loading com prefixo personalizado
    public func nova(loading: Bool) -> some View {
        prism(loading: loading)
    }

    /// Aplica estado de disabled com prefixo personalizado
    public func nova(disabled: Bool) -> some View {
        prism(disabled: disabled)
    }

    // MARK: - Text Modifiers

    /// Aplica alinhamento de texto com prefixo personalizado
    public func nova(alignment: TextAlignment) -> some View {
        prism(alignment: alignment)
    }

    /// Aplica fonte com prefixo personalizado
    public func nova(
        font: Font = .body,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil
    ) -> some View {
        prism(font: font, weight: weight, design: design)
    }

    // MARK: - Size & Spacing Modifiers

    /// Aplica tamanho com prefixo personalizado
    public func nova(
        width: PrismSize? = nil,
        height: PrismSize? = nil,
        alignment: Alignment = .center
    ) -> some View {
        prism(width: width, height: height, alignment: alignment)
    }

    /// Aplica padding com prefixo personalizado
    public func novaPadding(
        _ edges: Edge.Set = .all,
        _ spacing: PrismSpacing = .medium
    ) -> some View {
        prismPadding(edges, spacing)
    }

    /// Aplica padding com prefixo personalizado (todas as bordas)
    public func novaPadding(
        _ spacing: PrismSpacing = .medium
    ) -> some View {
        prismPadding(spacing)
    }

    // MARK: - Background Modifiers

    /// Aplica background padrão com prefixo personalizado
    public func novaBackground() -> some View {
        prismBackground()
    }

    /// Aplica background secundário com prefixo personalizado
    public func novaBackgroundSecondary() -> some View {
        prismBackgroundSecondary()
    }

    /// Aplica background de row com prefixo personalizado
    public func novaBackgroundRow() -> some View {
        prismBackgroundRow()
    }

    // MARK: - Effect Modifiers

    /// Aplica efeito glow com prefixo personalizado
    public func novaGlow(for color: Color? = nil) -> some View {
        prismGlow(for: color)
    }

    /// Aplica efeito de símbolo com prefixo personalizado
    public func novaSymbol<T: IndefiniteSymbolEffect & SymbolEffect>(
        effect: T,
        options: SymbolEffectOptions = .default,
        isActive: Bool = true
    ) -> some View {
        prismSymbol(effect: effect, options: options, isActive: isActive)
    }

    /// Aplica efeito skeleton com prefixo personalizado
    public func novaSkeleton() -> some View {
        prismSkeleton()
    }

    /// Aplica efeito parallax com prefixo personalizado (iOS apenas)
    public func novaParallax(width: PrismSize? = nil, height: PrismSize?) -> some View {
        prismParallax(width: width, height: height)
    }

    /// Aplica efeito de confetti com prefixo personalizado
    public func novaConfetti(
        amount: Int = 30,
        seconds: Int = 4,
        isActive: Bool
    ) -> some View {
        prismConfetti(amount: amount, seconds: seconds, isActive: isActive)
    }

    // MARK: - Shape & Clip Modifiers

    /// Aplica clip de shape com prefixo personalizado
    public func nova(clip shape: PrismShape) -> some View {
        prism(clip: shape)
    }

    // MARK: - Screen & Display Modifiers

    /// Aplica observação de screen com prefixo personalizado
    public func novaScreenObserve(minimumWidthScreen: CGFloat = 430) -> some View {
        prismScreenObserve(minimumWidthScreen: minimumWidthScreen)
    }

    /// Aplica browser sheet com prefixo personalizado
    public func novaBrowser(url: Binding<URL?>) -> some View {
        prismBrowser(url: url)
    }

    // MARK: - Preview Modifiers

    /// Aplica preview com prefixo personalizado
    public func novaPreview(
        layout: PreviewLayout,
        orientation: InterfaceOrientation,
        colorScheme: ColorScheme,
        locale: PrismLocale
    ) -> some View {
        prismPreview(
            layout: layout,
            orientation: orientation,
            colorScheme: colorScheme,
            locale: locale
        )
    }

    // MARK: - Conditional Modifiers

    /// Aplica transformação condicional com prefixo personalizado
    public func nova<Content: View>(
        if condition: Bool,
        transition: AnyTransition = .scale,
        animation: Animation? = .linear,
        transform: (Self) -> Content
    ) -> some View {
        prism(if: condition, transition: transition, animation: animation, transform: transform)
    }

    /// Aplica transformação condicional com item opcional
    public func nova<Content: View, Value>(
        item value: Value?,
        transform: (Self, Value) -> Content
    ) -> some View {
        prism(item: value, transform: transform)
    }

    /// Aplica transformação condicional com else
    public func nova<Content: View, ElseContent: View>(
        if condition: Bool,
        transform: (Self) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        prism(if: condition, transform: transform, else: `else`)
    }

    /// Aplica transformação condicional com item opcional e else
    public func nova<Content: View, Value, ElseContent: View>(
        item value: Value?,
        transform: (Self, Value) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        prism(item: value, transform: transform, else: `else`)
    }
}
