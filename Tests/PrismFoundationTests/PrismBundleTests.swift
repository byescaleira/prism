import Foundation
import Testing

@testable import PrismFoundation

struct PrismBundleTests {
    @Test
    func readsInjectedBundleMetadata() {
        let version = OperatingSystemVersion(
            majorVersion: 26,
            minorVersion: 4,
            patchVersion: 1
        )

        let bundle = PrismBundle(
            infoDictionary: [
                "CFBundleName": "PrismApp",
                "CFBundleIdentifier": "com.prism.app",
                "CFBundleShortVersionString": "1.2.3",
                "CFBundleVersion": "456",
            ],
            operatingSystemVersion: version
        )

        #expect(bundle.applicationName == "PrismApp")
        #expect(bundle.applicationIdentifier == "com.prism.app")
        #expect(bundle.applicationVersion == "1.2.3")
        #expect(bundle.applicationBuild == "456")
        #expect(bundle.operatingSystemVersion.majorVersion == 26)
        #expect(bundle.operatingSystemVersion.minorVersion == 4)
        #expect(bundle.operatingSystemVersion.patchVersion == 1)
    }

    @Test
    func returnsNilWhenMetadataIsMissing() {
        let bundle = PrismBundle(infoDictionary: nil)

        #expect(bundle.applicationName == nil)
        #expect(bundle.applicationIdentifier == nil)
        #expect(bundle.applicationVersion == nil)
        #expect(bundle.applicationBuild == nil)
    }
}
