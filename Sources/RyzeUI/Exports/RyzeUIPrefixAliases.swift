//
//  RyzeUIPrefixAliases.swift
//  RyzeUI
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
//  public typealias AppButton = RyzeButton
//  public typealias AppText = RyzeText
//  // etc...
//  ```
//

import RyzeFoundation
import SwiftUI

// MARK: - Atoms

public typealias NovaButton = RyzeButton
public typealias NovaText = RyzeText
public typealias NovaTextField = RyzeTextField
public typealias NovaSymbol = RyzeSymbol
public typealias NovaSpacer = RyzeSpacer
public typealias NovaVStack = RyzeVStack
public typealias NovaHStack = RyzeHStack
public typealias NovaZStack = RyzeZStack
public typealias NovaAdaptiveStack = RyzeAdaptiveStack
public typealias NovaLazyList = RyzeLazyList
public typealias NovaList = RyzeList
public typealias NovaHorizontalList = RyzeHorizontalList
public typealias NovaAsyncImage = RyzeAsyncImage
public typealias NovaShape = RyzeShape
public typealias NovaSection = RyzeSection
public typealias NovaLabel = RyzeLabel
public typealias NovaTabView = RyzeTabView

// MARK: - Molecules

public typealias NovaTag = RyzeTag
public typealias NovaCarousel = RyzeCarousel
public typealias NovaPrimaryButton = RyzePrimaryButton
public typealias NovaSecondaryButton = RyzeSecondaryButton
public typealias NovaBodyText = RyzeBodyText
public typealias NovaFootnoteText = RyzeFootnoteText
public typealias NovaCurrencyTextField = RyzeCurrencyTextField
public typealias NovaNavigationView = RyzeNavigationView
public typealias NovaAdaptiveScreen = RyzeAdaptiveScreen
public typealias NovaScaffold = RyzeScaffold
public typealias NovaBrowserView = RyzeBrowserView
public typealias NovaVideoView = RyzeVideoView

// MARK: - Accessibility

public typealias NovaAccessibilityProperties = RyzeAccessibilityProperties
public typealias NovaAccessibilityConfig = RyzeAccessibilityConfig
public typealias NovaAccessibility = RyzeAccessibility
public typealias NovaAccessibilityAction = RyzeAccessibilityAction
public typealias NovaAccessibilityBuilder = RyzeAccessibilityBuilder
public typealias NovaAccessibilityHint = RyzeAccessibilityHint

// MARK: - Styles & Tokens

public typealias NovaColor = RyzeColor
public typealias NovaSpacing = RyzeSpacing
public typealias NovaRadius = RyzeRadius
public typealias NovaSize = RyzeSize
public typealias NovaLayoutTier = RyzeLayoutTier
public typealias NovaPlatform = RyzePlatform
public typealias NovaPlatformContext = RyzePlatformContext
public typealias NovaNavigationModel = RyzeNavigationModel
public typealias NovaGradient = RyzeGradient
public typealias NovaSemanticColors = RyzeSemanticColors
public typealias NovaDesignTokens = RyzeDesignTokens
public typealias NovaButtonVariant = RyzeButtonVariant
public typealias NovaAdaptiveStackStyle = RyzeAdaptiveStackStyle
public typealias NovaSpacingToken = SpacingToken
public typealias NovaRadiusToken = RadiusToken
public typealias NovaFontSizeToken = FontSizeToken
public typealias NovaMotionToken = MotionToken
public typealias NovaBreakpoint = Breakpoint

// MARK: - Protocols

public typealias NovaThemeProtocol = RyzeThemeProtocol
public typealias NovaColorProtocol = RyzeColorProtocol
public typealias NovaSpacingProtocol = RyzeSpacingProtocol
public typealias NovaRadiusProtocol = RyzeRadiusProtocol
public typealias NovaSizeProtocol = RyzeSizeProtocol
public typealias NovaFontProtocol = RyzeFontProtocol
public typealias NovaFontFamilyProtocol = RyzeFontFamilyProtocol
public typealias NovaTextFieldMask = RyzeTextFieldMask
public typealias NovaTextFieldConfiguration = RyzeTextFieldConfiguration
public typealias NovaUIMock = RyzeUIMock

// MARK: - Errors & Enums

public typealias NovaUIError = RyzeUIError
public typealias NovaTextInputAutocapitalization = RyzeTextInputAutocapitalization
public typealias NovaTextFieldContentType = RyzeTextFieldContentType

// MARK: - View Modifiers Extensions

extension View {
    // MARK: - Accessibility

    /// Aplica prefixo personalizado às propriedades de acessibilidade
    public func nova(accessibility properties: RyzeAccessibilityProperties) -> some View {
        ryze(accessibility: properties)
    }

    /// Atalho para definir apenas testID com prefixo personalizado
    public func nova(testID: String) -> some View {
        ryze(testID: testID)
    }

    /// Aplica propriedades de acessibilidade usando builder pattern com prefixo personalizado
    public func nova(accessibility builder: (RyzeAccessibilityConfig) -> RyzeAccessibilityConfig) -> some View {
        ryze(accessibility: builder)
    }

    // MARK: - Style Modifiers

    /// Aplica cor de fundo com prefixo personalizado
    public func nova(background style: RyzeColor) -> some View {
        ryze(background: style)
    }

    /// Aplica cor de tint com prefixo personalizado
    public func nova(tint color: RyzeColor) -> some View {
        ryze(tint: color)
    }

