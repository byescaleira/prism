import Foundation
import Testing

@testable import PrismStorage

@Suite("DefStore")
struct PrismDefaultsStoreTests {
    let store = PrismDefaultsStore(suite: "test.defaults.\(UUID().uuidString)")

    @Test("Save and load string")
    func saveLoadString() throws {
        try store.save("hello", forKey: "greeting")
        let loaded = try store.load(String.self, forKey: "greeting")
        #expect(loaded == "hello")
    }

    @Test("Save and load codable")
    func saveLoadCodable() throws {
        struct User: Codable, Sendable, Equatable {
            let name: String
            let age: Int
        }
        let user = User(name: "Alice", age: 30)
        try store.save(user, forKey: "user")
        let loaded = try store.load(User.self, forKey: "user")
        #expect(loaded == user)
    }

    @Test("Load missing returns nil")
    func loadMissing() throws {
        let result = try store.load(String.self, forKey: "nonexistent")
        #expect(result == nil)
    }

    @Test("Delete removes value")
    func delete() throws {
        try store.save(42, forKey: "number")
        try store.delete(forKey: "number")
        let result = try store.load(Int.self, forKey: "number")
        #expect(result == nil)
    }

    @Test("Exists returns correct value")
    func exists() throws {
        #expect(try !store.exists(forKey: "missing"))
        try store.save(true, forKey: "flag")
        #expect(try store.exists(forKey: "flag"))
    }

    @Test("Clear removes all values")
    func clear() throws {
        try store.save("a", forKey: "k1")
        try store.save("b", forKey: "k2")
        try store.clear()
        #expect(try store.keys().isEmpty)
    }

    @Test("Keys returns stored keys")
    func keys() throws {
        try store.save(1, forKey: "x")
        try store.save(2, forKey: "y")
        let keys = try store.keys()
        #expect(keys.contains("x"))
        #expect(keys.contains("y"))
    }

    @Test("Overwrite replaces value")
    func overwrite() throws {
        try store.save("first", forKey: "val")
        try store.save("second", forKey: "val")
        let loaded = try store.load(String.self, forKey: "val")
        #expect(loaded == "second")
    }

    @Test("Bool round trip")
    func boolRoundTrip() throws {
        try store.save(true, forKey: "enabled")
        let loaded = try store.load(Bool.self, forKey: "enabled")
        #expect(loaded == true)
    }

    @Test("Array round trip")
    func arrayRoundTrip() throws {
        let items = [1, 2, 3, 4, 5]
        try store.save(items, forKey: "numbers")
        let loaded = try store.load([Int].self, forKey: "numbers")
        #expect(loaded == items)
    }
}

@Suite("DefKey")
struct PrismDefaultKeyTests {
    let store = PrismDefaultsStore(suite: "test.defkey.\(UUID().uuidString)")

    @Test("Typed key get with default")
    func typedKeyDefault() {
        let key = PrismDefaultKey("theme", default: "light")
        let value = store.get(key)
        #expect(value == "light")
    }

    @Test("Typed key set and get")
    func typedKeySetGet() {
        let key = PrismDefaultKey("count", default: 0)
        store.set(key, value: 42)
        #expect(store.get(key) == 42)
    }

    @Test("Optional typed key")
    func optionalKey() {
        let key = PrismDefaultKey<String?>("optName")
        let value = store.get(key)
        #expect(value == nil)
    }
}
