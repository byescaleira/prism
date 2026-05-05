import SwiftUI
import Testing

@testable import PrismUI

@MainActor
struct AccessibilityAuditTests {

    // MARK: - Tap Target Compliance

    @Test
    func buttonMeetsMinimumTapTarget() {
        #expect(PrismAccessibilityTest.validateMinimumTapTarget(width: 44, height: 44))
    }

    @Test
    func smallTargetFailsValidation() {
        #expect(!PrismAccessibilityTest.validateMinimumTapTarget(width: 30, height: 30))
    }

    @Test
    func rowMeetsMinimumTapTarget() {
        #expect(PrismAccessibilityTest.validateMinimumTapTarget(width: 375, height: 44))
    }

    // MARK: - Contrast Ratio

    @Test
    func primaryTextOnBackgroundPassesAA() {
        let theme = DefaultTheme()
        #expect(
            PrismAccessibilityTest.validateContrastRatio(
                foreground: .black, background: .white
            ))
    }

    @Test
    func darkThemeTextContrast() {
        let theme = DarkTheme()
        #expect(
            PrismAccessibilityTest.validateContrastRatio(
                foreground: .white, background: Color(white: 0.05)
            ))
    }

    @Test
    func highContrastThemeExceedsAAA() {
        #expect(
            PrismAccessibilityTest.validateContrastRatio(
                foreground: .black, background: .white
            ))
    }

    @Test
    func errorAndInfoOnWhitePassLargeText() {
        let theme = DefaultTheme()
        #expect(
            PrismAccessibilityTest.validateContrastRatio(
                foreground: theme.color(.error), background: .white, isLargeText: true
            ))
        #expect(
            PrismAccessibilityTest.validateContrastRatio(
                foreground: theme.color(.info), background: .white, isLargeText: true
            ))
    }

    @Test
    func highContrastFeedbackColorsPassLargeText() {
        let theme = HighContrastTheme()
        let feedbackTokens: [ColorToken] = [.success, .warning, .error, .info]
        for token in feedbackTokens {
            #expect(
                PrismAccessibilityTest.validateContrastRatio(
                    foreground: theme.color(token),
                    background: .white,
                    isLargeText: true
                ))
        }
    }

    // MARK: - Theme Token Completeness

    @Test
    func defaultThemeNoClearColors() {
        let issues = PrismThemeTest.validateAllColors(DefaultTheme())
        #expect(issues.isEmpty, "DefaultTheme has clear colors: \(issues)")
    }

    @Test
    func darkThemeNoClearColors() {
        let issues = PrismThemeTest.validateAllColors(DarkTheme())
        #expect(issues.isEmpty, "DarkTheme has clear colors: \(issues)")
    }

    @Test
    func highContrastThemeNoClearColors() {
        let issues = PrismThemeTest.validateAllColors(HighContrastTheme())
        #expect(issues.isEmpty, "HighContrastTheme has clear colors: \(issues)")
    }

    @Test
    func brandThemeNoClearColors() {
        let issues = PrismThemeTest.validateAllColors(BrandTheme())
        #expect(issues.isEmpty, "BrandTheme has clear colors: \(issues)")
    }

    // MARK: - Interactive State Hierarchy

    @Test
    func allThemesHaveDistinctInteractiveStates() {
        #expect(PrismThemeTest.validateInteractiveStates(DefaultTheme()))
        #expect(PrismThemeTest.validateInteractiveStates(DarkTheme()))
        #expect(PrismThemeTest.validateInteractiveStates(HighContrastTheme()))
        #expect(PrismThemeTest.validateInteractiveStates(BrandTheme()))
    }

    // MARK: - Minimum Spacing

    @Test
    func spacingTokensMeetMinimumReadability() {
        #expect(SpacingToken.xs.rawValue >= 4)
        #expect(SpacingToken.sm.rawValue >= 8)
    }

    @Test
    func radiusTokensArePositive() {
        for token in RadiusToken.allCases {
            #expect(token.rawValue >= 0)
        }
    }

    // MARK: - Component Existence Audit

    @Test
    func allPrimitivesInstantiate() {
        let button = PrismButton("Test") {}
        let icon = PrismIcon("star")
        let tag = PrismTag("Label")
        let card = PrismCard { Text("Content") }
        let divider = PrismDivider()
        let loading = PrismLoadingState(.loading)
        let progress = PrismProgressBar(value: 0.5)
        let avatar = PrismAvatar(initials: "AB")
        #expect(button != nil)
        #expect(icon != nil)
        #expect(tag != nil)
        #expect(card != nil)
        #expect(divider != nil)
        #expect(loading != nil)
        #expect(progress != nil)
        #expect(avatar != nil)
    }

    @Test
    func allCompositesInstantiate() {
        let banner = PrismBanner("Info", style: .info)
        let toast = PrismToast("Done", style: .success)
        let empty = PrismEmptyState(icon: "tray", title: "Empty")
        let countdown = PrismCountdownTimer(seconds: 60, autoStart: false)
        #expect(banner != nil)
        #expect(toast != nil)
        #expect(empty != nil)
        #expect(countdown != nil)
    }
}
