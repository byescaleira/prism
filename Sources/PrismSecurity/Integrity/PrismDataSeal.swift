import CryptoKit
import Foundation

/// Signs and verifies data integrity using HMAC-SHA256.
///
/// ```swift
/// let seal = PrismDataSeal(key: myKey)
///
/// // Seal a value
/// let sealed = try seal.seal(myCredentials)
///
/// // Verify and extract
/// let verified = try seal.unseal(Credentials.self, from: sealed)
/// ```
public struct PrismDataSeal: Sendable {
    private let key: SymmetricKey

    /// Creates a data seal with the given HMAC key.
    public init(key: SymmetricKey) {
        self.key = key
    }

    /// Creates a data seal with a key stored in the keychain.
    public init(keychain: PrismKeychain = PrismKeychain(), keyID: String = "PrismDataSeal") throws {
        let item = PrismKeychainItem(id: keyID, service: "PrismDataSeal")
        if keychain.exists(for: item) {
            let keyData = try keychain.load(for: item)
            self.key = SymmetricKey(data: keyData)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            try keychain.save(data: keyData, for: item)
            self.key = newKey
        }
    }

    /// Sealed data container with payload + HMAC.
    public struct SealedData: Codable, Sendable, Equatable {
        public let payload: Data
        public let mac: Data
        public let sealedAt: Date
    }

    /// Seals a Codable value with HMAC signature.
    public func seal<T: Codable & Sendable>(_ value: T) throws -> SealedData {
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            throw PrismSecurityError.serializationFailed
        }
        return sealData(data)
    }

    /// Seals raw data with HMAC signature.
    public func sealData(_ data: Data) -> SealedData {
        let mac = Data(HMAC<SHA256>.authenticationCode(for: data, using: key))
        return SealedData(payload: data, mac: mac, sealedAt: .now)
    }

    /// Verifies and extracts a Codable value from sealed data.
    public func unseal<T: Codable & Sendable>(_ type: T.Type, from sealed: SealedData) throws -> T {
        guard verify(sealed) else {
            throw PrismSecurityError.decryptionFailed("Data integrity check failed — HMAC mismatch")
        }
        do {
            return try JSONDecoder().decode(type, from: sealed.payload)
        } catch {
            throw PrismSecurityError.deserializationFailed
        }
    }

    /// Verifies the HMAC of sealed data without extracting.
    public func verify(_ sealed: SealedData) -> Bool {
        HMAC<SHA256>.isValidAuthenticationCode(sealed.mac, authenticating: sealed.payload, using: key)
    }

    /// Verifies raw data against a MAC.
    public func verify(data: Data, mac: Data) -> Bool {
        HMAC<SHA256>.isValidAuthenticationCode(mac, authenticating: data, using: key)
    }
}
