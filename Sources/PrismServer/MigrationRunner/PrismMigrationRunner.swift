#if canImport(SQLite3)
import Foundation
import SQLite3

// MARK: - Migration Protocol

public protocol PrismMigrationStep: Sendable {
    var name: String { get }
    func up(_ db: PrismDatabase) async throws
    func down(_ db: PrismDatabase) async throws
}

// MARK: - Migration Record

public struct PrismMigrationRecord: Sendable {
    public let id: Int
    public let name: String
    public let batch: Int
    public let appliedAt: String

    public init(id: Int, name: String, batch: Int, appliedAt: String) {
        self.id = id
        self.name = name
        self.batch = batch
        self.appliedAt = appliedAt
    }
}

// MARK: - Migration Status

public enum PrismMigrationStatus: Sendable {
    case pending
    case applied(batch: Int, appliedAt: String)
}

public struct PrismMigrationInfo: Sendable {
    public let name: String
    public let status: PrismMigrationStatus

    public init(name: String, status: PrismMigrationStatus) {
        self.name = name
        self.status = status
    }
}

// MARK: - Migration Runner

public actor PrismMigrationRunner {
    private let db: PrismDatabase
    private var migrations: [any PrismMigrationStep] = []
    private var initialized = false

    public init(database: PrismDatabase) {
        self.db = database
    }

    public func register(_ migration: any PrismMigrationStep) {
        migrations.append(migration)
    }

    public func registerAll(_ steps: [any PrismMigrationStep]) {
        migrations.append(contentsOf: steps)
    }

    private func ensureTable() async throws {
        guard !initialized else { return }
        try await db.execute("""
            CREATE TABLE IF NOT EXISTS _prism_migrations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                batch INTEGER NOT NULL,
                applied_at TEXT NOT NULL DEFAULT (datetime('now'))
            )
        """)
        initialized = true
    }

    public func migrate() async throws -> [String] {
        try await ensureTable()
        let applied = try await appliedNames()
        let pending = migrations.filter { !applied.contains($0.name) }

        guard !pending.isEmpty else { return [] }

        let batch = try await nextBatch()
        var ran: [String] = []

        for migration in pending {
            try await migration.up(db)
            try await db.execute(
                "INSERT INTO _prism_migrations (name, batch) VALUES (?, ?)",
                parameters: [.text(migration.name), .int(batch)]
            )
            ran.append(migration.name)
        }

        return ran
    }

    public func rollback() async throws -> [String] {
        try await ensureTable()
        let lastBatch = try await currentBatch()
        guard lastBatch > 0 else { return [] }

        let rows = try await db.query(
            "SELECT name FROM _prism_migrations WHERE batch = ? ORDER BY id DESC",
            parameters: [.int(lastBatch)]
        )

        var rolledBack: [String] = []
        for row in rows {
            guard let name = row.text("name") else { continue }
            if let migration = migrations.first(where: { $0.name == name }) {
                try await migration.down(db)
            }
            try await db.execute(
                "DELETE FROM _prism_migrations WHERE name = ?",
                parameters: [.text(name)]
            )
            rolledBack.append(name)
        }

        return rolledBack
    }

    public func rollbackAll() async throws -> [String] {
        try await ensureTable()
        var allRolledBack: [String] = []
        var batch = try await currentBatch()
        while batch > 0 {
            let names = try await rollback()
            allRolledBack.append(contentsOf: names)
            batch = try await currentBatch()
        }
        return allRolledBack
    }

    public func reset() async throws -> [String] {
        let rolledBack = try await rollbackAll()
        let migrated = try await migrate()
        return rolledBack + migrated
    }

    public func status() async throws -> [PrismMigrationInfo] {
        try await ensureTable()
        let applied = try await appliedRecords()
        var appliedMap: [String: PrismMigrationRecord] = [:]
        for record in applied {
            appliedMap[record.name] = record
        }

        return migrations.map { migration in
            if let record = appliedMap[migration.name] {
                return PrismMigrationInfo(name: migration.name, status: .applied(batch: record.batch, appliedAt: record.appliedAt))
            }
            return PrismMigrationInfo(name: migration.name, status: .pending)
        }
    }

    public func pendingCount() async throws -> Int {
        try await ensureTable()
        let applied = try await appliedNames()
        return migrations.filter { !applied.contains($0.name) }.count
    }

    // MARK: - Private

    private func appliedNames() async throws -> Set<String> {
        let rows = try await db.query("SELECT name FROM _prism_migrations ORDER BY id")
        return Set(rows.compactMap { $0.text("name") })
    }

    private func appliedRecords() async throws -> [PrismMigrationRecord] {
        let rows = try await db.query("SELECT id, name, batch, applied_at FROM _prism_migrations ORDER BY id")
        return rows.compactMap { row in
            guard let id = row.int("id"),
                  let name = row.text("name"),
                  let batch = row.int("batch"),
                  let appliedAt = row.text("applied_at") else { return nil }
            return PrismMigrationRecord(id: id, name: name, batch: batch, appliedAt: appliedAt)
        }
    }

    private func currentBatch() async throws -> Int {
        let rows = try await db.query("SELECT MAX(batch) as max_batch FROM _prism_migrations")
        return rows.first?.int("max_batch") ?? 0
    }

    private func nextBatch() async throws -> Int {
        try await currentBatch() + 1
    }
}

#endif
