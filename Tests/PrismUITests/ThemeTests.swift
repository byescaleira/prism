import SwiftUI
import Testing

@testable import PrismUI

@MainActor
struct ThemeTests {

    @Test
    func defaultThemeResolvesAllColorTokens() {
        let theme = DefaultTheme()
        for token in ColorToken.allCases {
            let color = theme.color(token)
            #expect(color.description.isEmpty == false, "Token \(token) should resolve")
        }
    }

    @Test
    func defaultThemeBrandUsesAccentColor() {
        let theme = DefaultTheme()
        let brand = theme.color(.brand)
        #expect(brand == .accentColor)
    }

    @Test
    func defaultThemeFeedbackColorsAreDistinct() {
        let theme = DefaultTheme()
        let success = theme.color(.success)
        let warning = theme.color(.warning)
        let error = theme.color(.error)
        let info = theme.color(.info)

        #expect(success != warning)
        #expect(warning != error)
        #expect(error != info)
    }

    @Test
    func customThemeOverridesColors() {
        let theme = TestTheme()
        #expect(theme.color(.brand) == .purple)
    }
}

// MARK: - Test Fixtures

private struct TestTheme: PrismTheme {
    func color(_ token: ColorToken) -> Color {
        switch token {
        case .brand: .purple
        default: .gray
        }
    }
}
