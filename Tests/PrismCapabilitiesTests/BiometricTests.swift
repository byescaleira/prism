import Testing

@testable import PrismCapabilities

// MARK: - Biometric Tests

@Suite("PrismBiometric")
struct PrismBiometricTests {

    // MARK: - PrismBiometricType

    @Test("PrismBiometricType has 4 cases")
    func biometricTypeCaseCount() {
        #expect(PrismBiometricType.allCases.count == 4)
    }

    @Test("PrismBiometricType includes all expected cases")
    func biometricTypeCases() {
        let cases = PrismBiometricType.allCases
        #expect(cases.contains(.none))
        #expect(cases.contains(.touchID))
        #expect(cases.contains(.faceID))
        #expect(cases.contains(.opticID))
    }

    // MARK: - PrismBiometricPolicy

    @Test("PrismBiometricPolicy has 2 cases")
    func biometricPolicyCaseCount() {
        #expect(PrismBiometricPolicy.allCases.count == 2)
    }

    @Test("PrismBiometricPolicy includes all expected cases")
    func biometricPolicyCases() {
        let cases = PrismBiometricPolicy.allCases
        #expect(cases.contains(.deviceOwnerAuthenticationWithBiometrics))
        #expect(cases.contains(.deviceOwnerAuthentication))
    }

    // MARK: - PrismBiometricError

    @Test("PrismBiometricError has 8 cases")
    func biometricErrorCaseCount() {
        #expect(PrismBiometricError.allCases.count == 8)
    }

    @Test("PrismBiometricError includes all expected cases")
    func biometricErrorCases() {
        let cases = PrismBiometricError.allCases
        #expect(cases.contains(.authenticationFailed))
        #expect(cases.contains(.userCancel))
        #expect(cases.contains(.userFallback))
        #expect(cases.contains(.systemCancel))
        #expect(cases.contains(.passcodeNotSet))
        #expect(cases.contains(.biometryNotAvailable))
        #expect(cases.contains(.biometryNotEnrolled))
        #expect(cases.contains(.biometryLockout))
    }

    // MARK: - PrismBiometricResult

    @Test("PrismBiometricResult stores success correctly")
    func biometricResultSuccess() {
        let result = PrismBiometricResult(success: true)
        #expect(result.success == true)
        #expect(result.error == nil)
    }

    @Test("PrismBiometricResult stores failure with error correctly")
    func biometricResultFailure() {
        let result = PrismBiometricResult(success: false, error: .userCancel)
        #expect(result.success == false)
        #expect(result.error == .userCancel)
    }

    @Test("PrismBiometricResult defaults error to nil")
    func biometricResultDefaults() {
        let result = PrismBiometricResult(success: false)
        #expect(result.success == false)
        #expect(result.error == nil)
    }

    @Test("PrismBiometricResult stores each error type")
    func biometricResultAllErrors() {
        for errorCase in PrismBiometricError.allCases {
            let result = PrismBiometricResult(success: false, error: errorCase)
            #expect(result.error == errorCase)
            #expect(result.success == false)
        }
    }
}
