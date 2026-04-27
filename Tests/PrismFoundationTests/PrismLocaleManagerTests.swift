import Foundation
import Testing

@testable import PrismFoundation

struct PrismLocaleManagerTests {

    @MainActor
    @Test
    func defaultInitResolvesToCurrentLocale() {
        let manager = PrismLocaleManager(persistsSelection: false)
        #expect(PrismLocale.allCases.contains(manager.current))
    }

    @MainActor
    @Test
    func explicitInitialLocaleIsRespected() {
        let manager = PrismLocaleManager(initial: .japaneseJP, persistsSelection: false)
        #expect(manager.current == .japaneseJP)
    }

    @MainActor
    @Test
    func availableLocalesDefaultsToAll() {
        let manager = PrismLocaleManager(persistsSelection: false)
        #expect(manager.available == PrismLocale.allCases.map { $0 })
    }

    @MainActor
    @Test
    func customAvailableLocalesIsRespected() {
        let subset: [PrismLocale] = [.englishUS, .portugueseBR]
        let manager = PrismLocaleManager(
            initial: .englishUS,
            available: subset,
            persistsSelection: false
        )
        #expect(manager.available == subset)
    }

    @MainActor
    @Test
    func changingCurrentUpdatesValue() {
        let manager = PrismLocaleManager(initial: .englishUS, persistsSelection: false)
        manager.current = .frenchFR
        #expect(manager.current == .frenchFR)
    }

    @MainActor
    @Test
    func persistenceWritesToUserDefaults() {
        let key = "com.prism.selectedLocale"
        UserDefaults.standard.removeObject(forKey: key)

        let manager = PrismLocaleManager(initial: .englishUS, persistsSelection: true)
        manager.current = .germanDE

        let stored = UserDefaults.standard.string(forKey: key)
        #expect(stored == "de_DE")

        UserDefaults.standard.removeObject(forKey: key)
    }

    @MainActor
    @Test
    func persistenceRestoresFromUserDefaults() {
        let key = "com.prism.selectedLocale"
        UserDefaults.standard.set("es_ES", forKey: key)

        let manager = PrismLocaleManager(persistsSelection: false)
        // When no explicit initial is given and persistence has a value,
        // the restored locale should be used. However, persistsSelection:false
        // means it still reads but doesn't write.
        // The implementation uses Self.restoredLocale() which reads the key.
        let restoredManager = PrismLocaleManager(persistsSelection: true)
        #expect(restoredManager.current == .spanishES)

        UserDefaults.standard.removeObject(forKey: key)
        _ = manager
    }

    @MainActor
    @Test
    func disabledPersistenceDoesNotWriteToUserDefaults() {
        let key = "com.prism.selectedLocale"
        UserDefaults.standard.removeObject(forKey: key)

        let manager = PrismLocaleManager(initial: .englishUS, persistsSelection: false)
        manager.current = .arabicSA

        let stored = UserDefaults.standard.string(forKey: key)
        #expect(stored == nil)
    }
}
