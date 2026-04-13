//
//  RyzeDefaults.swift
//  Ryze
//
//  Created by Rafael Escaleira on 13/09/25.
//

import Foundation

public struct RyzeDefaults: @unchecked Sendable {
    var userDefaults: UserDefaults

    public init() {
        self.userDefaults = Self.makeUserDefaults(
            suiteName: "ryze.defaults",
            makeSuite: { UserDefaults(suiteName: $0) },
            fallback: .standard
        )
    }

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

    public func get<Value: Codable>(for key: String) -> Value? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Value.self, from: data)
    }

    public func set<Value: Codable>(_ value: Value?, for key: String) {
        guard let value else {
            userDefaults.removeObject(forKey: key)
            return
        }

        guard let data = try? value.data() else { return }
        userDefaults.set(data, forKey: key)
    }
}
