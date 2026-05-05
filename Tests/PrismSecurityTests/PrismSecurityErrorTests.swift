import Foundation
import Testing

@testable import PrismSecurity

@Suite("SecErrors")
struct PrismSecurityErrorTests {
    @Test("All errors have descriptions")
    func errorDescriptions() {
        let errors: [PrismSecurityError] = [
            .permissionDenied("camera"),
            .permissionRestricted("photos"),
            .permissionNotAvailable("bluetooth"),
            .biometricNotAvailable,
            .biometricNotEnrolled,
            .biometricLockout,
            .biometricAuthenticationFailed,
            .biometricUserCancel,
            .biometricSystemCancel,
            .keychainItemNotFound,
            .keychainDuplicateItem,
            .keychainAccessDenied,
            .keychainOperationFailed(status: -25300),
            .keychainDataConversionFailed,
            .encryptionFailed("bad data"),
            .decryptionFailed("tampered"),
            .invalidKey,
            .invalidData,
            .secureEnclaveNotAvailable,
            .secureEnclaveKeyGenerationFailed,
            .secureEnclaveSigningFailed,
            .serializationFailed,
            .deserializationFailed,
        ]

        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(!error.errorDescription!.isEmpty)
        }
    }

    @Test("Permission errors include permission name")
    func permissionErrorContext() {
        let error = PrismSecurityError.permissionDenied("camera")
        #expect(error.errorDescription!.contains("camera"))
    }

    @Test("Keychain status included in error")
    func keychainStatus() {
        let error = PrismSecurityError.keychainOperationFailed(status: -25300)
        #expect(error.errorDescription!.contains("-25300"))
    }

    @Test("Encryption reason included in error")
    func encryptionReason() {
        let error = PrismSecurityError.encryptionFailed("invalid block size")
        #expect(error.errorDescription!.contains("invalid block size"))
    }

    @Test("Errors are equatable")
    func equatable() {
        #expect(PrismSecurityError.biometricNotAvailable == .biometricNotAvailable)
        #expect(PrismSecurityError.keychainItemNotFound != .keychainDuplicateItem)
        #expect(
            PrismSecurityError.permissionDenied("camera") == .permissionDenied("camera")
        )
        #expect(
            PrismSecurityError.permissionDenied("camera") != .permissionDenied("mic")
        )
    }

    @Test("Errors are sendable")
    func sendable() {
        let error: any Sendable = PrismSecurityError.biometricNotAvailable
        #expect(error is PrismSecurityError)
    }
}
