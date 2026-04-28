import SwiftUI
import Testing

@testable import PrismUI

@MainActor
struct ThemeVariantTests {

    // MARK: - DarkTheme

    @Test
    func darkThemeResolvesAllTokens() {
        let issues = PrismThemeTest.validateAllColors(DarkTheme())
        #expect(issues.isEmpty, "DarkTheme unresolved: \(issues)")
    }

    @Test
    func darkThemeFeedbackColorsDistinct() {
        #expect(PrismThemeTest.validateFeedbackColorsDistinct(DarkTheme()))
    }

    @Test
    func darkThemeInteractiveStatesValid() {
        #expect(PrismThemeTest.validateInteractiveStates(DarkTheme()))
    }

    // MARK: - HighContrastTheme

    @Test
    func highContrastResolvesAllTokens() {
        let issues = PrismThemeTest.validateAllColors(HighContrastTheme())
        #expect(issues.isEmpty, "HighContrastTheme unresolved: \(issues)")
    }

    @Test
    func highContrastFeedbackColorsDistinct() {
        #expect(PrismThemeTest.validateFeedbackColorsDistinct(HighContrastTheme()))
    }

    @Test
    func highContrastInteractiveStatesValid() {
        #expect(PrismThemeTest.validateInteractiveStates(HighContrastTheme()))
    }

    // MARK: - BrandTheme

    @Test
    func brandThemeResolvesAllTokens() {
        let issues = PrismThemeTest.validateAllColors(BrandTheme())
        #expect(issues.isEmpty, "BrandTheme unresolved: \(issues)")
    }

    @Test
    func brandThemeCustomColorsApply() {
        let theme = BrandTheme(primary: .purple, secondary: .mint, accent: .orange)
        #expect(theme.color(.brand).description != DefaultTheme().color(.brand).description)
    }

    @Test
    func brandThemeFeedbackColorsDistinct() {
        #expect(PrismThemeTest.validateFeedbackColorsDistinct(BrandTheme()))
    }

    @Test
    func brandThemeInteractiveUsesAccent() {
        let theme = BrandTheme(primary: .purple, secondary: .mint, accent: .orange)
        let interactive = theme.color(.interactive).description
        let brand = theme.color(.brand).description
        #expect(interactive != brand)
    }

    // MARK: - Cross-theme Validation

    @Test
    func defaultThemeFeedbackDistinct() {
        #expect(PrismThemeTest.validateFeedbackColorsDistinct(DefaultTheme()))
    }

    @Test
    func allBuiltInThemesResolveAllTokens() {
        #expect(PrismThemeTest.validateAllColors(DefaultTheme()).isEmpty)
        #expect(PrismThemeTest.validateAllColors(DarkTheme()).isEmpty)
        #expect(PrismThemeTest.validateAllColors(HighContrastTheme()).isEmpty)
        #expect(PrismThemeTest.validateAllColors(BrandTheme()).isEmpty)
    }
}
