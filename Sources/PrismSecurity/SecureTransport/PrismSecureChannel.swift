import CryptoKit
import Foundation

/// Bidirectional encrypted communication channel using ECDH key agreement.
///
/// ```swift
/// let alice = PrismSecureChannel()
/// let bob = PrismSecureChannel()
///
/// try alice.establish(with: bob.publicKeyData)
/// try bob.establish(with: alice.publicKeyData)
///
/// let encrypted = try alice.encrypt(Data("Hello Bob".utf8))
/// let decrypted = try bob.decrypt(encrypted)
/// ```
public final class PrismSecureChannel: Sendable {
    private let keyAgreement: PrismKeyAgreement
    private let encryptor: PrismEncryptor
    private let lock = NSLock()
    nonisolated(unsafe) private var _sharedKey: SymmetricKey?

    /// Public key data to share with remote party.
    public var publicKeyData: Data {
        keyAgreement.publicKeyData
    }

    /// Whether the channel has been established.
    public var isEstablished: Bool {
        lock.withLock { _sharedKey != nil }
    }

    /// Creates a new secure channel.
    /// - Parameter algorithm: Encryption algorithm for the channel. Defaults to `.aesGCM`.
    public init(algorithm: PrismEncryptor.Algorithm = .aesGCM) {
        self.keyAgreement = PrismKeyAgreement()
        self.encryptor = PrismEncryptor(algorithm: algorithm)
    }

    /// Establishes the channel using the remote party's public key.
    /// - Parameter remotePublicKeyData: Remote party's raw P256 public key.
    public func establish(with remotePublicKeyData: Data) throws {
        let sharedKey = try keyAgreement.deriveSharedSecret(with: remotePublicKeyData)
        lock.withLock { _sharedKey = sharedKey }
    }

    /// Encrypts data for transmission through the channel.
    public func encrypt(_ data: Data) throws -> Data {
        guard let key = lock.withLock({ _sharedKey }) else {
            throw PrismSecurityError.invalidKey
        }
        return try encryptor.encrypt(data, using: key)
    }

    /// Decrypts data received through the channel.
    public func decrypt(_ data: Data) throws -> Data {
        guard let key = lock.withLock({ _sharedKey }) else {
            throw PrismSecurityError.invalidKey
        }
        return try encryptor.decrypt(data, using: key)
    }

    /// Encrypts a Codable value.
    public func encrypt<T: Codable & Sendable>(_ value: T) throws -> Data {
        let data = try JSONEncoder().encode(value)
        return try encrypt(data)
    }

    /// Decrypts data into a Codable value.
    public func decrypt<T: Codable & Sendable>(_ type: T.Type, from data: Data) throws -> T {
        let decrypted = try decrypt(data)
        return try JSONDecoder().decode(type, from: decrypted)
    }

    /// Closes the channel and zeroes the shared key.
    public func close() {
        lock.withLock { _sharedKey = nil }
    }
}
