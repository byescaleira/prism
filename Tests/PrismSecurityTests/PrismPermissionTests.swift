import Foundation
import Testing

@testable import PrismSecurity

@Suite("PermTypes")
struct PrismPermissionTypeTests {
    @Test("All permissions have display names")
    func displayNames() {
        for permission in PrismPermission.allCases {
            #expect(!permission.displayName.isEmpty)
        }
    }

    @Test("All permissions have usage description keys")
    func usageKeys() {
        for permission in PrismPermission.allCases {
            #expect(permission.usageDescriptionKey.hasPrefix("NS"))
        }
    }

    @Test("Permission raw values are unique")
    func uniqueRawValues() {
        let rawValues = PrismPermission.allCases.map(\.rawValue)
        #expect(Set(rawValues).count == rawValues.count)
    }

    @Test("Camera permission properties")
    func camera() {
        let perm = PrismPermission.camera
        #expect(perm.displayName == "Camera")
        #expect(perm.usageDescriptionKey == "NSCameraUsageDescription")
    }

    @Test("FaceID permission properties")
    func faceID() {
        let perm = PrismPermission.faceID
        #expect(perm.displayName == "Face ID")
        #expect(perm.usageDescriptionKey == "NSFaceIDUsageDescription")
    }

    @Test("Total permission count")
    func count() {
        #expect(PrismPermission.allCases.count == 16)
    }
}

@Suite("PermStatus")
struct PrismPermissionStatusTests {
    @Test("Authorized grants access")
    func authorized() {
        #expect(PrismPermissionStatus.authorized.isGranted)
        #expect(!PrismPermissionStatus.authorized.canRequest)
    }

    @Test("Limited grants access")
    func limited() {
        #expect(PrismPermissionStatus.limited.isGranted)
    }

    @Test("Provisional grants access")
    func provisional() {
        #expect(PrismPermissionStatus.provisional.isGranted)
    }

    @Test("Denied does not grant access")
    func denied() {
        #expect(!PrismPermissionStatus.denied.isGranted)
        #expect(!PrismPermissionStatus.denied.canRequest)
    }

    @Test("Restricted does not grant access")
    func restricted() {
        #expect(!PrismPermissionStatus.restricted.isGranted)
    }

    @Test("NotDetermined can request")
    func notDetermined() {
        #expect(!PrismPermissionStatus.notDetermined.isGranted)
        #expect(PrismPermissionStatus.notDetermined.canRequest)
    }

    @Test("All cases covered")
    func allCases() {
        #expect(PrismPermissionStatus.allCases.count == 6)
    }
}

@Suite("PermChange")
struct PrismPermissionChangeTests {
    @Test("Change equality")
    func equality() {
        let a = PrismPermissionChange(
            permission: .camera,
            oldStatus: .notDetermined,
            newStatus: .authorized
        )
        let b = PrismPermissionChange(
            permission: .camera,
            oldStatus: .notDetermined,
            newStatus: .authorized
        )
        #expect(a == b)
    }

    @Test("Change inequality")
    func inequality() {
        let a = PrismPermissionChange(
            permission: .camera,
            oldStatus: .notDetermined,
            newStatus: .authorized
        )
        let b = PrismPermissionChange(
            permission: .microphone,
            oldStatus: .notDetermined,
            newStatus: .authorized
        )
        #expect(a != b)
    }
}
