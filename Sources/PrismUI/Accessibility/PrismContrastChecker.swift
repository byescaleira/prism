import SwiftUI

/// WCAG compliance levels with minimum contrast ratios.
public enum PrismContrastLevel: String, Sendable, CaseIterable, Hashable {
    /// WCAG AA for normal text — minimum 4.5:1.
    case aa
    /// WCAG AAA for normal text — minimum 7:1.
    case aaa
    /// WCAG AA for large text — minimum 3:1.
    case aaLargeText
    /// WCAG AAA for large text — minimum 4.5:1.
    case aaaLargeText

    /// Minimum contrast ratio required for this level.
    public var minimumRatio: Double {
        switch self {
        case .aa: return 4.5
        case .aaa: return 7.0
        case .aaLargeText: return 3.0
        case .aaaLargeText: return 4.5
        }
    }
}

/// WCAG 2.x contrast ratio calculator and color suggestion engine.
public struct PrismContrastChecker: Sendable {

    /// Calculates the WCAG contrast ratio between two colors.
    public static func contrastRatio(between color1: Color, and color2: Color) -> Double {
        let l1 = relativeLuminance(of: color1)
        let l2 = relativeLuminance(of: color2)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Checks whether the foreground and background meet the given WCAG level.
    public static func meetsLevel(
        _ level: PrismContrastLevel,
        foreground: Color,
        background: Color
    ) -> Bool {
        contrastRatio(between: foreground, and: background) >= level.minimumRatio
    }

    /// Adjusts foreground lightness until the contrast ratio meets the target level.
    public static func suggestAccessibleColor(
        for foreground: Color,
        on background: Color,
        level: PrismContrastLevel
    ) -> Color {
        if meetsLevel(level, foreground: foreground, background: background) {
            return foreground
        }

        let resolved = foreground.resolve(in: EnvironmentValues())
        var r = Double(resolved.red)
        var g = Double(resolved.green)
        var b = Double(resolved.blue)
        let a = Double(resolved.opacity)
        let bgLuminance = relativeLuminance(of: background)

        // Determine whether to darken or lighten based on background luminance
        let shouldDarken = bgLuminance > 0.5
        let step = 0.01

        for _ in 0..<200 {
            if shouldDarken {
                r = max(r - step, 0)
                g = max(g - step, 0)
                b = max(b - step, 0)
            } else {
                r = min(r + step, 1)
                g = min(g + step, 1)
                b = min(b + step, 1)
            }
            let candidate = Color(red: r, green: g, blue: b, opacity: a)
            if meetsLevel(level, foreground: candidate, background: background) {
                return candidate
            }
        }

        // Fallback: return black or white depending on background
        return shouldDarken
            ? Color(red: 0, green: 0, blue: 0, opacity: a)
            : Color(red: 1, green: 1, blue: 1, opacity: a)
    }

    /// Calculates WCAG relative luminance for a color.
    public static func relativeLuminance(of color: Color) -> Double {
        let resolved = color.resolve(in: EnvironmentValues())
        let r = linearize(Double(resolved.red))
        let g = linearize(Double(resolved.green))
        let b = linearize(Double(resolved.blue))
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    /// Converts sRGB component to linear value per WCAG formula.
    private static func linearize(_ value: Double) -> Double {
        value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
    }
}
