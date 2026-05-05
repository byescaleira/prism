#if canImport(SQLite3)
    import Foundation

    /// A versioned database migration.
    public struct PrismMigration: Sendable {
        /// Unique version identifier (use sequential integers or timestamps).
        public let version: Int
        /// Human-readable name.
        public let name: String
        /// SQL statements to apply the migration.
        public let up: String
        /// SQL statements to revert the migration.
        public let down: String

        /// Creates a migration with the given version, name, and SQL statements.
        public init(version: Int, name: String, up: String, down: String = "") {
            self.version = version
            self.name = name
            self.up = up
            self.down = down
        }
    }

    /// Runs versioned migrations on a PrismDatabase.
    public struct PrismMigrator: Sendable {
        private let db: PrismDatabase
        private let migrations: [PrismMigration]

        /// Creates a migrator for the given database and set of migrations.
        public init(database: PrismDatabase, migrations: [PrismMigration]) {
            self.db = database
            self.migrations = migrations.sorted { $0.version < $1.version }
        }

        /// Applies all pending migrations.
        public func migrate() async throws {
            try await createMigrationsTable()
            let applied = try await appliedVersions()

            for migration in migrations where !applied.contains(migration.version) {
                try await db.transaction { db in
                    try db.execute(migration.up)
                    try db.execute(
                        "INSERT INTO _prism_migrations (version, name, applied_at) VALUES (?, ?, ?)",
                        parameters: [
                            .int(migration.version), .text(migration.name),
                            .text(ISO8601DateFormatter().string(from: .now)),
                        ]
                    )
                }
            }
        }

        /// Reverts the last applied migration.
        public func rollback() async throws {
            let applied = try await appliedVersions()
            guard let lastVersion = applied.max(),
                let migration = migrations.first(where: { $0.version == lastVersion })
            else {
                return
            }

            guard !migration.down.isEmpty else {
                throw PrismDatabaseError.migrationFailed("No rollback SQL for migration \(migration.version)")
            }

            try await db.transaction { db in
                try db.execute(migration.down)
                try db.execute("DELETE FROM _prism_migrations WHERE version = ?", parameters: [.int(migration.version)])
            }
        }

        private func createMigrationsTable() async throws {
            try await db.execute(
                """
                CREATE TABLE IF NOT EXISTS _prism_migrations (
                    version INTEGER PRIMARY KEY,
                    name TEXT NOT NULL,
                    applied_at TEXT NOT NULL
                )
                """)
        }

        private func appliedVersions() async throws -> Set<Int> {
            let rows = try await db.query("SELECT version FROM _prism_migrations")
            return Set(rows.compactMap { $0.int("version") })
        }
    }
#endif
