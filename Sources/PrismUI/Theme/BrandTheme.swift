import SwiftUI

/// Customizable brand theme with configurable primary, secondary, and accent colors.
///
/// Use this theme to match your app's brand identity while keeping
/// the full token system intact.
///
/// ```swift
/// let myBrand = BrandTheme(
///     primary: .indigo,
///     secondary: .mint,
///     accent: .orange
/// )
/// ContentView()
///     .prismTheme(myBrand)
/// ```
public struct BrandTheme: PrismTheme, Sendable {

    private let primary: Color
    private let secondary: Color
    private let accent: Color

    /// Creates a brand theme with the given primary, secondary, and accent colors.
    public init(
        primary: Color = .blue,
        secondary: Color = .cyan,
        accent: Color = .orange
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
    }

    /// Resolves a color token to a concrete color using the brand palette.
    public func color(_ token: ColorToken) -> Color {
        switch token {
        case .brand: primary
        case .brandVariant: secondary

        case .background: platformBackground
        case .backgroundSecondary: platformBackgroundSecondary
        case .backgroundTertiary: platformBackgroundTertiary

        case .surface: platformBackground
        case .surfaceSecondary: platformBackgroundSecondary
        case .surfaceElevated: platformBackgroundTertiary

        case .onBackground: .primary
        case .onBackgroundSecondary: .secondary
        case .onBackgroundTertiary: .primary.opacity(0.3)
        case .onSurface: .primary
        case .onSurfaceSecondary: .secondary
        case .onBrand: .white

        case .border: platformSeparator
        case .borderSubtle: platformSeparator.opacity(0.5)
        case .separator: platformSeparator

        case .interactive: accent
        case .interactiveHover: accent.opacity(0.9)
        case .interactivePressed: accent.opacity(0.7)
        case .interactiveDisabled: .secondary.opacity(0.3)

        case .success: .green
        case .warning: .orange
        case .error: .red
        case .info: secondary

        case .shadow: .black.opacity(0.1)
        case .overlay: .black.opacity(0.4)
        }
    }
}

extension BrandTheme {

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
        Color(white: 0.11)
        #endif
    }

    private var platformBackgroundTertiary: Color {
        #if canImport(UIKit) && !os(watchOS)
        Color(.tertiarySystemBackground)
        #elseif os(macOS)
        Color(.underPageBackgroundColor)
        #else
        Color(white: 0.17)
        #endif
    }

    private var platformSeparator: Color {
        #if canImport(UIKit) && !os(watchOS)
        Color(.separator)
        #elseif os(macOS)
        Color(.separatorColor)
        #else
        .gray.opacity(0.3)
        #endif
    }
}
