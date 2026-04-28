import SwiftUI

/// AI-assisted theme generation from a single brand color.
///
/// Derives complementary, analogous, and triadic colors, then builds
/// a complete `BrandTheme` automatically.
///
/// ```swift
/// let theme = PrismAutoTheme.generate(from: .indigo)
/// ContentView().prismTheme(theme)
/// ```
@MainActor
public enum PrismAutoTheme {

    /// Generates a complete BrandTheme from a single brand color.
    public static func generate(from brandColor: Color) -> BrandTheme {
        let resolved = brandColor.resolve(in: .init())
        let hsl = rgbToHSL(r: Double(resolved.red), g: Double(resolved.green), b: Double(resolved.blue))

        let secondary = hslToColor(h: (hsl.h + 30).truncatingRemainder(dividingBy: 360), s: hsl.s * 0.8, l: hsl.l)
        let accent = hslToColor(h: (hsl.h + 180).truncatingRemainder(dividingBy: 360), s: hsl.s, l: hsl.l)

        return BrandTheme(primary: brandColor, secondary: secondary, accent: accent)
    }

    /// Generates a theme using analogous color harmony.
    public static func analogous(from brandColor: Color) -> BrandTheme {
        let resolved = brandColor.resolve(in: .init())
        let hsl = rgbToHSL(r: Double(resolved.red), g: Double(resolved.green), b: Double(resolved.blue))

        let secondary = hslToColor(h: (hsl.h + 30).truncatingRemainder(dividingBy: 360), s: hsl.s, l: hsl.l)
        let accent = hslToColor(h: (hsl.h - 30 + 360).truncatingRemainder(dividingBy: 360), s: hsl.s, l: hsl.l)

        return BrandTheme(primary: brandColor, secondary: secondary, accent: accent)
    }

    /// Generates a theme using triadic color harmony.
    public static func triadic(from brandColor: Color) -> BrandTheme {
        let resolved = brandColor.resolve(in: .init())
        let hsl = rgbToHSL(r: Double(resolved.red), g: Double(resolved.green), b: Double(resolved.blue))

        let secondary = hslToColor(h: (hsl.h + 120).truncatingRemainder(dividingBy: 360), s: hsl.s * 0.7, l: hsl.l)
        let accent = hslToColor(h: (hsl.h + 240).truncatingRemainder(dividingBy: 360), s: hsl.s * 0.8, l: hsl.l)

        return BrandTheme(primary: brandColor, secondary: secondary, accent: accent)
    }

    /// Generates a theme using split-complementary harmony.
    public static func splitComplementary(from brandColor: Color) -> BrandTheme {
        let resolved = brandColor.resolve(in: .init())
        let hsl = rgbToHSL(r: Double(resolved.red), g: Double(resolved.green), b: Double(resolved.blue))

        let secondary = hslToColor(h: (hsl.h + 150).truncatingRemainder(dividingBy: 360), s: hsl.s * 0.75, l: hsl.l)
        let accent = hslToColor(h: (hsl.h + 210).truncatingRemainder(dividingBy: 360), s: hsl.s * 0.85, l: hsl.l)

        return BrandTheme(primary: brandColor, secondary: secondary, accent: accent)
    }

    /// Available color harmony strategies.
    public enum Harmony: String, CaseIterable, Sendable {
        case complementary
        case analogous
        case triadic
        case splitComplementary
    }

    /// Generates a theme using the specified harmony.
    public static func generate(from brandColor: Color, harmony: Harmony) -> BrandTheme {
        switch harmony {
        case .complementary: generate(from: brandColor)
        case .analogous: analogous(from: brandColor)
        case .triadic: triadic(from: brandColor)
        case .splitComplementary: splitComplementary(from: brandColor)
        }
    }

    // MARK: - Color Math

    private struct HSL {
        let h: Double
        let s: Double
        let l: Double
    }

    private static func rgbToHSL(r: Double, g: Double, b: Double) -> HSL {
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC
        let l = (maxC + minC) / 2

        guard delta > 0.001 else { return HSL(h: 0, s: 0, l: l) }

        let s = l > 0.5 ? delta / (2 - maxC - minC) : delta / (maxC + minC)

        var h: Double
        if maxC == r {
            h = ((g - b) / delta).truncatingRemainder(dividingBy: 6)
        } else if maxC == g {
            h = (b - r) / delta + 2
        } else {
            h = (r - g) / delta + 4
        }
        h = (h * 60 + 360).truncatingRemainder(dividingBy: 360)

        return HSL(h: h, s: s, l: l)
    }

    private static func hslToColor(h: Double, s: Double, l: Double) -> Color {
        let c = (1 - abs(2 * l - 1)) * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = l - c / 2

        var r = 0.0, g = 0.0, b = 0.0
        switch h {
        case 0..<60: (r, g, b) = (c, x, 0)
        case 60..<120: (r, g, b) = (x, c, 0)
        case 120..<180: (r, g, b) = (0, c, x)
        case 180..<240: (r, g, b) = (0, x, c)
        case 240..<300: (r, g, b) = (x, 0, c)
        default: (r, g, b) = (c, 0, x)
        }

        return Color(red: r + m, green: g + m, blue: b + m)
    }
}
