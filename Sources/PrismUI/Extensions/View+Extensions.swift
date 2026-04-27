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

// MARK: - PrismUI Design System View Modifiers
///
/// This extension provides all PrismUI Design System view modifiers.
/// Modifiers follow the `prism()` naming convention for consistency.
///
/// ## Modifier Categories
///
/// ### Style Modifiers
/// - `prism(background:)` - Applies background color
/// - `prism(tint:)` - Applies tint color (buttons, links)
/// - `prism(color:)` - Applies foreground color
///
/// ### Environment Modifiers
/// - `prism(theme:)` - Applies Design System theme
/// - `prism(locale:)` - Sets locale
/// - `prism(colorScheme:)` - Forces light/dark mode
/// - `prism(loading:)` - Enables loading state (skeleton)
/// - `prism(disabled:)` - Enables disabled state
///
/// ### Text Modifiers
/// - `prism(alignment:)` - Multi-line text alignment
/// - `prism(font:weight:design:)` - Full typography
///
/// ### Size & Spacing Modifiers
/// - `prism(width:height:alignment:)` - Semantic dimensions
/// - `prismPadding(_:_:)` - Padding with PrismSpacing tokens
///
/// ### Background Modifiers
/// - `prismBackground()` - Default theme background
/// - `prismBackgroundSecondary()` - Secondary background
/// - `prismBackgroundRow()` - Adaptive row background
///
/// ### Effect Modifiers
/// - `prismGlow(for:)` - Animated glow effect
/// - `prismSymbol(effect:options:isActive:)` - Symbol effects
/// - `prismSkeleton()` - Skeleton/loading state
/// - `prismParallax(width:height:)` - 3D parallax effect (iOS)
/// - `prismConfetti(amount:seconds:isActive:)` - Confetti rain
///
/// ### Shape & Clip Modifiers
/// - `prism(clip:)` - Applies shape as clip
///
/// ### Screen & Display Modifiers
/// - `prismScreenObserve(minimumWidthScreen:)` - Observes screen size
/// - `prismBrowser(url:)` - Presents browser in sheet
///
/// ### Preview Modifiers
/// - `prismPreview(layout:orientation:colorScheme:locale:)` - Configures preview
///
/// ### Accessibility Modifiers
/// - `prism(_:)` - Applies accessibility properties
///
/// ### Conditional Modifiers
/// - `prism(if:transform:)` - Conditional transform
/// - `prism(item:transform:)` - Optional item transform
/// - `prism(if:transform:else:)` - Transform with else
/// - `prism(item:transform:else:)` - Transform with item and else
///
/// ## Combined Usage Example
/// ```swift
/// PrismVStack {
///     PrismText("Title")
///         .prism(font: .headline)
///     PrismText("Description")
///         .prism(color: .textSecondary)
/// }
/// .prismPadding()
/// .prismBackgroundSecondary()
/// .prism(clip: .rounded(radius: .medium))
/// .prism(loading: isLoading)
/// ```
extension View {
    /// Applies a ``PrismColor`` as the view's background.
    ///
    /// - Parameter style: The design-system color to use as background.
    /// - Returns: A view with the specified background color applied.
    public func prism(background style: PrismColor) -> some View {
        self.background(style)
    }

    /// Applies a ``PrismColor`` as the view's tint, affecting interactive elements like buttons and links.
    ///
    /// - Parameter color: The design-system color to use as tint.
    /// - Returns: A view with the specified tint color applied.
    public func prism(tint color: PrismColor) -> some View {
        self.tint(color)
    }

    /// Applies a ``PrismColor`` as the view's foreground style.
    ///
    /// - Parameter color: The design-system color to use as foreground.
    /// - Returns: A view with the specified foreground color applied.
    public func prism(color: PrismColor) -> some View {
        self.foregroundStyle(color)
    }

    /// Injects a PrismUI design-system theme into the view's environment.
    ///
    /// The theme is erased to ``PrismTheme`` and its tokens are propagated
    /// via both `\.theme` and `\.designTokens` environment keys.
    ///
    /// - Parameter theme: A theme conforming to ``PrismThemeProtocol``.
    /// - Returns: A view with the specified theme applied to its environment.
    public func prism(theme: PrismThemeProtocol) -> some View {
        self.modifier(
            PrismThemeModifier(
                theme: theme.eraseToAnyTheme()
            )
        )
    }

