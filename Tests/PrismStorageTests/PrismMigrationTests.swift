import Foundation
import Testing

@testable import PrismStorage

@Suite("MigStore")
struct PrismStorageMigrationTests {
    func makeMigrator() -> (PrismStorageMigrator, PrismDefaultsStore) {
        let store = PrismDefaultsStore(suite: "MigTest-\(UUID().uuidString)")
        return (PrismStorageMigrator(store: store), store)
    }

    @Test("Initial version is zero")
    func initialVersion() {
        let (migrator, _) = makeMigrator()
        #expect(migrator.currentVersion == 0)
    }

    @Test("Single migration runs")
    func singleMigration() throws {
        let (migrator, store) = makeMigrator()
        let steps = [
            PrismMigrationStep(version: 1) { s in
                try s.save("migrated", forKey: "flag")
            },
        ]
        let version = try migrator.migrate(steps: steps)
        #expect(version == 1)
        #expect(migrator.currentVersion == 1)
        #expect(try store.load(String.self, forKey: "flag") == "migrated")
    }

    @Test("Multiple migrations run in order")
    func multipleMigrations() throws {
        let (migrator, store) = makeMigrator()
        let steps = [
            PrismMigrationStep(version: 1) { s in
                try s.save(1, forKey: "v")
            },
            PrismMigrationStep(version: 2) { s in
                let prev = try s.load(Int.self, forKey: "v") ?? 0
                try s.save(prev + 10, forKey: "v")
            },
            PrismMigrationStep(version: 3) { s in
                let prev = try s.load(Int.self, forKey: "v") ?? 0
                try s.save(prev + 100, forKey: "v")
            },
        ]
        let version = try migrator.migrate(steps: steps)
        #expect(version == 3)
        #expect(try store.load(Int.self, forKey: "v") == 111)
    }

    @Test("Skips already-applied migrations")
    func skipsApplied() throws {
        let (migrator, store) = makeMigrator()
        let step1 = [
            PrismMigrationStep(version: 1) { s in
                try s.save("v1", forKey: "data")
            },
        ]
        try migrator.migrate(steps: step1)

        let allSteps = step1 + [
            PrismMigrationStep(version: 2) { s in
                try s.save("v2", forKey: "data")
            },
        ]
        let version = try migrator.migrate(steps: allSteps)
        #expect(version == 2)
        #expect(try store.load(String.self, forKey: "data") == "v2")
    }

    @Test("No pending returns current version")
    func noPending() throws {
        let (migrator, _) = makeMigrator()
        let steps = [
            PrismMigrationStep(version: 1) { _ in },
        ]
        try migrator.migrate(steps: steps)
        let version = try migrator.migrate(steps: steps)
        #expect(version == 1)
    }

    @Test("Needs migration check")
    func needsMigration() throws {
        let (migrator, _) = makeMigrator()
        #expect(migrator.needsMigration(latestVersion: 1))
        try migrator.migrate(steps: [
            PrismMigrationStep(version: 1) { _ in },
        ])
        #expect(!migrator.needsMigration(latestVersion: 1))
        #expect(migrator.needsMigration(latestVersion: 2))
    }

    @Test("Reset clears version")
    func resetVersion() throws {
        let (migrator, _) = makeMigrator()
        try migrator.migrate(steps: [
            PrismMigrationStep(version: 1) { _ in },
        ])
        #expect(migrator.currentVersion == 1)
        try migrator.reset()
        #expect(migrator.currentVersion == 0)
    }

    @Test("Unordered steps run in version order")
    func unorderedSteps() throws {
        let (migrator, store) = makeMigrator()
        let steps = [
            PrismMigrationStep(version: 3) { s in try s.save("c", forKey: "last") },
            PrismMigrationStep(version: 1) { s in try s.save("a", forKey: "first") },
            PrismMigrationStep(version: 2) { s in try s.save("b", forKey: "mid") },
        ]
        try migrator.migrate(steps: steps)
        #expect(migrator.currentVersion == 3)
        #expect(try store.load(String.self, forKey: "first") == "a")
        #expect(try store.load(String.self, forKey: "last") == "c")
    }
}
