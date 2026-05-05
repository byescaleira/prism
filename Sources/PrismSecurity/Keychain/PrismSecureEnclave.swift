import CryptoKit
import Foundation
import Security

/// Hardware-backed key generation and signing using the Secure Enclave.
public struct PrismSecureEnclave: Sendable {
    private let keychain: PrismKeychain

    public init(keychain: PrismKeychain = PrismKeychain(service: "PrismSecureEnclave")) {
        self.keychain = keychain
    }

    /// Whether Secure Enclave is available on this device.
    public static var isAvailable: Bool {
        SecureEnclave.isAvailable
    }

    /// Generates a P256 key pair in the Secure Enclave and stores a reference.
    /// - Parameter tag: Unique identifier for the key pair.
    /// - Returns: The public key as raw representation.
    @discardableResult
    public func generateKeyPair(tag: String) throws -> Data {
        guard SecureEnclave.isAvailable else {
            throw PrismSecurityError.secureEnclaveNotAvailable
        }

        do {
            let privateKey = try SecureEnclave.P256.Signing.PrivateKey()
            let publicKeyData = privateKey.publicKey.rawRepresentation
            let privateKeyData = privateKey.dataRepresentation

            let item = PrismKeychainItem(
                id: "se_key_\(tag)",
                service: "PrismSecureEnclave",
                accessControl: .biometricCurrentSet
            )
            try keychain.save(data: privateKeyData, for: item)

            return publicKeyData
        } catch let error as PrismSecurityError {
            throw error
        } catch {
            throw PrismSecurityError.secureEnclaveKeyGenerationFailed
        }
    }

    /// Signs data using a Secure Enclave key.
    /// - Parameters:
    ///   - data: Data to sign.
    ///   - tag: Key pair identifier.
    /// - Returns: Signature as raw bytes.
    public func sign(data: Data, withKeyTagged tag: String) throws -> Data {
        guard SecureEnclave.isAvailable else {
            throw PrismSecurityError.secureEnclaveNotAvailable
        }

        do {
            let item = PrismKeychainItem(
                id: "se_key_\(tag)",
                service: "PrismSecureEnclave",
                accessControl: .biometricCurrentSet
            )
            let keyData = try keychain.load(for: item)
            let privateKey = try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: keyData)
            let signature = try privateKey.signature(for: data)
            return signature.rawRepresentation
        } catch let error as PrismSecurityError {
            throw error
        } catch {
            throw PrismSecurityError.secureEnclaveSigningFailed
        }
    }

    /// Verifies a signature against a public key.
    /// - Parameters:
    ///   - signature: Signature bytes.
    ///   - data: Original data.
    ///   - publicKey: Public key raw representation.
    /// - Returns: Whether the signature is valid.
    public func verify(signature: Data, for data: Data, publicKey: Data) throws -> Bool {
        let key = try P256.Signing.PublicKey(rawRepresentation: publicKey)
        let ecdsaSignature = try P256.Signing.ECDSASignature(rawRepresentation: signature)
        return key.isValidSignature(ecdsaSignature, for: data)
    }

    /// Deletes a key pair from the Secure Enclave keychain.
    public func deleteKeyPair(tag: String) throws {
        let item = PrismKeychainItem(
            id: "se_key_\(tag)",
            service: "PrismSecureEnclave",
            accessControl: .biometricCurrentSet
        )
        try keychain.delete(for: item)
    }
}