    /// Overrides the current theme's design tokens while preserving the theme itself.
    ///
    /// - Parameter tokens: The ``PrismDesignTokens`` to apply.
    /// - Returns: A view with the overridden design tokens in its environment.
    public func prism(tokens: PrismDesignTokens) -> some View {
        self.modifier(PrismTokensModifier(tokens: tokens))
    }

    /// Sets the locale for the view hierarchy using a ``PrismLocale``.
    ///
    /// - Parameter locale: The locale to apply.
    /// - Returns: A view with the specified locale in its environment.
    public func prism(locale: PrismLocale) -> some View {
        self.environment(\.locale, locale.rawValue)
    }

    /// Injects a ``PrismLocaleManager`` and applies its current locale.
    ///
    /// The view hierarchy will update automatically when the manager's
    /// ``PrismLocaleManager/current`` property changes.
    ///
    /// - Parameter localeManager: The locale manager to inject.
    /// - Returns: A view with the locale manager and its locale applied.
    public func prism(localeManager: PrismLocaleManager) -> some View {
        self
            .environment(\.localeManager, localeManager)
            .environment(\.locale, localeManager.current.rawValue)
    }

    /// Injects an analytics provider for automatic component tracking.
    ///
    /// Once set, PrismUI components (buttons, text fields, carousels, etc.)
    /// will automatically emit events to this provider.
    ///
    /// - Parameter analytics: The analytics provider to use.
    /// - Returns: A view with the analytics provider in its environment.
    public func prism(analytics: any PrismAnalyticsProvider) -> some View {
        self.environment(\.analyticsProvider, analytics)
    }

    /// Forces a preferred color scheme (light or dark) on the view.
    ///
    /// - Parameter colorScheme: The color scheme to apply, or `nil` to follow the system setting.
    /// - Returns: A view with the preferred color scheme applied.
    public func prism(colorScheme: ColorScheme? = nil) -> some View {
        self.preferredColorScheme(colorScheme)
    }

    /// Sets the loading state in the view's environment, enabling skeleton placeholders.
    ///
    /// - Parameter loading: Whether the view hierarchy is in a loading state.
    /// - Returns: A view with the `isLoading` environment value set.
    public func prism(loading: Bool) -> some View {
        self.environment(\.isLoading, loading)
    }

    /// Sets the disabled state in the view's environment.
    ///
    /// - Parameter disabled: Whether the view hierarchy should be disabled.
    /// - Returns: A view with the `isDisabled` environment value set.
    public func prism(disabled: Bool) -> some View {
        self.environment(\.isDisabled, disabled)
    }

    /// Sets the multiline text alignment for the view.
    ///
    /// - Parameter alignment: The text alignment (`.leading`, `.center`, `.trailing`).
    /// - Returns: A view with the specified multiline text alignment.
    public func prism(alignment: TextAlignment) -> some View {
        self.multilineTextAlignment(alignment)
    }

    /// Applies font, weight, and design to the view in a single call.
    ///
    /// - Parameters:
    ///   - font: The font to apply. Defaults to `.body`.
    ///   - weight: An optional font weight override.
    ///   - design: An optional font design override (e.g., `.rounded`, `.monospaced`).
    /// - Returns: A view with the specified typography applied.
    public func prism(
        font: Font = .body,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil
    ) -> some View {
        self.font(font)
            .fontWeight(weight)
            .fontDesign(design)
    }

    /// Sets the view's dimensions using semantic ``PrismSize`` tokens.
    ///
    /// - Parameters:
    ///   - width: An optional semantic width token.
    ///   - height: An optional semantic height token.
    ///   - alignment: The alignment of the content within the frame. Defaults to `.center`.
    /// - Returns: A view with the specified semantic dimensions applied.
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

