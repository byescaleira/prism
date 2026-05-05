import Foundation

/// Type-safe configuration from environment variables and .env files.
public struct PrismConfig: Sendable {
    private let values: [String: String]

    /// Creates a configuration with the given key-value pairs.
    public init(values: [String: String] = [:]) {
        self.values = values
    }

    /// Loads config from environment variables merged with provided values.
    public static func fromEnvironment(overrides: [String: String] = [:]) -> PrismConfig {
        var merged = ProcessInfo.processInfo.environment
        for (key, value) in overrides {
            merged[key] = value
        }
        return PrismConfig(values: merged)
    }

    /// Loads config from a .env file, merged with environment.
    public static func load(path: String = ".env", environment: String? = nil) -> PrismConfig {
        var envValues = ProcessInfo.processInfo.environment

        if let parsed = Self.parseEnvFile(at: path) {
            for (key, value) in parsed {
                if envValues[key] == nil {
                    envValues[key] = value
                }
            }
        }

        if let env = environment ?? envValues["PRISM_ENV"] {
            let envPath = ".env.\(env)"
            if let envSpecific = Self.parseEnvFile(at: envPath) {
                for (key, value) in envSpecific {
                    if envValues[key] == nil {
                        envValues[key] = value
                    }
                }
            }
        }

        return PrismConfig(values: envValues)
    }

    /// Gets a string value or nil.
    public func get(_ key: String) -> String? {
        values[key]
    }

    /// Gets a string value or a default.
    public func get(_ key: String, default defaultValue: String) -> String {
        values[key] ?? defaultValue
    }

    /// Gets a required string value. Throws if missing.
    public func require(_ key: String) throws -> String {
        guard let value = values[key] else {
            throw PrismConfigError.missingKey(key)
        }
        return value
    }

    /// Gets an integer value.
    public func getInt(_ key: String) -> Int? {
        values[key].flatMap(Int.init)
    }

    /// Gets an integer value or a default.
    public func getInt(_ key: String, default defaultValue: Int) -> Int {
        values[key].flatMap(Int.init) ?? defaultValue
    }

    /// Gets a boolean value. "true", "1", "yes" → true.
    public func getBool(_ key: String) -> Bool? {
        guard let raw = values[key]?.lowercased() else { return nil }
        switch raw {
        case "true", "1", "yes": return true
        case "false", "0", "no": return false
        default: return nil
        }
    }

    /// Gets a boolean value or a default.
    public func getBool(_ key: String, default defaultValue: Bool) -> Bool {
        getBool(key) ?? defaultValue
    }

    /// Gets a double value.
    public func getDouble(_ key: String) -> Double? {
        values[key].flatMap(Double.init)
    }

    /// Gets the current environment name (from PRISM_ENV).
    public var environment: String {
        self.get("PRISM_ENV", default: "development")
    }

    /// Whether in production mode.
    public var isProduction: Bool { environment == "production" }

    /// Whether in development mode.
    public var isDevelopment: Bool { environment == "development" }

    /// Server port from PORT env var.
    public var port: UInt16 {
        UInt16(getInt("PORT", default: 8080))
    }

    /// Server host from HOST env var.
    public var host: String {
        self.get("HOST", default: "0.0.0.0")
    }

    /// All configuration keys.
    public var keys: [String] { Array(values.keys) }

    private static func parseEnvFile(at path: String) -> [String: String]? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }

        var result: [String: String] = [:]
        for line in content.split(separator: "\n", omittingEmptySubsequences: true) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

            guard let equalsIndex = trimmed.firstIndex(of: "=") else { continue }
            let key = String(trimmed[trimmed.startIndex..<equalsIndex]).trimmingCharacters(in: .whitespaces)
            var value = String(trimmed[trimmed.index(after: equalsIndex)...]).trimmingCharacters(in: .whitespaces)

            if (value.hasPrefix("\"") && value.hasSuffix("\"")) || (value.hasPrefix("'") && value.hasSuffix("'")) {
                value = String(value.dropFirst().dropLast())
            }

            if !key.isEmpty {
                result[key] = value
            }
        }
        return result
    }
}

/// Configuration errors.
public enum PrismConfigError: Error, Sendable {
    /// A required configuration key was not found.
    case missingKey(String)
    /// A configuration value could not be parsed into the expected type.
    case invalidValue(String, String)
}
