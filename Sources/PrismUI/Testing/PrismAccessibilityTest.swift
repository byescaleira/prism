import SwiftUI

/// Test utility for automated accessibility assertions.
///
/// Provides helpers for verifying accessibility compliance in unit tests.
@MainActor
public enum PrismAccessibilityTest {

    /// Verifies minimum tap target size (44×44pt per Apple HIG).
    public static func validateMinimumTapTarget(
        width: CGFloat,
        height: CGFloat
    ) -> Bool {
        width >= 44 && height >= 44
    }

    /// Verifies contrast ratio meets WCAG AA (4.5:1 for normal text, 3:1 for large text).
    public static func validateContrastRatio(
        foreground: Color,
        background: Color,
        isLargeText: Bool = false
    ) -> Bool {
        let ratio = contrastRatio(foreground, background)
        return isLargeText ? ratio >= 3.0 : ratio >= 4.5
    }

    /// Calculates approximate contrast ratio between two colors.
    private static func contrastRatio(_ color1: Color, _ color2: Color) -> Double {
        let l1 = relativeLuminance(color1)
        let l2 = relativeLuminance(color2)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private static func relativeLuminance(_ color: Color) -> Double {
        let resolved = color.resolve(in: .init())
        let r = linearize(Double(resolved.red))
        let g = linearize(Double(resolved.green))
        let b = linearize(Double(resolved.blue))
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    private static func linearize(_ value: Double) -> Double {
        value <= 0.04045
            ? value / 12.92
            : pow((value + 0.055) / 1.055, 2.4)
    }
}
