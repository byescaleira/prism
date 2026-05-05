import SwiftUI

/// Dark-only theme that ignores the system appearance setting.
///
/// Forces dark surfaces and light content regardless of `colorScheme`.
/// Useful for media apps, cinematic UIs, and always-dark sections.
///
/// ```swift
/// ContentView()
///     .prismTheme(DarkTheme())
/// ```
public struct DarkTheme: PrismTheme, Sendable {

    /// Creates a dark theme instance.
    public init() {}

    /// Resolves a color token to a concrete color using the dark palette.
    public func color(_ token: ColorToken) -> Color {
        switch token {
        case .brand: .accentColor
        case .brandVariant: .accentColor.opacity(0.8)

        case .background: Color(white: 0.05)
        case .backgroundSecondary: Color(white: 0.10)
        case .backgroundTertiary: Color(white: 0.15)

        case .surface: Color(white: 0.10)
        case .surfaceSecondary: Color(white: 0.14)
        case .surfaceElevated: Color(white: 0.18)

        case .onBackground: .white
        case .onBackgroundSecondary: .white.opacity(0.7)
        case .onBackgroundTertiary: .white.opacity(0.35)
        case .onSurface: .white
        case .onSurfaceSecondary: .white.opacity(0.65)
        case .onBrand: .white

        case .border: .white.opacity(0.15)
        case .borderSubtle: .white.opacity(0.08)
        case .separator: .white.opacity(0.12)

        case .interactive: .accentColor
        case .interactiveHover: .accentColor.opacity(0.9)
        case .interactivePressed: .accentColor.opacity(0.7)
        case .interactiveDisabled: .white.opacity(0.2)

        case .success: Color(red: 0.3, green: 0.85, blue: 0.4)
        case .warning: Color(red: 1.0, green: 0.8, blue: 0.3)
        case .error: Color(red: 1.0, green: 0.4, blue: 0.35)
        case .info: Color(red: 0.35, green: 0.65, blue: 1.0)

        case .shadow: .black.opacity(0.3)
        case .overlay: .black.opacity(0.6)
        }
    }
}
