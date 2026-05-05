import SwiftUI

/// High-contrast theme for enhanced readability and accessibility.
///
/// Maximizes contrast ratios beyond WCAG AAA standards. Uses pure black
/// and white for backgrounds/text, bolder borders, and saturated feedback colors.
///
/// ```swift
/// ContentView()
///     .prismTheme(HighContrastTheme())
/// ```
public struct HighContrastTheme: PrismTheme, Sendable {

    /// Creates a high-contrast theme instance.
    public init() {}

    /// Resolves a color token to a concrete color using the high-contrast palette.
    public func color(_ token: ColorToken) -> Color {
        switch token {
        case .brand: .accentColor
        case .brandVariant: .accentColor.opacity(0.85)

        case .background: platformBackground
        case .backgroundSecondary: platformBackgroundSecondary
        case .backgroundTertiary: platformBackgroundTertiary

        case .surface: platformBackground
        case .surfaceSecondary: platformBackgroundSecondary
        case .surfaceElevated: platformBackgroundTertiary

        case .onBackground: platformForeground
        case .onBackgroundSecondary: platformForeground.opacity(0.8)
        case .onBackgroundTertiary: platformForeground.opacity(0.6)
        case .onSurface: platformForeground
        case .onSurfaceSecondary: platformForeground.opacity(0.75)
        case .onBrand: .white

        case .border: platformForeground.opacity(0.5)
        case .borderSubtle: platformForeground.opacity(0.3)
        case .separator: platformForeground.opacity(0.4)

        case .interactive: .accentColor
        case .interactiveHover: .accentColor.opacity(0.85)
        case .interactivePressed: .accentColor.opacity(0.65)
        case .interactiveDisabled: platformForeground.opacity(0.35)

        case .success: Color(red: 0.0, green: 0.55, blue: 0.1)
        case .warning: Color(red: 0.7, green: 0.4, blue: 0.0)
        case .error: Color(red: 0.9, green: 0.1, blue: 0.1)
        case .info: Color(red: 0.0, green: 0.4, blue: 0.9)

        case .shadow: .black.opacity(0.25)
        case .overlay: .black.opacity(0.7)
        }
    }
}

extension HighContrastTheme {

    private var platformBackground: Color {
        #if canImport(UIKit) && !os(watchOS)
            Color(.systemBackground)
        #elseif os(macOS)
            Color(.windowBackgroundColor)
        #else
            .black
        #endif
    }

    private var platformBackgroundSecondary: Color {
        #if canImport(UIKit) && !os(watchOS)
            Color(.secondarySystemBackground)
        #elseif os(macOS)
            Color(.controlBackgroundColor)
        #else
            Color(white: 0.08)
        #endif
    }

    private var platformBackgroundTertiary: Color {
        #if canImport(UIKit) && !os(watchOS)
            Color(.tertiarySystemBackground)
        #elseif os(macOS)
            Color(.underPageBackgroundColor)
        #else
            Color(white: 0.14)
        #endif
    }

    private var platformForeground: Color {
        #if canImport(UIKit) && !os(watchOS)
            Color(.label)
        #elseif os(macOS)
            Color(.labelColor)
        #else
            .white
        #endif
    }
}
