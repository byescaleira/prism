#if canImport(SQLite3)
import Foundation
import SQLite3

// MARK: - Seeder Protocol

public protocol PrismSeederProtocol: Sendable {
    var name: String { get }
    func run(_ db: PrismDatabase) async throws
}

// MARK: - Seeder Record

public struct PrismSeederRecord: Sendable {
    public let id: Int
    public let name: String
    public let ranAt: String

    public init(id: Int, name: String, ranAt: String) {
        self.id = id
        self.name = name
        self.ranAt = ranAt
    }
}

// MARK: - Seeder Runner

public actor PrismSeederRunner {
    private let db: PrismDatabase
    private var seeders: [any PrismSeederProtocol] = []
    private var initialized = false

    public init(database: PrismDatabase) {
        self.db = database
    }

    public func register(_ seeder: any PrismSeederProtocol) {
        seeders.append(seeder)
    }

    public func registerAll(_ items: [any PrismSeederProtocol]) {
        seeders.append(contentsOf: items)
    }

    private func ensureTable() async throws {
        guard !initialized else { return }
        try await db.execute("""
            CREATE TABLE IF NOT EXISTS _prism_seeds (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                ran_at TEXT NOT NULL DEFAULT (datetime('now'))
            )
        """)
        initialized = true
    }

    public func seed() async throws -> [String] {
        try await ensureTable()
        let ran = try await ranNames()
        let pending = seeders.filter { !ran.contains($0.name) }

        guard !pending.isEmpty else { return [] }

        var seeded: [String] = []
        for seeder in pending {
            try await seeder.run(db)
            try await db.execute(
                "INSERT INTO _prism_seeds (name) VALUES (?)",
                parameters: [.text(seeder.name)]
            )
            seeded.append(seeder.name)
        }
        return seeded
    }

    public func seedSpecific(_ names: [String]) async throws -> [String] {
        try await ensureTable()
        let ran = try await ranNames()

        var seeded: [String] = []
        for name in names {
            guard !ran.contains(name) else { continue }
            guard let seeder = seeders.first(where: { $0.name == name }) else {
                throw PrismSeederError.seederNotFound(name)
            }
            try await seeder.run(db)
            try await db.execute(
                "INSERT INTO _prism_seeds (name) VALUES (?)",
                parameters: [.text(seeder.name)]
            )
            seeded.append(name)
        }
        return seeded
    }

    public func reset(tables: [String]) async throws -> [String] {
        try await ensureTable()
        for table in tables {
            let safeName = table.replacingOccurrences(of: "'", with: "''")
            try await db.execute("DELETE FROM '\(safeName)'")
        }
        try await db.execute("DELETE FROM _prism_seeds")
        return try await seed()
    }

    public func status() async throws -> [(name: String, ran: Bool, ranAt: String?)] {
        try await ensureTable()
        let records = try await ranRecords()
        var recordMap: [String: PrismSeederRecord] = [:]
        for record in records {
            recordMap[record.name] = record
        }

        return seeders.map { seeder in
            if let record = recordMap[seeder.name] {
                return (name: seeder.name, ran: true, ranAt: record.ranAt)
            }
            return (name: seeder.name, ran: false, ranAt: nil)
        }
    }

    public func pendingCount() async throws -> Int {
        try await ensureTable()
        let ran = try await ranNames()
        return seeders.filter { !ran.contains($0.name) }.count
    }

    // MARK: - Private

    private func ranNames() async throws -> Set<String> {
        let rows = try await db.query("SELECT name FROM _prism_seeds")
        return Set(rows.compactMap { $0.text("name") })
    }

    private func ranRecords() async throws -> [PrismSeederRecord] {
        let rows = try await db.query("SELECT id, name, ran_at FROM _prism_seeds ORDER BY id")
        return rows.compactMap { row in
            guard let id = row.int("id"),
                  let name = row.text("name"),
                  let ranAt = row.text("ran_at") else { return nil }
            return PrismSeederRecord(id: id, name: name, ranAt: ranAt)
        }
    }
}

// MARK: - Errors

public enum PrismSeederError: Error, Sendable {
    case seederNotFound(String)
    case resetFailed(String)
}

#endif
