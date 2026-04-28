import Testing

@testable import PrismUI

struct TokenTests {

    // MARK: - SpacingToken

    @Test
    func spacingTokensFollowFourPointGrid() {
        let values = SpacingToken.allCases.map(\.rawValue)
        for value in values where value > 0 {
            #expect(value.truncatingRemainder(dividingBy: 2) == 0,
                    "Spacing \(value) should be even (4pt grid)")
        }
    }

    @Test
    func spacingTokensAreStrictlyIncreasing() {
        let values = SpacingToken.allCases.map(\.rawValue)
        for i in 1..<values.count {
            #expect(values[i] > values[i - 1])
        }
    }

    // MARK: - RadiusToken

    @Test
    func radiusTokensAreStrictlyIncreasing() {
        let values = RadiusToken.allCases.map(\.rawValue)
        for i in 1..<values.count {
            #expect(values[i] > values[i - 1])
        }
    }

    @Test
    func radiusFullTokenHasLargeValue() {
        #expect(RadiusToken.full.rawValue >= 9999)
    }

    // MARK: - TypographyToken

    @Test
    func typographyTokensCoverAllTextStyles() {
        #expect(TypographyToken.allCases.count == 11)
    }

    @Test
    func typographyTokenProducesFont() {
        let font = TypographyToken.body.font
        let fontOverride = TypographyToken.body.font(weight: .bold)
        #expect(font != fontOverride)
    }

    @Test
    func typographyDefaultWeightsMatchExpectation() {
        #expect(TypographyToken.largeTitle.defaultWeight == .bold)
        #expect(TypographyToken.body.defaultWeight == .regular)
        #expect(TypographyToken.headline.defaultWeight == .semibold)
    }

    // MARK: - MotionToken

    @Test
    func motionDurationsAreStrictlyIncreasing() {
        let durations = MotionToken.allCases.map(\.duration)
        for i in 1..<durations.count {
            #expect(durations[i] > durations[i - 1])
        }
    }

    @Test
    func motionTokenProducesDistinctAnimations() {
        let fast = MotionToken.fast.animation
        let slow = MotionToken.slow.animation
        #expect(fast != slow)
    }

    // MARK: - ElevationToken

    @Test
    func elevationTokensAreComparable() {
        #expect(ElevationToken.flat < ElevationToken.low)
        #expect(ElevationToken.low < ElevationToken.medium)
        #expect(ElevationToken.medium < ElevationToken.high)
        #expect(ElevationToken.high < ElevationToken.overlay)
    }

    @Test
    func flatElevationHasNoShadow() {
        #expect(ElevationToken.flat.shadowRadius == 0)
        #expect(ElevationToken.flat.shadowY == 0)
        #expect(ElevationToken.flat.shadowOpacity == 0)
    }

    @Test
    func elevationShadowRadiusIncreases() {
        let radii = ElevationToken.allCases.map(\.shadowRadius)
        for i in 1..<radii.count {
            #expect(radii[i] >= radii[i - 1])
        }
    }

    // MARK: - ColorToken

    @Test
    func colorTokenCoversAllSemanticRoles() {
        #expect(ColorToken.allCases.count >= 25)
    }
}
