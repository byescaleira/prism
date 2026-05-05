import Foundation
import Testing

@testable import PrismSecurity

@Suite("BioTypes")
struct PrismBiometricTypeTests {
    @Test("All types have display names")
    func displayNames() {
        for type in PrismBiometricType.allCases {
            #expect(!type.displayName.isEmpty)
        }
    }

    @Test("None type")
    func noneType() {
        #expect(PrismBiometricType.none.displayName == "None")
    }

    @Test("FaceID type")
    func faceID() {
        #expect(PrismBiometricType.faceID.displayName == "Face ID")
        #expect(PrismBiometricType.faceID.rawValue == "faceID")
    }

    @Test("TouchID type")
    func touchID() {
        #expect(PrismBiometricType.touchID.displayName == "Touch ID")
    }

    @Test("OpticID type")
    func opticID() {
        #expect(PrismBiometricType.opticID.displayName == "Optic ID")
    }

    @Test("All cases count")
    func count() {
        #expect(PrismBiometricType.allCases.count == 4)
    }
}

@Suite("BioPolicy")
struct PrismBiometricPolicyTests {
    @Test("Biometrics only does not allow passcode")
    func biometricsOnly() {
        #expect(!PrismBiometricPolicy.biometricsOnly.allowsPasscodeFallback)
    }

    @Test("Biometrics or passcode allows passcode")
    func biometricsOrPasscode() {
        #expect(PrismBiometricPolicy.biometricsOrPasscode.allowsPasscodeFallback)
    }
}
