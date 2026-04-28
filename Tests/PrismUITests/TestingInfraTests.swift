import SwiftUI
import Testing

@testable import PrismUI

@MainActor
struct TestingInfraTests {

    // MARK: - PrismThemeTest

    @Test
    func defaultThemePassesAllColorValidation() {
        let issues = PrismThemeTest.validateAllColors(DefaultTheme())
        #expect(issues.isEmpty, "Unresolved tokens: \(issues)")
    }

    @Test
    func defaultThemeFeedbackColorsAreDistinct() {
        let result = PrismThemeTest.validateFeedbackColorsDistinct(DefaultTheme())
        #expect(result)
    }

    @Test
    func defaultThemeInteractiveStatesFormHierarchy() {
        let result = PrismThemeTest.validateInteractiveStates(DefaultTheme())
        #expect(result)
    }

    // MARK: - PrismAccessibilityTest

    @Test
    func minimumTapTargetValidation() {
        #expect(PrismAccessibilityTest.validateMinimumTapTarget(width: 44, height: 44))
        #expect(PrismAccessibilityTest.validateMinimumTapTarget(width: 60, height: 50))
        #expect(!PrismAccessibilityTest.validateMinimumTapTarget(width: 30, height: 30))
        #expect(!PrismAccessibilityTest.validateMinimumTapTarget(width: 44, height: 40))
    }

    @Test
    func contrastRatioBlackOnWhitePasses() {
        let passes = PrismAccessibilityTest.validateContrastRatio(
            foreground: .black,
            background: .white
        )
        #expect(passes)
    }

    @Test
    func contrastRatioLightOnLightFails() {
        let passes = PrismAccessibilityTest.validateContrastRatio(
            foreground: Color(white: 0.85),
            background: .white
        )
        #expect(!passes)
    }

    @Test
    func contrastRatioLargeTextHasLowerThreshold() {
        let passes = PrismAccessibilityTest.validateContrastRatio(
            foreground: Color(white: 0.45),
            background: .white,
            isLargeText: true
        )
        #expect(passes)
    }

    // MARK: - PrismPreviewCatalog

    @Test
    func previewCatalogCreatesSuccessfully() {
        let catalog = PrismPreviewCatalog {
            Text("Test Component")
        }
        #expect(catalog != nil)
    }
}
