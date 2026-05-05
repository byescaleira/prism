import Foundation

/// Errors thrown by PrismSecurity operations.
public enum PrismSecurityError: Error, Sendable, Equatable, LocalizedError {
    // MARK: - Permission

    case permissionDenied(String)
    case permissionRestricted(String)
    case permissionNotAvailable(String)

    // MARK: - Biometric

    case biometricNotAvailable
    case biometricNotEnrolled
    case biometricLockout
    case biometricAuthenticationFailed
    case biometricUserCancel
    case biometricSystemCancel

    // MARK: - Keychain

    case keychainItemNotFound
    case keychainDuplicateItem
    case keychainAccessDenied
    case keychainOperationFailed(status: Int32)
    case keychainDataConversionFailed

    // MARK: - Encryption

    case encryptionFailed(String)
    case decryptionFailed(String)
    case invalidKey
    case invalidData

    // MARK: - Secure Enclave

    case secureEnclaveNotAvailable
    case secureEnclaveKeyGenerationFailed
    case secureEnclaveSigningFailed

    // MARK: - Secure Store

    case serializationFailed
    case deserializationFailed

    public var errorDescription: String? {
        switch self {
        case .permissionDenied(let permission):
            "Permission denied: \(permission)"
        case .permissionRestricted(let permission):
            "Permission restricted: \(permission)"
        case .permissionNotAvailable(let permission):
            "Permission not available: \(permission)"
        case .biometricNotAvailable:
            "Biometric authentication is not available on this device"
        case .biometricNotEnrolled:
            "No biometric data is enrolled on this device"
        case .biometricLockout:
            "Biometric authentication is locked out due to too many failed attempts"
        case .biometricAuthenticationFailed:
            "Biometric authentication failed"
        case .biometricUserCancel:
            "Biometric authentication was cancelled by the user"
        case .biometricSystemCancel:
            "Biometric authentication was cancelled by the system"
        case .keychainItemNotFound:
            "Keychain item not found"
        case .keychainDuplicateItem:
            "Keychain item already exists"
        case .keychainAccessDenied:
            "Access to keychain item was denied"
        case .keychainOperationFailed(let status):
            "Keychain operation failed with status: \(status)"
        case .keychainDataConversionFailed:
            "Failed to convert keychain data"
        case .encryptionFailed(let reason):
            "Encryption failed: \(reason)"
        case .decryptionFailed(let reason):
            "Decryption failed: \(reason)"
        case .invalidKey:
            "Invalid encryption key"
        case .invalidData:
            "Invalid data for cryptographic operation"
        case .secureEnclaveNotAvailable:
            "Secure Enclave is not available on this device"
        case .secureEnclaveKeyGenerationFailed:
            "Failed to generate key in Secure Enclave"
        case .secureEnclaveSigningFailed:
            "Failed to sign data with Secure Enclave key"
        case .serializationFailed:
            "Failed to serialize data for secure storage"
        case .deserializationFailed:
            "Failed to deserialize data from secure storage"
        }
    }
}
