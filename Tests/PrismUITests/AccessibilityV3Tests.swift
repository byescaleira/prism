import SwiftUI
import Testing

@testable import PrismUI

@Suite("Accessibility V3")
@MainActor
struct AccessibilityV3Tests {

    // MARK: - Color Blindness Simulation

    @Test
    func colorBlindnessTypeHasSevenCases() {
        #expect(PrismColorBlindnessType.allCases.count == 7)
    }

    @Test
    func colorBlindnessTypesAreCaseIterable() {
        let expected: [PrismColorBlindnessType] = [
            .protanopia, .deuteranopia, .tritanopia, .achromatopsia,
            .protanomaly, .deuteranomaly, .tritanomaly,
        ]
        #expect(PrismColorBlindnessType.allCases == expected)
    }

    @Test
    func colorBlindnessTypeIsHashable() {
        var set = Set<PrismColorBlindnessType>()
        set.insert(.protanopia)
        set.insert(.deuteranopia)
        #expect(set.count == 2)
    }

    @Test
    func simulateReturnsColorForEachType() {
        let input = Color.red
        for type in PrismColorBlindnessType.allCases {
            let result = PrismColorBlindnessSimulator.simulate(input, type: type)
            #expect(result != nil)
        }
    }

    @Test
    func achromatopsiaProducesGrayscale() {
        let result = PrismColorBlindnessSimulator.simulate(Color.red, type: .achromatopsia)
        let resolved = result.resolve(in: EnvironmentValues())
        // Achromatopsia matrix produces equal RGB channels (grayscale)
        let tolerance: Float = 0.02
        #expect(abs(resolved.red - resolved.green) < tolerance)
        #expect(abs(resolved.green - resolved.blue) < tolerance)
    }

    @Test
    func simulatePreservesOpacity() {
        let input = Color.blue.opacity(0.5)
        let result = PrismColorBlindnessSimulator.simulate(input, type: .protanopia)
        let resolved = result.resolve(in: EnvironmentValues())
        #expect(abs(resolved.opacity - 0.5) < 0.01)
    }

    // MARK: - Contrast Ratio

    @Test
    func contrastRatioBlackOnWhiteIs21() {
        let ratio = PrismContrastChecker.contrastRatio(between: .white, and: .black)
        #expect(abs(ratio - 21.0) < 0.5)
    }

    @Test
    func contrastRatioSameColorIsOne() {
        let ratio = PrismContrastChecker.contrastRatio(between: .red, and: .red)
        #expect(abs(ratio - 1.0) < 0.01)
    }

    @Test
    func contrastRatioIsSymmetric() {
        let ratio1 = PrismContrastChecker.contrastRatio(between: .blue, and: .white)
        let ratio2 = PrismContrastChecker.contrastRatio(between: .white, and: .blue)
        #expect(abs(ratio1 - ratio2) < 0.01)
    }

    // MARK: - Meets Level

    @Test
    func blackOnWhiteMeetsAAA() {
        #expect(PrismContrastChecker.meetsLevel(.aaa, foreground: .black, background: .white))
    }

    @Test
    func whiteOnWhiteFailsAA() {
        #expect(!PrismContrastChecker.meetsLevel(.aa, foreground: .white, background: .white))
    }

    @Test
    func blackOnWhiteMeetsAllLevels() {
        for level in PrismContrastLevel.allCases {
            #expect(PrismContrastChecker.meetsLevel(level, foreground: .black, background: .white))
        }
    }

    // MARK: - Suggest Accessible Color

    @Test
    func suggestAccessibleColorMeetsTarget() {
        let suggested = PrismContrastChecker.suggestAccessibleColor(
            for: Color(red: 0.7, green: 0.7, blue: 0.7),
            on: .white,
            level: .aa
        )
        #expect(PrismContrastChecker.meetsLevel(.aa, foreground: suggested, background: .white))
    }

    @Test
    func suggestAccessibleColorReturnsOriginalWhenAlreadyMeeting() {
        let original = Color.black
        let suggested = PrismContrastChecker.suggestAccessibleColor(
            for: original,
            on: .white,
            level: .aa
        )
        let resolvedOriginal = original.resolve(in: EnvironmentValues())
        let resolvedSuggested = suggested.resolve(in: EnvironmentValues())
        #expect(abs(resolvedOriginal.red - resolvedSuggested.red) < 0.01)
        #expect(abs(resolvedOriginal.green - resolvedSuggested.green) < 0.01)
        #expect(abs(resolvedOriginal.blue - resolvedSuggested.blue) < 0.01)
    }

    // MARK: - Contrast Level Minimum Ratios

    @Test
    func contrastLevelMinimumRatios() {
        #expect(PrismContrastLevel.aa.minimumRatio == 4.5)
        #expect(PrismContrastLevel.aaa.minimumRatio == 7.0)
        #expect(PrismContrastLevel.aaLargeText.minimumRatio == 3.0)
        #expect(PrismContrastLevel.aaaLargeText.minimumRatio == 4.5)
    }

    @Test
    func contrastLevelHasFourCases() {
        #expect(PrismContrastLevel.allCases.count == 4)
    }

    // MARK: - Focus Order Validation

    @Test
    func orderedItemsValidateSuccessfully() {
        let items = [
            PrismFocusOrderItem(id: "a", label: "Header", priority: 100),
            PrismFocusOrderItem(id: "b", label: "Content", priority: 50),
            PrismFocusOrderItem(id: "c", label: "Footer", priority: 10),
        ]
        let result = PrismFocusOrderValidator.validate(items)
        #expect(result.isValid)
        #expect(result.warnings.isEmpty)
    }

    @Test
    func unorderedItemsProduceWarnings() {
        let items = [
            PrismFocusOrderItem(id: "a", label: "Footer", priority: 10),
            PrismFocusOrderItem(id: "b", label: "Header", priority: 100),
        ]
        let result = PrismFocusOrderValidator.validate(items)
        #expect(!result.isValid)
        #expect(result.warnings.count == 1)
    }

    @Test
    func focusOrderItemIsIdentifiable() {
        let item = PrismFocusOrderItem(id: "test", label: "Test", priority: 1)
        #expect(item.id == "test")
    }

    @Test
    func focusOrderItemIsHashable() {
        let a = PrismFocusOrderItem(id: "a", label: "A", priority: 1)
        let b = PrismFocusOrderItem(id: "b", label: "B", priority: 2)
        var set = Set<PrismFocusOrderItem>()
        set.insert(a)
        set.insert(b)
        #expect(set.count == 2)
    }

    // MARK: - Announcement Priority

    @Test
    func announcementPriorityHasTwoCases() {
        #expect(PrismAnnouncementPriority.allCases.count == 2)
    }

    @Test
    func announcementPriorityCases() {
        let cases = PrismAnnouncementPriority.allCases
        #expect(cases.contains(.polite))
        #expect(cases.contains(.assertive))
    }

    // MARK: - Voice Control Group

    @Test
    func voiceControlGroupInstantiates() {
        let group = PrismVoiceControlGroup("Test Group") {
            Text("Child 1")
            Text("Child 2")
        }
        #expect(group != nil)
    }

    // MARK: - Relative Luminance

    @Test
    func whiteLuminanceIsApproximatelyOne() {
        let luminance = PrismContrastChecker.relativeLuminance(of: .white)
        #expect(abs(luminance - 1.0) < 0.01)
    }

    @Test
    func blackLuminanceIsApproximatelyZero() {
        let luminance = PrismContrastChecker.relativeLuminance(of: .black)
        #expect(abs(luminance - 0.0) < 0.01)
    }
}
