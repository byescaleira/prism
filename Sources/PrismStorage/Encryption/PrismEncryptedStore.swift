import CryptoKit
import Foundation

/// Transparent encryption wrapper — encrypts values before delegating to an inner store.
public final class PrismEncryptedStore: PrismStorageProtocol, @unchecked Sendable {
    private let inner: PrismStorageProtocol
    private let key: SymmetricKey
    private let lock = NSLock()

    public init(wrapping store: PrismStorageProtocol, key: SymmetricKey) {
        self.inner = store
        self.key = key
    }

    public convenience init(wrapping store: PrismStorageProtocol, keyData: Data) {
        self.init(wrapping: store, key: SymmetricKey(data: keyData))
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) throws {
        let plaintext: Data
        do {
            plaintext = try JSONEncoder().encode(value)
        } catch {
            throw PrismStorageError.encodingFailed(key)
        }

        let encrypted = try encrypt(plaintext)
        lock.lock()
        defer { lock.unlock() }
        try inner.save(encrypted, forKey: key)
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) throws -> T? {
        lock.lock()
        let encrypted: Data? = try inner.load(Data.self, forKey: key)
        lock.unlock()

        guard let encrypted else { return nil }
        let plaintext = try decrypt(encrypted)

        do {
            return try JSONDecoder().decode(type, from: plaintext)
        } catch {
            throw PrismStorageError.decodingFailed(key)
        }
    }

    public func delete(forKey key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        try inner.delete(forKey: key)
    }

    public func exists(forKey key: String) throws -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return try inner.exists(forKey: key)
    }

    public func clear() throws {
        lock.lock()
        defer { lock.unlock() }
        try inner.clear()
    }

    public func keys() throws -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return try inner.keys()
    }

    // MARK: - Crypto

    private func encrypt(_ data: Data) throws -> Data {
        do {
            let sealed = try AES.GCM.seal(data, using: key)
            guard let combined = sealed.combined else {
                throw PrismStorageError.encryptionFailed
            }
            return combined
        } catch is PrismStorageError {
            throw PrismStorageError.encryptionFailed
        } catch {
            throw PrismStorageError.encryptionFailed
        }
    }

    private func decrypt(_ data: Data) throws -> Data {
        do {
            let box = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(box, using: key)
        } catch {
            throw PrismStorageError.decryptionFailed
        }
    }
}

/// Async variant wrapping an async store.
public actor PrismEncryptedAsyncStore: PrismAsyncStorageProtocol {
    private let inner: PrismAsyncStorageProtocol
    private let key: SymmetricKey

    public init(wrapping store: PrismAsyncStorageProtocol, key: SymmetricKey) {
        self.inner = store
        self.key = key
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) async throws {
        let plaintext: Data
        do {
            plaintext = try JSONEncoder().encode(value)
        } catch {
            throw PrismStorageError.encodingFailed(key)
        }
        let encrypted = try encrypt(plaintext)
        try await inner.save(encrypted, forKey: key)
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
        guard let encrypted: Data = try await inner.load(Data.self, forKey: key) else { return nil }
        let plaintext = try decrypt(encrypted)
        do {
            return try JSONDecoder().decode(type, from: plaintext)
        } catch {
            throw PrismStorageError.decodingFailed(key)
        }
    }

    public func delete(forKey key: String) async throws {
        try await inner.delete(forKey: key)
    }

    public func exists(forKey key: String) async throws -> Bool {
        try await inner.exists(forKey: key)
    }

    public func clear() async throws {
        try await inner.clear()
    }

    public func keys() async throws -> [String] {
        try await inner.keys()
    }

    private func encrypt(_ data: Data) throws -> Data {
        do {
            let sealed = try AES.GCM.seal(data, using: key)
            guard let combined = sealed.combined else {
                throw PrismStorageError.encryptionFailed
            }
            return combined
        } catch is PrismStorageError {
            throw PrismStorageError.encryptionFailed
        } catch {
            throw PrismStorageError.encryptionFailed
        }
    }

    private func decrypt(_ data: Data) throws -> Data {
        do {
            let box = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(box, using: key)
        } catch {
            throw PrismStorageError.decryptionFailed
        }
    }
}
