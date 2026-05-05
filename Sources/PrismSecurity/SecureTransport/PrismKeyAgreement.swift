import CryptoKit
import Foundation

/// P256 ECDH key agreement for establishing shared secrets.
///
/// ```swift
/// let alice = PrismKeyAgreement()
/// let bob = PrismKeyAgreement()
///
/// let sharedFromAlice = try alice.deriveSharedSecret(with: bob.publicKeyData)
/// let sharedFromBob = try bob.deriveSharedSecret(with: alice.publicKeyData)
/// // sharedFromAlice == sharedFromBob
/// ```
public struct PrismKeyAgreement: Sendable {
    private let privateKey: P256.KeyAgreement.PrivateKey

    /// Public key for sharing with the remote party.
    public var publicKey: P256.KeyAgreement.PublicKey {
        privateKey.publicKey
    }

    /// Public key as raw data for transmission.
    public var publicKeyData: Data {
        privateKey.publicKey.rawRepresentation
    }

    /// Creates a new key agreement with a fresh P256 key pair.
    public init() {
        self.privateKey = P256.KeyAgreement.PrivateKey()
    }

    /// Creates a key agreement from an existing private key.
    public init(privateKey: P256.KeyAgreement.PrivateKey) {
        self.privateKey = privateKey
    }

    /// Derives a shared symmetric key using ECDH + HKDF.
    /// - Parameters:
    ///   - remotePublicKeyData: Remote party's raw public key.
    ///   - salt: Optional salt for HKDF.
    ///   - info: Context info for HKDF. Defaults to "PrismSecureTransport".
    ///   - outputByteCount: Derived key size. Defaults to 32 (256-bit).
    /// - Returns: Derived symmetric key.
    public func deriveSharedSecret(
        with remotePublicKeyData: Data,
        salt: Data? = nil,
        info: Data = Data("PrismSecureTransport".utf8),
        outputByteCount: Int = 32
    ) throws -> SymmetricKey {
        let remotePublicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: remotePublicKeyData)
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: remotePublicKey)

        if let salt {
            return sharedSecret.hkdfDerivedSymmetricKey(
                using: SHA256.self,
                salt: salt,
                sharedInfo: info,
                outputByteCount: outputByteCount
            )
        }
        return sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: info,
            outputByteCount: outputByteCount
        )
    }

    /// Derives a shared secret from a PublicKey object.
    public func deriveSharedSecret(
        with remotePublicKey: P256.KeyAgreement.PublicKey,
        info: Data = Data("PrismSecureTransport".utf8),
        outputByteCount: Int = 32
    ) throws -> SymmetricKey {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: remotePublicKey)
        return sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: info,
            outputByteCount: outputByteCount
        )
    }
}