    /// Adds padding to the view using ``PrismSpacing`` design tokens.
    ///
    /// - Parameters:
    ///   - edges: The edges to pad. Defaults to `.all`.
    ///   - spacing: The spacing token to use. Defaults to `.medium`.
    /// - Returns: A view with token-based padding applied.
    public func prismPadding(
        _ edges: Edge.Set = .all,
        _ spacing: PrismSpacing = .medium
    ) -> some View {
        self.modifier(PrismSpacingModifier(edges: edges, spacing: spacing))
    }

    /// Adds uniform padding on all edges using a ``PrismSpacing`` design token.
    ///
    /// - Parameter spacing: The spacing token to use. Defaults to `.medium`.
    /// - Returns: A view with token-based padding on all edges.
    public func prismPadding(
        _ spacing: PrismSpacing = .medium
    ) -> some View {
        self.modifier(PrismSpacingModifier(edges: .all, spacing: spacing))
    }

    /// Applies the primary theme background to the view.
    ///
    /// - Returns: A view with the default theme background color applied.
    public func prismBackground() -> some View {
        self.modifier(PrismBackgroundModifier())
    }

    /// Applies the secondary theme background to the view.
    ///
    /// - Returns: A view with the secondary theme background color applied.
    public func prismBackgroundSecondary() -> some View {
        self.modifier(PrismBackgroundSecondaryModifier())
    }

    /// Applies an adaptive row background suitable for list rows and cards.
    ///
    /// - Returns: A view with the adaptive row background applied.
    public func prismBackgroundRow() -> some View {
        self.modifier(PrismBackgroundRowModifier())
    }

    /// Adds an animated glow effect around the view.
    ///
    /// - Parameter color: The glow color. When `nil`, the theme's primary color is used.
    /// - Returns: A view with an animated glow effect applied.
    public func prismGlow(for color: Color? = nil) -> some View {
        self.modifier(PrismGlowModifier(color: color))
    }

    /// Applies an indefinite symbol effect to SF Symbol images.
    ///
    /// - Parameters:
    ///   - effect: The symbol effect to apply (e.g., `.bounce`, `.pulse`).
    ///   - options: Symbol effect options. Defaults to `.default`.
    ///   - isActive: Whether the effect is active. Defaults to `true`.
    /// - Returns: A view with the symbol effect applied.
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

    /// Conditionally applies a transform to the view with an animated transition.
    ///
    /// When `condition` is `true`, the `transform` closure is applied; otherwise
    /// the original view is shown. The change is animated using the specified transition.
    ///
    /// - Parameters:
    ///   - condition: The boolean condition to evaluate.
    ///   - transition: The transition to use. Defaults to `.scale`.
    ///   - animation: The animation to use. Defaults to `.linear`.
    ///   - transform: A closure that transforms the view when the condition is `true`.
    /// - Returns: The original or transformed view, animated on state change.
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

    /// Conditionally applies a transform when an optional value is non-nil.
    ///
    /// - Parameters:
    ///   - value: An optional value to unwrap.
    ///   - transform: A closure receiving the view and the unwrapped value.
    /// - Returns: The transformed view if `value` is non-nil, otherwise the original view.
    @ViewBuilder
    public func prism<Content: View, Value>(
        item value: Value?,
        transform: (Self, Value) -> Content
    ) -> some View {
        if let value { transform(self, value) } else { self }
    }

    /// Conditionally applies one of two transforms based on a boolean condition.
    ///
    /// - Parameters:
    ///   - condition: The boolean condition to evaluate.
    ///   - transform: A closure applied when `condition` is `true`.
    ///   - else: An optional closure applied when `condition` is `false`.
    /// - Returns: The result of the matching transform, or the original view if no `else` is provided.
    @ViewBuilder
    public func prism<Content: View, ElseContent: View>(
        if condition: Bool,
        transform: (Self) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        if condition { transform(self) } else if let `else` { `else`(self) } else { self }
    }

    /// Conditionally applies a transform when an optional value is non-nil, with an else fallback.
    ///
    /// - Parameters:
    ///   - value: An optional value to unwrap.
    ///   - transform: A closure receiving the view and the unwrapped value.
    ///   - else: An optional closure applied when `value` is `nil`.
    /// - Returns: The result of the matching transform, or the original view if no `else` is provided.
    @ViewBuilder
    public func prism<Content: View, Value, ElseContent: View>(
        item value: Value?,
        transform: (Self, Value) -> Content,
        `else`: ((Self) -> ElseContent)? = nil
    ) -> some View {
        if let value { transform(self, value) } else if let `else` { `else`(self) } else { self }
    }

