import Foundation

/// Type-safe key for UserDefaults storage.
public struct PrismDefaultKey<Value: Codable & Sendable>: Sendable {
    public let name: String
    public let defaultValue: Value
    public let suite: String?

    public init(_ name: String, default defaultValue: Value, suite: String? = nil) {
        self.name = name
        self.defaultValue = defaultValue
        self.suite = suite
    }
}

extension PrismDefaultKey where Value: ExpressibleByNilLiteral {
    public init(_ name: String, suite: String? = nil) {
        self.name = name
        self.defaultValue = nil
        self.suite = suite
    }
}
