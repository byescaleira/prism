import Foundation

/// Configuration for PrismSecureStore.
public struct PrismSecureStoreConfiguration: Sendable {
    /// Encryption algorithm to use.
    public let algorithm: PrismEncryptor.Algorithm
    /// Keychain service identifier.
    public let service: String
    /// Keychain access control for encryption keys.
    public let keyAccessControl: PrismKeychainAccessControl
    /// Whether to sync the encryption key via iCloud Keychain.
    public let synchronizeKey: Bool

    /// Default configuration: AES-GCM, standard keychain access, no sync.
    public static let `default` = PrismSecureStoreConfiguration(
        algorithm: .aesGCM,
        service: "PrismSecureStore",
        keyAccessControl: .default,
        synchronizeKey: false
    )

    /// Biometric-protected: requires Face ID/Touch ID to access.
    public static let biometricProtected = PrismSecureStoreConfiguration(
        algorithm: .aesGCM,
        service: "PrismSecureStore",
        keyAccessControl: .biometricAny,
        synchronizeKey: false
    )

    /// High security: ChaChaPoly + biometric + no sync.
    public static let highSecurity = PrismSecureStoreConfiguration(
        algorithm: .chaChaPoly,
        service: "PrismSecureStore",
        keyAccessControl: .biometricCurrentSet,
        synchronizeKey: false
    )

    public init(
        algorithm: PrismEncryptor.Algorithm = .aesGCM,
        service: String = "PrismSecureStore",
        keyAccessControl: PrismKeychainAccessControl = .default,
        synchronizeKey: Bool = false
    ) {
        self.algorithm = algorithm
        self.service = service
        self.keyAccessControl = keyAccessControl
        self.synchronizeKey = synchronizeKey
    }
}
