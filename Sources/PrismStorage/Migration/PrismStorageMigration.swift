import Foundation

/// A single migration step with a version identifier and transform closure.
public struct PrismMigrationStep: Sendable {
    public let version: Int
    public let migrate: @Sendable (PrismStorageProtocol) throws -> Void

    public init(version: Int, migrate: @escaping @Sendable (PrismStorageProtocol) throws -> Void) {
        self.version = version
        self.migrate = migrate
    }
}

/// Runs ordered migrations against a storage engine, tracking current version.
public struct PrismStorageMigrator: Sendable {
    private let store: PrismStorageProtocol
    private let versionKey: String

    public init(store: PrismStorageProtocol, versionKey: String = "_prism_schema_version") {
        self.store = store
        self.versionKey = versionKey
    }

    public var currentVersion: Int {
        (try? store.load(Int.self, forKey: versionKey)) ?? 0
    }

    @discardableResult
    public func migrate(steps: [PrismMigrationStep]) throws -> Int {
        let current = currentVersion
        let pending = steps
            .filter { $0.version > current }
            .sorted { $0.version < $1.version }

        guard !pending.isEmpty else { return current }

        for step in pending {
            do {
                try step.migrate(store)
                try store.save(step.version, forKey: versionKey)
            } catch {
                throw PrismStorageError.migrationFailed(
                    "Failed at version \(step.version): \(error.localizedDescription)"
                )
            }
        }

        return pending.last?.version ?? current
    }

    public func needsMigration(latestVersion: Int) -> Bool {
        currentVersion < latestVersion
    }

    public func reset() throws {
        try store.delete(forKey: versionKey)
    }
}
