import CryptoKit
import Foundation

/// Key derivation functions for deriving encryption keys from passwords or other keys.
public struct PrismKeyDerivation: Sendable {
    public init() {}

    // MARK: - HKDF

    /// Derives a symmetric key using HKDF (HMAC-based Key Derivation Function).
    /// - Parameters:
    ///   - inputKey: Input keying material.
    ///   - salt: Optional salt value.
    ///   - info: Optional context and application-specific information.
    ///   - outputByteCount: Desired output key size in bytes. Defaults to 32 (256-bit).
    /// - Returns: Derived symmetric key.
    public func deriveKey(
        from inputKey: SymmetricKey,
        salt: Data? = nil,
        info: Data = Data(),
        outputByteCount: Int = 32
    ) -> SymmetricKey {
        let saltData = salt ?? Data(repeating: 0, count: 32)
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKey,
            salt: saltData,
            info: info,
            outputByteCount: outputByteCount
        )
    }

    /// Derives a symmetric key from a shared secret (e.g., from key agreement).
    public func deriveKey(
        from sharedSecret: Data,
        salt: Data? = nil,
        info: Data = Data(),
        outputByteCount: Int = 32
    ) -> SymmetricKey {
        let inputKey = SymmetricKey(data: sharedSecret)
        return deriveKey(from: inputKey, salt: salt, info: info, outputByteCount: outputByteCount)
    }

    // MARK: - Password-Based

    /// Derives a symmetric key from a password using PBKDF2-like construction via HKDF.
    /// - Parameters:
    ///   - password: User password.
    ///   - salt: Random salt. Generate with `generateSalt()`.
    ///   - outputByteCount: Desired key size. Defaults to 32.
    /// - Returns: Derived symmetric key.
    public func deriveKey(
        fromPassword password: String,
        salt: Data,
        outputByteCount: Int = 32
    ) -> SymmetricKey {
        let passwordData = Data(password.utf8)
        let inputKey = SymmetricKey(data: passwordData)
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKey,
            salt: salt,
            info: Data("PrismSecurity.PasswordDerived".utf8),
            outputByteCount: outputByteCount
        )
    }

    /// Generates a random salt for key derivation.
    /// - Parameter byteCount: Salt size in bytes. Defaults to 32.
    /// - Returns: Random salt data.
    public func generateSalt(byteCount: Int = 32) -> Data {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        _ = SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes)
        return Data(bytes)
    }
}
