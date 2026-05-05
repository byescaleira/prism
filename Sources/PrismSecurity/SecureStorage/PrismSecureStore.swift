import CryptoKit
import Foundation

/// High-level secure storage combining encryption + keychain in one call.
///
/// Encrypts data with AES-GCM or ChaChaPoly, stores the encryption key in the Keychain
/// (optionally biometric-protected), and persists the encrypted payload alongside it.
///
/// ```swift
/// let store = PrismSecureStore()
///
/// // Save
/// try store.save("secret-token", forKey: "apiToken")
///
/// // Load
/// let token: String = try store.load(String.self, forKey: "apiToken")
///
/// // Delete
/// try store.delete(forKey: "apiToken")
/// ```
public struct PrismSecureStore: Sendable {
    private let encryptor: PrismEncryptor
    private let keychain: PrismKeychain
    private let configuration: PrismSecureStoreConfiguration

    /// Creates a secure store with the given configuration.
    public init(configuration: PrismSecureStoreConfiguration = .default) {
        self.encryptor = PrismEncryptor(algorithm: configuration.algorithm)
        self.keychain = PrismKeychain(service: configuration.service)
        self.configuration = configuration
    }

    // MARK: - Codable Operations

    /// Encrypts and stores a Codable value.
    /// - Parameters:
    ///   - value: Value to store securely.
    ///   - key: Storage key identifier.
    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            throw PrismSecurityError.serializationFailed
        }

        try saveData(data, forKey: key)
    }

    /// Loads and decrypts a Codable value.
    /// - Parameters:
    ///   - type: Expected value type.
    ///   - key: Storage key identifier.
    /// - Returns: Decrypted and decoded value.
    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) throws -> T {
        let data = try loadData(forKey: key)

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw PrismSecurityError.deserializationFailed
        }
    }

    // MARK: - String Operations

    /// Encrypts and stores a string value.
    public func save(_ string: String, forKey key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw PrismSecurityError.serializationFailed
        }
        try saveData(data, forKey: key)
    }

    /// Loads and decrypts a string value.
    public func loadString(forKey key: String) throws -> String {
        let data = try loadData(forKey: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw PrismSecurityError.deserializationFailed
        }
        return string
    }

    // MARK: - Data Operations

    /// Encrypts and stores raw data.
    public func saveData(_ data: Data, forKey key: String) throws {
        let encryptionKey = try getOrCreateEncryptionKey(forKey: key)
        let encrypted = try encryptor.encrypt(data, using: encryptionKey)

        let dataItem = PrismKeychainItem(
            id: "data_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        try keychain.save(data: encrypted, for: dataItem)
    }

    /// Loads and decrypts raw data.
    public func loadData(forKey key: String) throws -> Data {
        let encryptionKey = try loadEncryptionKey(forKey: key)

        let dataItem = PrismKeychainItem(
            id: "data_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        let encrypted = try keychain.load(for: dataItem)
        return try encryptor.decrypt(encrypted, using: encryptionKey)
    }

    // MARK: - Management

    /// Deletes a stored value and its encryption key.
    public func delete(forKey key: String) throws {
        let keyItem = PrismKeychainItem(
            id: "key_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        let dataItem = PrismKeychainItem(
            id: "data_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        try keychain.delete(for: keyItem)
        try keychain.delete(for: dataItem)
    }

    /// Whether a value exists for the given key.
    public func exists(forKey key: String) -> Bool {
        let dataItem = PrismKeychainItem(
            id: "data_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        return keychain.exists(for: dataItem)
    }

    /// Deletes all stored values and keys.
    public func deleteAll() throws {
        try keychain.deleteAll()
    }

    // MARK: - Private Key Management

    private func getOrCreateEncryptionKey(forKey key: String) throws -> SymmetricKey {
        let keyItem = PrismKeychainItem(
            id: "key_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )

        if keychain.exists(for: keyItem) {
            let keyData = try keychain.load(for: keyItem)
            return SymmetricKey(data: keyData)
        }

        let newKey = encryptor.generateKey()
        let keyData = encryptor.exportKey(newKey)
        try keychain.save(data: keyData, for: keyItem)
        return newKey
    }

    private func loadEncryptionKey(forKey key: String) throws -> SymmetricKey {
        let keyItem = PrismKeychainItem(
            id: "key_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        let keyData = try keychain.load(for: keyItem)
        return SymmetricKey(data: keyData)
    }
}
