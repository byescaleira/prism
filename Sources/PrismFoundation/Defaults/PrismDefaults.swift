//
//  PrismDefaults.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/09/25.
//

import Foundation

/// A UserDefaults wrapper with Codable type support.
///
/// Thread-safe: `UserDefaults` is itself thread-safe for reads and writes.
public struct PrismDefaults: @unchecked Sendable {
    let userDefaults: UserDefaults

    /// Creates a defaults wrapper using the "prism.defaults" suite, falling back to standard defaults.
    public init() {
        self.userDefaults = Self.makeUserDefaults(
            suiteName: "prism.defaults",
            makeSuite: { UserDefaults(suiteName: $0) },
            fallback: .standard
        )
    }

    /// Creates a defaults wrapper using the provided `UserDefaults` instance.
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    static func makeUserDefaults(
        suiteName: String,
        makeSuite: (String) -> UserDefaults?,
        fallback: UserDefaults
    ) -> UserDefaults {
        if let userDefaults = makeSuite(suiteName) {
            return userDefaults
        }

        return fallback
    }

    /// Retrieves and decodes a `Codable` value for the given key, returning `nil` if absent or decoding fails.
    public func get<Value: Codable>(for key: String) -> Value? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Value.self, from: data)
    }

    /// Encodes and stores a `Codable` value for the given key, or removes it if the value is `nil`.
    public func set<Value: Codable>(_ value: Value?, for key: String) {
        guard let value else {
            userDefaults.removeObject(forKey: key)
            return
        }

        guard let data = try? value.data() else { return }
        userDefaults.set(data, forKey: key)
    }
}
