//
//  PrismUIPrefixAliases.swift
//  PrismUI
//
//  Created by Rafael Escaleira on 09/04/26.
//
//  Typealiases file for Design System prefix customization.
//
//  TO USE: Copy this file to your project and change the "Nova" prefix
//  to your desired prefix. Example:
//
//  ```swift
//  // In your project:
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
public typealias NovaDivider = PrismDivider
public typealias NovaMenu = PrismMenu

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
public typealias NovaAlert = PrismAlert

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

    /// Applies custom prefix to accessibility properties.
    public func nova(accessibility properties: PrismAccessibilityProperties) -> some View {
        prism(accessibility: properties)
    }

    /// Shortcut to set only testID with custom prefix.
    public func nova(testID: String) -> some View {
        prism(testID: testID)
    }

    /// Applies accessibility properties using builder pattern with custom prefix.
    public func nova(accessibility builder: (PrismAccessibilityConfig) -> PrismAccessibilityConfig) -> some View {
        prism(accessibility: builder)
    }

    // MARK: - Style Modifiers

    /// Applies background color with custom prefix.
    public func nova(background style: PrismColor) -> some View {
        prism(background: style)
    }

    /// Applies tint color with custom prefix.
    public func nova(tint color: PrismColor) -> some View {
        prism(tint: color)
    }

    /// Applies foreground color with custom prefix.
    public func nova(color: PrismColor) -> some View {
        prism(color: color)
    }

    // MARK: - Environment Modifiers

    /// Applies theme with custom prefix.
    public func nova(theme: PrismThemeProtocol) -> some View {
        prism(theme: theme)
    }

    /// Applies locale with custom prefix.
    public func nova(locale: PrismLocale) -> some View {
        prism(locale: locale)
    }

    /// Applies color scheme with custom prefix.
    public func nova(colorScheme: ColorScheme? = nil) -> some View {
        prism(colorScheme: colorScheme)
    }

    /// Applies loading state with custom prefix.
    public func nova(loading: Bool) -> some View {
        prism(loading: loading)
    }

    /// Applies disabled state with custom prefix.
    public func nova(disabled: Bool) -> some View {
        prism(disabled: disabled)
    }

    // MARK: - Text Modifiers

    /// Applies text alignment with custom prefix.
    public func nova(alignment: TextAlignment) -> some View {
        prism(alignment: alignment)
    }

    /// Applies font with custom prefix.
    public func nova(
        font: Font = .body,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil
    ) -> some View {
        prism(font: font, weight: weight, design: design)
    }

    // MARK: - Size & Spacing Modifiers

    /// Applies size with custom prefix.
    public func nova(
        width: PrismSize? = nil,
        height: PrismSize? = nil,
        alignment: Alignment = .center
    ) -> some View {
        prism(width: width, height: height, alignment: alignment)
    }

    /// Applies padding with custom prefix.
    public func novaPadding(
        _ edges: Edge.Set = .all,
        _ spacing: PrismSpacing = .medium
    ) -> some View {
        prismPadding(edges, spacing)
    }

    /// Applies padding with custom prefix (all edges).
    public func novaPadding(
        _ spacing: PrismSpacing = .medium
    ) -> some View {
        prismPadding(spacing)
    }

    // MARK: - Background Modifiers

    /// Applies default background with custom prefix.
    public func novaBackground() -> some View {
        prismBackground()
    }

    /// Applies secondary background with custom prefix.
    public func novaBackgroundSecondary() -> some View {
        prismBackgroundSecondary()
    }

    /// Applies row background with custom prefix.
    public func novaBackgroundRow() -> some View {
        prismBackgroundRow()
    }

    // MARK: - Effect Modifiers

    /// Applies glow effect with custom prefix.
    public func novaGlow(for color: Color? = nil) -> some View {
        prismGlow(for: color)
    }

    /// Applies symbol effect with custom prefix.
    public func novaSymbol<T: IndefiniteSymbolEffect & SymbolEffect>(
        effect: T,
        options: SymbolEffectOptions = .default,
        isActive: Bool = true
    ) -> some View {
        prismSymbol(effect: effect, options: options, isActive: isActive)
    }

    /// Applies skeleton effect with custom prefix.
    public func novaSkeleton() -> some View {
        prismSkeleton()
    }

    /// Applies parallax effect with custom prefix (iOS only).
    public func novaParallax(width: PrismSize? = nil, height: PrismSize?) -> some View {
        prismParallax(width: width, height: height)
    }

    /// Applies confetti effect with custom prefix.
    public func novaConfetti(
        amount: Int = 30,
        seconds: Int = 4,
        isActive: Bool
    ) -> some View {
        prismConfetti(amount: amount, seconds: seconds, isActive: isActive)
    }

    // MARK: - Shape & Clip Modifiers

    /// Applies shape clip with custom prefix.
    public func nova(clip shape: PrismShape) -> some View {
        prism(clip: shape)
    }

    // MARK: - Screen & Display Modifiers

    /// Applies screen observation with custom prefix.
    public func novaScreenObserve(minimumWidthScreen: CGFloat = 430) -> some View {
        prismScreenObserve(minimumWidthScreen: minimumWidthScreen)
    }

    /// Applies browser sheet with custom prefix.
    public func novaBrowser(url: Binding<URL?>) -> some View {
        prismBrowser(url: url)
    }

    // MARK: - Preview Modifiers

    /// Applies preview with custom prefix.
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

    /// Applies conditional transformation with custom prefix.
    public func nova<Content: View>(
        if condition: Bool,
        transition: AnyTransition = .scale,
        animation: Animation? = .linear,
        transform: (Self) -> Content
    ) -> some View {
        prism(if: condition, transition: transition, animation: animation, transform: transform)
    }

    /// Applies conditional transformation with optional item.
    public func nova<Content: View, Value>(
        item value: Value?,
        transform: (Self, Value) -> Content
    ) -> some View {
        prism(item: value, transform: transform)
    }

    /// Applies conditional transformation with else.
    public func nova<Content: View, ElseContent: View>(
        if condition: Bool,
        transform: (Self) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        prism(if: condition, transform: transform, else: `else`)
    }

    /// Applies conditional transformation with optional item and else.
    public func nova<Content: View, Value, ElseContent: View>(
        item value: Value?,
        transform: (Self, Value) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        prism(item: value, transform: transform, else: `else`)
    }
}
