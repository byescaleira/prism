import SwiftUI

/// Exports PrismUI design tokens to JSON or Figma-compatible format.
///
/// Use this to keep design tools in sync with the code-defined token system.
///
/// ```swift
/// let json = PrismTokenExport.toJSON(theme: DefaultTheme())
/// // Save to file or send to Figma plugin
/// ```
@MainActor
public enum PrismTokenExport {

    /// Exports all tokens as a JSON dictionary.
    public static func toJSON(theme: some PrismTheme) -> [String: Any] {
        var result: [String: Any] = [:]

        result["colors"] = exportColors(theme: theme)
        result["typography"] = exportTypography()
        result["spacing"] = exportSpacing()
        result["radius"] = exportRadius()
        result["elevation"] = exportElevation()
        result["motion"] = exportMotion()

        return result
    }

    /// Exports tokens as JSON data.
    public static func toJSONData(theme: some PrismTheme) -> Data? {
        try? JSONSerialization.data(
            withJSONObject: toJSON(theme: theme),
            options: [.prettyPrinted, .sortedKeys]
        )
    }

    /// Exports tokens as a JSON string.
    public static func toJSONString(theme: some PrismTheme) -> String? {
        guard let data = toJSONData(theme: theme) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Color Export

    private static func exportColors(theme: some PrismTheme) -> [String: String] {
        var colors: [String: String] = [:]
        for token in ColorToken.allCases {
            let color = theme.color(token)
            let resolved = color.resolve(in: .init())
            colors[token.rawValue] = String(
                format: "#%02X%02X%02X%02X",
                Int(resolved.red * 255),
                Int(resolved.green * 255),
                Int(resolved.blue * 255),
                Int(resolved.opacity * 255)
            )
        }
        return colors
    }

    // MARK: - Typography Export

    private static func exportTypography() -> [String: [String: Any]] {
        var typography: [String: [String: Any]] = [:]
        for token in TypographyToken.allCases {
            typography["\(token)"] = [
                "textStyle": "\(token.textStyle)",
                "defaultWeight": "\(token.defaultWeight)",
            ]
        }
        return typography
    }

    // MARK: - Spacing Export

    private static func exportSpacing() -> [String: CGFloat] {
        var spacing: [String: CGFloat] = [:]
        for token in SpacingToken.allCases {
            spacing["\(token)"] = token.rawValue
        }
        return spacing
    }

    // MARK: - Radius Export

    private static func exportRadius() -> [String: CGFloat] {
        var radius: [String: CGFloat] = [:]
        for token in RadiusToken.allCases {
            radius["\(token)"] = token.rawValue
        }
        return radius
    }

    // MARK: - Elevation Export

    private static func exportElevation() -> [String: [String: Any]] {
        var elevation: [String: [String: Any]] = [:]
        for token in ElevationToken.allCases {
            elevation["\(token)"] = [
                "shadowRadius": token.shadowRadius,
                "shadowY": token.shadowY,
                "shadowOpacity": token.shadowOpacity,
            ]
        }
        return elevation
    }

    // MARK: - Motion Export

    private static func exportMotion() -> [String: TimeInterval] {
        var motion: [String: TimeInterval] = [:]
        for token in MotionToken.allCases {
            motion["\(token)"] = token.duration
        }
        return motion
    }
}

// MARK: - Figma Token Format

extension PrismTokenExport {

    /// Exports in Figma Tokens plugin format (Design Tokens Community Group spec).
    public static func toFigmaTokens(theme: some PrismTheme) -> [String: Any] {
        var tokens: [String: Any] = [:]

        var colorTokens: [String: Any] = [:]
        for token in ColorToken.allCases {
            let color = theme.color(token)
            let resolved = color.resolve(in: .init())
            colorTokens[token.rawValue] = [
                "$value": String(
                    format: "#%02X%02X%02X",
                    Int(resolved.red * 255),
                    Int(resolved.green * 255),
                    Int(resolved.blue * 255)
                ),
                "$type": "color",
            ]
        }
        tokens["color"] = colorTokens

        var spacingTokens: [String: Any] = [:]
        for token in SpacingToken.allCases {
            spacingTokens["\(token)"] = [
                "$value": "\(Int(token.rawValue))px",
                "$type": "dimension",
            ]
        }
        tokens["spacing"] = spacingTokens

        var radiusTokens: [String: Any] = [:]
        for token in RadiusToken.allCases {
            radiusTokens["\(token)"] = [
                "$value": "\(Int(token.rawValue))px",
                "$type": "dimension",
            ]
        }
        tokens["borderRadius"] = radiusTokens

        return tokens
    }
}