    /// Aplica cor de foreground com prefixo personalizado
    public func nova(color: RyzeColor) -> some View {
        ryze(color: color)
    }

    // MARK: - Environment Modifiers

    /// Aplica tema com prefixo personalizado
    public func nova(theme: RyzeThemeProtocol) -> some View {
        ryze(theme: theme)
    }

    /// Aplica locale com prefixo personalizado
    public func nova(locale: RyzeLocale) -> some View {
        ryze(locale: locale)
    }

    /// Aplica color scheme com prefixo personalizado
    public func nova(colorScheme: ColorScheme? = nil) -> some View {
        ryze(colorScheme: colorScheme)
    }

    /// Aplica estado de loading com prefixo personalizado
    public func nova(loading: Bool) -> some View {
        ryze(loading: loading)
    }

    /// Aplica estado de disabled com prefixo personalizado
    public func nova(disabled: Bool) -> some View {
        ryze(disabled: disabled)
    }

    // MARK: - Text Modifiers

    /// Aplica alinhamento de texto com prefixo personalizado
    public func nova(alignment: TextAlignment) -> some View {
        ryze(alignment: alignment)
    }

    /// Aplica fonte com prefixo personalizado
    public func nova(
        font: Font = .body,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil
    ) -> some View {
        ryze(font: font, weight: weight, design: design)
    }

    // MARK: - Size & Spacing Modifiers

    /// Aplica tamanho com prefixo personalizado
    public func nova(
        width: RyzeSize? = nil,
        height: RyzeSize? = nil,
        alignment: Alignment = .center
    ) -> some View {
        ryze(width: width, height: height, alignment: alignment)
    }

    /// Aplica padding com prefixo personalizado
    public func novaPadding(
        _ edges: Edge.Set = .all,
        _ spacing: RyzeSpacing = .medium
    ) -> some View {
        ryzePadding(edges, spacing)
    }

    /// Aplica padding com prefixo personalizado (todas as bordas)
    public func novaPadding(
        _ spacing: RyzeSpacing = .medium
    ) -> some View {
        ryzePadding(spacing)
    }

    // MARK: - Background Modifiers

    /// Aplica background padrão com prefixo personalizado
    public func novaBackground() -> some View {
        ryzeBackground()
    }

    /// Aplica background secundário com prefixo personalizado
    public func novaBackgroundSecondary() -> some View {
        ryzeBackgroundSecondary()
    }

    /// Aplica background de row com prefixo personalizado
    public func novaBackgroundRow() -> some View {
        ryzeBackgroundRow()
    }

    // MARK: - Effect Modifiers

    /// Aplica efeito glow com prefixo personalizado
    public func novaGlow(for color: Color? = nil) -> some View {
        ryzeGlow(for: color)
    }

    /// Aplica efeito de símbolo com prefixo personalizado
    public func novaSymbol<T: IndefiniteSymbolEffect & SymbolEffect>(
        effect: T,
        options: SymbolEffectOptions = .default,
        isActive: Bool = true
    ) -> some View {
        ryzeSymbol(effect: effect, options: options, isActive: isActive)
    }

    /// Aplica efeito skeleton com prefixo personalizado
    public func novaSkeleton() -> some View {
        ryzeSkeleton()
    }

    /// Aplica efeito parallax com prefixo personalizado (iOS apenas)
    public func novaParallax(width: RyzeSize? = nil, height: RyzeSize?) -> some View {
        ryzeParallax(width: width, height: height)
    }

    /// Aplica efeito de confetti com prefixo personalizado
    public func novaConfetti(
        amount: Int = 30,
        seconds: Int = 4,
        isActive: Bool
    ) -> some View {
        ryzeConfetti(amount: amount, seconds: seconds, isActive: isActive)
    }

    // MARK: - Shape & Clip Modifiers

    /// Aplica clip de shape com prefixo personalizado
    public func nova(clip shape: RyzeShape) -> some View {
        ryze(clip: shape)
    }

    // MARK: - Screen & Display Modifiers

    /// Aplica observação de screen com prefixo personalizado
    public func novaScreenObserve(minimumWidthScreen: CGFloat = 430) -> some View {
        ryzeScreenObserve(minimumWidthScreen: minimumWidthScreen)
    }

    /// Aplica browser sheet com prefixo personalizado
    public func novaBrowser(url: Binding<URL?>) -> some View {
        ryzeBrowser(url: url)
    }

    // MARK: - Preview Modifiers

    /// Aplica preview com prefixo personalizado
    public func novaPreview(
        layout: PreviewLayout,
        orientation: InterfaceOrientation,
        colorScheme: ColorScheme,
        locale: RyzeLocale
    ) -> some View {
        ryzePreview(
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
        ryze(if: condition, transition: transition, animation: animation, transform: transform)
    }

    /// Aplica transformação condicional com item opcional
    public func nova<Content: View, Value>(
        item value: Value?,
        transform: (Self, Value) -> Content
    ) -> some View {
        ryze(item: value, transform: transform)
    }

    /// Aplica transformação condicional com else
    public func nova<Content: View, ElseContent: View>(
        if condition: Bool,
        transform: (Self) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        ryze(if: condition, transform: transform, else: `else`)
    }

    /// Aplica transformação condicional com item opcional e else
    public func nova<Content: View, Value, ElseContent: View>(
        item value: Value?,
        transform: (Self, Value) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        ryze(item: value, transform: transform, else: `else`)
    }
}
