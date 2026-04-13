import Foundation
import Testing

@testable import PrismFoundation

struct PrismDefaultsTests {
    @Test
    func storesAndLoadsCodableValues() throws {
        let suiteName = "prism.tests.defaults.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let defaults = PrismDefaults(userDefaults: userDefaults)
        let expected = SampleSettings(
            username: "rafael",
            launchCount: 7
        )

        defaults.set(expected, for: "settings")

        let stored: SampleSettings? = defaults.get(for: "settings")
        #expect(stored == expected)
    }

    @Test
    func returnsNilForMissingKeys() throws {
        let suiteName = "prism.tests.defaults.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let defaults = PrismDefaults(userDefaults: userDefaults)
        let stored: SampleSettings? = defaults.get(for: "missing")

        #expect(stored == nil)
    }

    @Test
    func removesStoredValuesWhenSettingNil() throws {
        let suiteName = "prism.tests.defaults.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let defaults = PrismDefaults(userDefaults: userDefaults)
        defaults.set(
            SampleSettings(
                username: "rafael",
                launchCount: 7
            ),
            for: "settings"
        )

        defaults.set(Optional<SampleSettings>.none, for: "settings")

        let stored: SampleSettings? = defaults.get(for: "settings")
        #expect(stored == nil)
    }

    @Test
    func returnsNilForCorruptedStoredData() throws {
        let suiteName = "prism.tests.defaults.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        userDefaults.set(Data([0xFF, 0xFE, 0xFD]), forKey: "settings")

        let defaults = PrismDefaults(userDefaults: userDefaults)
        let stored: SampleSettings? = defaults.get(for: "settings")

        #expect(stored == nil)
    }

    @Test
    func ignoresValuesThatCannotBeEncoded() throws {
        let suiteName = "prism.tests.defaults.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let defaults = PrismDefaults(userDefaults: userDefaults)
        defaults.set(BrokenCodable(), for: "broken")

        #expect(userDefaults.data(forKey: "broken") == nil)
    }

    @Test
    func defaultInitializerProvidesAWorkingStore() {
        let key = "prism.tests.defaults.default.\(UUID().uuidString)"
        let expected = SampleSettings(username: "rafael", launchCount: 11)
        let defaults = PrismDefaults()
        defer { defaults.userDefaults.removeObject(forKey: key) }

        defaults.set(expected, for: key)

        let stored: SampleSettings? = defaults.get(for: key)
        #expect(stored == expected)
    }

    @Test
    func userDefaultsFactoryUsesSuiteWhenAvailableAndFallbackOtherwise() throws {
        let suiteName = "prism.tests.defaults.factory.\(UUID().uuidString)"
        let suiteDefaults = try #require(UserDefaults(suiteName: suiteName))
        let fallbackDefaults = UserDefaults()

        let resolved = PrismDefaults.makeUserDefaults(
            suiteName: suiteName,
            makeSuite: { _ in suiteDefaults },
            fallback: fallbackDefaults
        )
        let fallback = PrismDefaults.makeUserDefaults(
            suiteName: suiteName,
            makeSuite: { _ in nil },
            fallback: fallbackDefaults
        )

        #expect(resolved === suiteDefaults)
        #expect(fallback === fallbackDefaults)
    }
}
