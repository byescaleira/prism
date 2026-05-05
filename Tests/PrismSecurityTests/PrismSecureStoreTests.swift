import Foundation
import Testing

@testable import PrismSecurity

@Suite("StoreConf")
struct PrismSecureStoreConfigurationTests {
    @Test("Default configuration")
    func defaultConfig() {
        let config = PrismSecureStoreConfiguration.default
        #expect(config.algorithm == .aesGCM)
        #expect(config.service == "PrismSecureStore")
        #expect(config.synchronizeKey == false)
    }

    @Test("Biometric protected configuration")
    func biometricConfig() {
        let config = PrismSecureStoreConfiguration.biometricProtected
        #expect(config.algorithm == .aesGCM)
        #expect(config.synchronizeKey == false)
    }

    @Test("High security configuration")
    func highSecurityConfig() {
        let config = PrismSecureStoreConfiguration.highSecurity
        #expect(config.algorithm == .chaChaPoly)
        #expect(config.synchronizeKey == false)
    }

    @Test("Custom configuration")
    func customConfig() {
        let config = PrismSecureStoreConfiguration(
            algorithm: .chaChaPoly,
            service: "CustomService",
            synchronizeKey: true
        )
        #expect(config.algorithm == .chaChaPoly)
        #expect(config.service == "CustomService")
        #expect(config.synchronizeKey == true)
    }
}

#if os(macOS) || os(iOS)
    @Suite("SecStore")
    struct PrismSecureStoreTests {
        let store = PrismSecureStore(
            configuration: PrismSecureStoreConfiguration(
                service: "PrismSecureStoreTests_\(UUID().uuidString)"
            )
        )

        @Test("Save and load string")
        func stringRoundTrip() throws {
            let key = "token_\(UUID().uuidString)"
            try store.save("my-secret-token", forKey: key)
            let loaded = try store.loadString(forKey: key)
            #expect(loaded == "my-secret-token")
            try store.delete(forKey: key)
        }

        @Test("Save and load Codable")
        func codableRoundTrip() throws {
            struct Credentials: Codable, Sendable, Equatable {
                let username: String
                let apiKey: String
            }

            let key = "creds_\(UUID().uuidString)"
            let creds = Credentials(username: "admin", apiKey: "sk-123")
            try store.save(creds, forKey: key)
            let loaded = try store.load(Credentials.self, forKey: key)
            #expect(loaded == creds)
            try store.delete(forKey: key)
        }

        @Test("Save and load raw data")
        func dataRoundTrip() throws {
            let key = "data_\(UUID().uuidString)"
            let data = Data(repeating: 0xAB, count: 256)
            try store.saveData(data, forKey: key)
            let loaded = try store.loadData(forKey: key)
            #expect(loaded == data)
            try store.delete(forKey: key)
        }

        @Test("Exists returns true for saved items")
        func exists() throws {
            let key = "exists_\(UUID().uuidString)"
            try store.save("value", forKey: key)
            #expect(store.exists(forKey: key))
            try store.delete(forKey: key)
        }

        @Test("Exists returns false for missing items")
        func notExists() {
            #expect(!store.exists(forKey: "nonexistent_\(UUID().uuidString)"))
        }

        @Test("Delete removes item")
        func delete() throws {
            let key = "del_\(UUID().uuidString)"
            try store.save("temp", forKey: key)
            try store.delete(forKey: key)
            #expect(!store.exists(forKey: key))
        }

        @Test("Overwrite existing value")
        func overwrite() throws {
            let key = "overwrite_\(UUID().uuidString)"
            try store.save("first", forKey: key)
            try store.save("second", forKey: key)
            let loaded = try store.loadString(forKey: key)
            #expect(loaded == "second")
            try store.delete(forKey: key)
        }

        @Test("Delete all does not throw")
        func deleteAll() throws {
            let key = "all_\(UUID().uuidString)"
            try store.save("a", forKey: key)
            try store.deleteAll()
            try store.delete(forKey: key)
        }
    }
#endif
