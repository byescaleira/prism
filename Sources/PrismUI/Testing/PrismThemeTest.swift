import SwiftUI

/// Test utility for verifying theme token resolution.
///
/// Use in unit tests to assert that a custom theme correctly resolves all tokens.
/// ```swift
/// @Test func customThemeResolvesAll() {
///     let issues = PrismThemeTest.validateAllColors(MyTheme())
///     #expect(issues.isEmpty, "Unresolved tokens: \(issues)")
/// }
/// ```
@MainActor
public enum PrismThemeTest {

    /// Validates that a theme produces a non-clear color for every `ColorToken`.
    public static func validateAllColors(_ theme: some PrismTheme) -> [ColorToken] {
        ColorToken.allCases.filter { token in
            theme.color(token) == .clear
        }
    }

    /// Validates that feedback colors are mutually distinct.
    public static func validateFeedbackColorsDistinct(_ theme: some PrismTheme) -> Bool {
        let feedbackTokens: [ColorToken] = [.success, .warning, .error, .info]
        let colors = feedbackTokens.map { theme.color($0).description }
        return Set(colors).count == feedbackTokens.count
    }

    /// Validates that interactive state colors form a visual hierarchy.
    public static func validateInteractiveStates(_ theme: some PrismTheme) -> Bool {
        let base = theme.color(.interactive).description
        let hover = theme.color(.interactiveHover).description
        let pressed = theme.color(.interactivePressed).description
        let disabled = theme.color(.interactiveDisabled).description
        return Set([base, hover, pressed, disabled]).count >= 3
    }
}