    /// Applies a skeleton loading placeholder effect to the view.
    ///
    /// The skeleton is displayed when the `isLoading` environment value is `true`.
    ///
    /// - Returns: A view that shows a shimmer placeholder when loading.
    public func prismSkeleton() -> some View {
        self.modifier(PrismSkeletonModifier())
    }

    /// Applies a 3D parallax tilt effect driven by device motion (iOS only).
    ///
    /// On non-iOS platforms this modifier is a no-op.
    ///
    /// - Parameters:
    ///   - width: An optional semantic width for the parallax container.
    ///   - height: An optional semantic height for the parallax container.
    /// - Returns: A view with the parallax effect applied on iOS.
    @ViewBuilder
    public func prismParallax(width: PrismSize? = nil, height: PrismSize?) -> some View {
        #if os(iOS)
            self.modifier(PrismParallaxModifier(width: width, height: height))
        #else
            self
        #endif
    }

    /// Clips the view using a ``PrismShape``.
    ///
    /// - Parameter shape: The design-system shape to use as a clipping mask.
    /// - Returns: A view clipped to the specified shape.
    public func prism(clip shape: PrismShape) -> some View {
        self.clipShape(shape)
    }

    /// Configures the view for Xcode previews with layout, orientation, color scheme, and locale.
    ///
    /// Combines padding, background, locale, layout, orientation, color scheme, and a
    /// descriptive display name into a single convenience modifier.
    ///
    /// - Parameters:
    ///   - layout: The preview layout (`.sizeThatFits`, `.fixed`, etc.).
    ///   - orientation: The simulated interface orientation.
    ///   - colorScheme: The color scheme to preview.
    ///   - locale: The ``PrismLocale`` to apply.
    /// - Returns: A view configured for Xcode preview display.
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

    /// Applies optional ``PrismAccessibilityProperties`` to the view.
    ///
    /// When `accessibility` is `nil`, no accessibility modifications are applied.
    ///
    /// - Parameter accessibility: The accessibility properties to apply, or `nil`.
    /// - Returns: A view with the accessibility properties applied when present.
    @ViewBuilder
    public func prism(_ accessibility: PrismAccessibilityProperties?) -> some View {
        if let accessibility {
            self.modifier(PrismAccessibilityModifier(properties: accessibility))
        } else {
            self
        }
    }

    /// Observes the screen size and publishes layout information to the environment.
    ///
    /// Sets `screenSize` and `isLargeScreen` environment values based on the current geometry.
    ///
    /// - Parameter minimumWidthScreen: The minimum width threshold for large-screen layout. Defaults to `430`.
    /// - Returns: A view that observes and publishes screen-size environment values.
    public func prismScreenObserve(minimumWidthScreen: CGFloat = 430) -> some View {
        self.modifier(PrismScreenModifier(minimumWidthScreen: minimumWidthScreen))
    }

    /// Triggers a confetti rain animation overlay on the view.
    ///
    /// - Parameters:
    ///   - amount: The number of confetti particles. Defaults to `30`.
    ///   - seconds: The duration in seconds for the confetti animation. Defaults to `4`.
    ///   - isActive: Whether the confetti effect is currently active.
    /// - Returns: A view with a confetti animation overlay.
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

    /// Tracks a custom analytics event when the view appears.
    ///
    /// - Parameter event: The event to track on appearance.
    /// - Returns: A view that emits the analytics event on appear.
    public func prismTrack(_ event: PrismAnalyticsEvent) -> some View {
        self.modifier(PrismAnalyticsTrackModifier(event: event))
    }

    /// Presents an in-app browser sheet when the bound URL is non-nil.
    ///
    /// Setting the URL to `nil` dismisses the sheet.
    ///
    /// - Parameter url: A binding to the URL to display. When non-nil, the browser is presented.
    /// - Returns: A view that presents a ``PrismBrowser`` sheet.
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
