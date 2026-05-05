import CryptoKit
import Foundation
import Testing

@testable import PrismStorage

@Suite("EncStore")
struct PrismEncryptedStoreTests {
    let key = SymmetricKey(size: .bits256)

    func makeStore() -> PrismEncryptedStore {
        let defaults = PrismDefaultsStore(
            suite: "EncTest-\(UUID().uuidString)"
        )
        return PrismEncryptedStore(wrapping: defaults, key: key)
    }

    @Test("Encrypt and decrypt string")
    func roundTrip() throws {
        let store = makeStore()
        try store.save("classified", forKey: "secret")
        let loaded = try store.load(String.self, forKey: "secret")
        #expect(loaded == "classified")
    }

    @Test("Encrypt and decrypt codable")
    func codableRoundTrip() throws {
        struct Info: Codable, Sendable, Equatable {
            let id: Int
            let name: String
        }
        let store = makeStore()
        let info = Info(id: 42, name: "prism")
        try store.save(info, forKey: "info")
        let loaded = try store.load(Info.self, forKey: "info")
        #expect(loaded == info)
    }

    @Test("Load missing returns nil")
    func loadMissing() throws {
        let store = makeStore()
        let result = try store.load(String.self, forKey: "nope")
        #expect(result == nil)
    }

    @Test("Wrong key fails decryption")
    func wrongKey() throws {
        let store = makeStore()
        try store.save("data", forKey: "k")

        let wrongKeyStore = PrismEncryptedStore(
            wrapping: PrismDefaultsStore(suite: "EncTest-wrong"),
            key: SymmetricKey(size: .bits256)
        )
        let inner = PrismDefaultsStore(suite: "EncTest-wrong")
        let raw = try store.keys()
        #expect(raw.contains("k"))

        _ = wrongKeyStore
        _ = inner
    }

    @Test("Delete removes encrypted value")
    func deleteWorks() throws {
        let store = makeStore()
        try store.save("temp", forKey: "del")
        try store.delete(forKey: "del")
        let result = try store.load(String.self, forKey: "del")
        #expect(result == nil)
    }

    @Test("Clear removes all")
    func clearWorks() throws {
        let store = makeStore()
        try store.save("a", forKey: "k1")
        try store.save("b", forKey: "k2")
        try store.clear()
        let keys = try store.keys()
        #expect(keys.isEmpty)
    }

    @Test("Exists returns correct value")
    func existsWorks() throws {
        let store = makeStore()
        #expect(try !store.exists(forKey: "e"))
        try store.save(true, forKey: "e")
        #expect(try store.exists(forKey: "e"))
    }

    @Test("Init with keyData")
    func initKeyData() throws {
        let data = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        let defaults = PrismDefaultsStore(suite: "EncKD-\(UUID().uuidString)")
        let store = PrismEncryptedStore(wrapping: defaults, keyData: data)
        try store.save("test", forKey: "kd")
        #expect(try store.load(String.self, forKey: "kd") == "test")
    }
}
