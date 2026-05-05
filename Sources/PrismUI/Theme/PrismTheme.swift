import SwiftUI

/// Contract for a complete Prism design theme.
///
/// Implement this protocol to provide a custom color palette
/// while keeping all other design tokens consistent.
@MainActor
public protocol PrismTheme: Sendable {
    func color(_ token: ColorToken) -> Color
}

/// Default theme using Apple HIG system colors.
public struct DefaultTheme: PrismTheme, Sendable {

    /// Creates a default theme instance.
    public init() {}

    // swiftlint:disable:next cyclomatic_complexity
    /// Resolves a color token to a concrete color using system-adaptive defaults.
    public func color(_ token: ColorToken) -> Color {
        switch token {
        case .brand: .accentColor
        case .brandVariant: .accentColor.opacity(0.8)

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

        case .interactive: .accentColor
        case .interactiveHover: .accentColor.opacity(0.9)
        case .interactivePressed: .accentColor.opacity(0.7)
        case .interactiveDisabled: .secondary.opacity(0.3)

        case .success: .green
        case .warning: .orange
        case .error: .red
        case .info: .blue

        case .shadow: .black.opacity(0.1)
        case .overlay: .black.opacity(0.4)
        }
    }
}

// MARK: - Platform-Adaptive System Colors

extension DefaultTheme {

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
