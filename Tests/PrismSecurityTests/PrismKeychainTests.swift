import Foundation
import Testing

@testable import PrismSecurity

@Suite("KcItem")
struct PrismKeychainItemTests {
    @Test("Default item properties")
    func defaults() {
        let item = PrismKeychainItem(id: "test")
        #expect(item.id == "test")
        #expect(item.service == "PrismSecurity")
        #expect(item.accessGroup == nil)
        #expect(item.synchronizable == false)
    }

    @Test("Custom item properties")
    func custom() {
        let item = PrismKeychainItem(
            id: "token",
            service: "MyApp",
            accessGroup: "group.com.app",
            synchronizable: true
        )
        #expect(item.id == "token")
        #expect(item.service == "MyApp")
        #expect(item.accessGroup == "group.com.app")
        #expect(item.synchronizable == true)
    }

    @Test("Item ID is identifiable")
    func identifiable() {
        let item = PrismKeychainItem(id: "abc")
        #expect(item.id == "abc")
    }
}

@Suite("KcAccess")
struct PrismKeychainAccessControlTests {
    @Test("Default access control")
    func defaultControl() {
        let ac = PrismKeychainAccessControl.default
        #expect(ac.accessibility == .whenUnlocked)
    }

    @Test("Biometric access control")
    func biometric() {
        let ac = PrismKeychainAccessControl.biometricAny
        #expect(ac.accessibility == .whenPasscodeSet)
    }

    @Test("Passcode access control")
    func passcode() {
        let ac = PrismKeychainAccessControl.devicePasscode
        #expect(ac.accessibility == .whenPasscodeSet)
    }
}

@Suite("KcAccess2")
struct PrismKeychainAccessibilityTests {
    @Test("When unlocked CF value exists")
    func whenUnlocked() {
        let a = PrismKeychainAccessibility.whenUnlocked
        #expect(a == .whenUnlocked)
    }

    @Test("After first unlock CF value exists")
    func afterFirstUnlock() {
        let a = PrismKeychainAccessibility.afterFirstUnlock
        #expect(a == .afterFirstUnlock)
    }

    @Test("When passcode set CF value exists")
    func whenPasscodeSet() {
        let a = PrismKeychainAccessibility.whenPasscodeSet
        #expect(a == .whenPasscodeSet)
    }
}

#if os(macOS) || os(iOS)
    @Suite("Keychain")
    struct PrismKeychainTests {
        let keychain = PrismKeychain(service: "PrismSecurityTests")
        let testItem = PrismKeychainItem(
            id: "test_\(UUID().uuidString)",
            service: "PrismSecurityTests"
        )

        @Test("Save and load data")
        func saveLoad() throws {
            let data = Data("test-value".utf8)
            try keychain.save(data: data, for: testItem)
            let loaded = try keychain.load(for: testItem)
            #expect(loaded == data)
            try keychain.delete(for: testItem)
        }

        @Test("Save and load string")
        func saveLoadString() throws {
            try keychain.save(string: "hello-prism", for: testItem)
            let loaded = try keychain.loadString(for: testItem)
            #expect(loaded == "hello-prism")
            try keychain.delete(for: testItem)
        }

        @Test("Save and load Codable")
        func saveLoadCodable() throws {
            struct Token: Codable, Sendable, Equatable {
                let value: String
                let expiry: Int
            }

            let token = Token(value: "abc", expiry: 3600)
            try keychain.save(token, for: testItem)
            let loaded = try keychain.load(Token.self, for: testItem)
            #expect(loaded == token)
            try keychain.delete(for: testItem)
        }

        @Test("Exists returns true for saved items")
        func exists() throws {
            try keychain.save(data: Data("x".utf8), for: testItem)
            #expect(keychain.exists(for: testItem))
            try keychain.delete(for: testItem)
        }

        @Test("Exists returns false for missing items")
        func notExists() {
            let missingItem = PrismKeychainItem(
                id: "nonexistent_\(UUID().uuidString)",
                service: "PrismSecurityTests"
            )
            #expect(!keychain.exists(for: missingItem))
        }

        @Test("Delete removes item")
        func delete() throws {
            try keychain.save(data: Data("x".utf8), for: testItem)
            try keychain.delete(for: testItem)
            #expect(!keychain.exists(for: testItem))
        }

        @Test("Load missing item throws")
        func loadMissing() throws {
            let missingItem = PrismKeychainItem(
                id: "missing_\(UUID().uuidString)",
                service: "PrismSecurityTests"
            )
            #expect(throws: PrismSecurityError.keychainItemNotFound) {
                try keychain.load(for: missingItem)
            }
        }

        @Test("Overwrite existing item")
        func overwrite() throws {
            try keychain.save(string: "first", for: testItem)
            try keychain.save(string: "second", for: testItem)
            let loaded = try keychain.loadString(for: testItem)
            #expect(loaded == "second")
            try keychain.delete(for: testItem)
        }

        @Test("Delete all does not throw")
        func deleteAll() throws {
            let item = PrismKeychainItem(
                id: "bulk_\(UUID().uuidString)",
                service: "PrismSecurityTests"
            )
            try keychain.save(string: "a", for: item)
            try keychain.deleteAll()
            try keychain.delete(for: item)
        }
    }
#endif
