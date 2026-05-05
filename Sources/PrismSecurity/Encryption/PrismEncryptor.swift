import CryptoKit
import Foundation

/// Symmetric encryption using AES-GCM or ChaChaPoly via CryptoKit.
public struct PrismEncryptor: Sendable {
    /// Encryption algorithm selection.
    public enum Algorithm: String, Sendable, Hashable, CaseIterable {
        case aesGCM
        case chaChaPoly
    }

    private let algorithm: Algorithm

    /// Creates an encryptor with the specified algorithm.
    /// - Parameter algorithm: Encryption algorithm. Defaults to `.aesGCM`.
    public init(algorithm: Algorithm = .aesGCM) {
        self.algorithm = algorithm
    }

    /// Generates a new random 256-bit symmetric key.
    public func generateKey() -> SymmetricKey {
        SymmetricKey(size: .bits256)
    }

    /// Exports a symmetric key as raw data.
    public func exportKey(_ key: SymmetricKey) -> Data {
        key.withUnsafeBytes { Data($0) }
    }

    /// Imports a symmetric key from raw data.
    public func importKey(_ data: Data) -> SymmetricKey {
        SymmetricKey(data: data)
    }

    /// Encrypts data using the configured algorithm.
    /// - Parameters:
    ///   - data: Plaintext data.
    ///   - key: Symmetric key for encryption.
    /// - Returns: Combined sealed box data (nonce + ciphertext + tag).
    public func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        switch algorithm {
        case .aesGCM:
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let combined = sealedBox.combined else {
                throw PrismSecurityError.encryptionFailed("Failed to produce combined sealed box")
            }
            return combined
        case .chaChaPoly:
            let sealedBox = try ChaChaPoly.seal(data, using: key)
            return sealedBox.combined
        }
    }

    /// Decrypts data using the configured algorithm.
    /// - Parameters:
    ///   - data: Combined sealed box data.
    ///   - key: Symmetric key used for encryption.
    /// - Returns: Decrypted plaintext data.
    public func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            switch algorithm {
            case .aesGCM:
                let sealedBox = try AES.GCM.SealedBox(combined: data)
                return try AES.GCM.open(sealedBox, using: key)
            case .chaChaPoly:
                let sealedBox = try ChaChaPoly.SealedBox(combined: data)
                return try ChaChaPoly.open(sealedBox, using: key)
            }
        } catch {
            throw PrismSecurityError.decryptionFailed(error.localizedDescription)
        }
    }

    /// Encrypts a Codable value.
    public func encrypt<T: Codable & Sendable>(_ value: T, using key: SymmetricKey) throws -> Data {
        let data = try JSONEncoder().encode(value)
        return try encrypt(data, using: key)
    }

    /// Decrypts data into a Codable value.
    public func decrypt<T: Codable & Sendable>(_ type: T.Type, from data: Data, using key: SymmetricKey) throws -> T {
        let decrypted = try decrypt(data, using: key)
        do {
            return try JSONDecoder().decode(type, from: decrypted)
        } catch {
            throw PrismSecurityError.deserializationFailed
        }
    }
}
