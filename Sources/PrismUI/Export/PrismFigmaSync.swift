import SwiftUI

/// Bidirectional Figma token sync — export and import.
///
/// Export: generates Figma Variables-compatible JSON from current theme.
/// Import: parses Figma Variables JSON and creates a BrandTheme.
///
/// ```swift
/// // Export
/// let json = PrismFigmaSync.exportVariables(theme: DefaultTheme())
///
/// // Import
/// if let theme = PrismFigmaSync.importTheme(from: jsonData) {
///     ContentView().prismTheme(theme)
/// }
/// ```
@MainActor
public enum PrismFigmaSync {

    // MARK: - Export (Figma Variables format)

    /// Exports as Figma Variables-compatible JSON.
    public static func exportVariables(theme: some PrismTheme) -> [String: Any] {
        [
            "version": "1.0",
            "collections": [
                exportColorCollection(theme: theme),
                exportDimensionCollection(),
            ],
        ]
    }

    /// Exports as Figma Variables JSON data.
    public static func exportVariablesData(theme: some PrismTheme) -> Data? {
        try? JSONSerialization.data(
            withJSONObject: exportVariables(theme: theme),
            options: [.prettyPrinted, .sortedKeys]
        )
    }

    /// Exports as Figma Variables JSON string.
    public static func exportVariablesString(theme: some PrismTheme) -> String? {
        guard let data = exportVariablesData(theme: theme) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func exportColorCollection(theme: some PrismTheme) -> [String: Any] {
        var variables: [[String: Any]] = []
        for token in ColorToken.allCases {
            let resolved = theme.color(token).resolve(in: .init())
            variables.append([
                "name": "color/\(token.rawValue)",
                "type": "COLOR",
                "value": [
                    "r": Double(resolved.red),
                    "g": Double(resolved.green),
                    "b": Double(resolved.blue),
                    "a": Double(resolved.opacity),
                ],
            ])
        }
        return ["name": "Prism Colors", "modes": ["Default"], "variables": variables]
    }

    private static func exportDimensionCollection() -> [String: Any] {
        var variables: [[String: Any]] = []

        for token in SpacingToken.allCases {
            variables.append([
                "name": "spacing/\(token)",
                "type": "FLOAT",
                "value": token.rawValue,
            ])
        }

        for token in RadiusToken.allCases {
            variables.append([
                "name": "radius/\(token)",
                "type": "FLOAT",
                "value": token.rawValue,
            ])
        }

        return ["name": "Prism Dimensions", "modes": ["Default"], "variables": variables]
    }

    // MARK: - Import

    /// Parses Figma Variables JSON and creates a BrandTheme.
    public static func importTheme(from data: Data) -> BrandTheme? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let collections = json["collections"] as? [[String: Any]]
        else { return nil }

        var primary: Color?
        var secondary: Color?
        var accent: Color?

        for collection in collections {
            guard let variables = collection["variables"] as? [[String: Any]] else { continue }
            for variable in variables {
                guard let name = variable["name"] as? String,
                      let value = variable["value"] as? [String: Double]
                else { continue }

                let color = Color(
                    red: value["r"] ?? 0,
                    green: value["g"] ?? 0,
                    blue: value["b"] ?? 0,
                    opacity: value["a"] ?? 1
                )

                switch name {
                case "color/brand": primary = color
                case "color/brandVariant": secondary = color
                case "color/interactive": accent = color
                default: break
                }
            }
        }

        return BrandTheme(
            primary: primary ?? .blue,
            secondary: secondary ?? .cyan,
            accent: accent ?? .orange
        )
    }

    /// Parses a JSON string and creates a BrandTheme.
    public static func importTheme(from jsonString: String) -> BrandTheme? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return importTheme(from: data)
    }

    // MARK: - DTCG (Design Tokens Community Group) Format

    /// Exports in W3C DTCG format for cross-tool compatibility.
    public static func exportDTCG(theme: some PrismTheme) -> [String: Any] {
        var tokens: [String: Any] = [:]

        for token in ColorToken.allCases {
            let resolved = theme.color(token).resolve(in: .init())
            tokens["color.\(token.rawValue)"] = [
                "$value": String(
                    format: "#%02x%02x%02x%02x",
                    Int(resolved.red * 255),
                    Int(resolved.green * 255),
                    Int(resolved.blue * 255),
                    Int(resolved.opacity * 255)
                ),
                "$type": "color",
                "$description": "Prism \(token.rawValue) token",
            ]
        }

        for token in SpacingToken.allCases {
            tokens["spacing.\(token)"] = [
                "$value": "\(token.rawValue)px",
                "$type": "dimension",
            ]
        }

        for token in RadiusToken.allCases {
            tokens["radius.\(token)"] = [
                "$value": "\(token.rawValue)px",
                "$type": "dimension",
            ]
        }

        for token in ElevationToken.allCases {
            tokens["elevation.\(token)"] = [
                "$value": [
                    "offsetX": "0px",
                    "offsetY": "\(token.shadowY)px",
                    "blur": "\(token.shadowRadius)px",
                    "color": "rgba(0,0,0,\(token.shadowOpacity))",
                ] as [String: String],
                "$type": "shadow",
            ]
        }

        return tokens
    }
}
