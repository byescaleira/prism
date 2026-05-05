#if canImport(SQLite3)
    import Testing
    import Foundation
    @testable import PrismServer

    struct TestMigrationCreateUsers: PrismMigrationStep, Sendable {
        let name = "001_create_users"
        func up(_ db: PrismDatabase) async throws {
            try await db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL)")
        }
        func down(_ db: PrismDatabase) async throws {
            try await db.execute("DROP TABLE IF EXISTS users")
        }
    }

    struct TestMigrationCreatePosts: PrismMigrationStep, Sendable {
        let name = "002_create_posts"
        func up(_ db: PrismDatabase) async throws {
            try await db.execute("CREATE TABLE posts (id INTEGER PRIMARY KEY, title TEXT, user_id INTEGER)")
        }
        func down(_ db: PrismDatabase) async throws {
            try await db.execute("DROP TABLE IF EXISTS posts")
        }
    }

    struct TestMigrationAddEmail: PrismMigrationStep, Sendable {
        let name = "003_add_email"
        func up(_ db: PrismDatabase) async throws {
            try await db.execute("ALTER TABLE users ADD COLUMN email TEXT")
        }
        func down(_ db: PrismDatabase) async throws {
            // SQLite doesn't support DROP COLUMN in older versions
        }
    }

    @Suite("PrismMigrationRunner Tests")
    struct PrismMigrationRunnerTests {

        func makeRunner() async throws -> (PrismMigrationRunner, PrismDatabase) {
            let db = try PrismDatabase(path: ":memory:")
            let runner = PrismMigrationRunner(database: db)
            return (runner, db)
        }

        @Test("Run pending migrations")
        func runMigrations() async throws {
            let (runner, _) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            await runner.register(TestMigrationCreatePosts())
            let result = try await runner.migrate()
            #expect(result.count == 2)
            #expect(result[0] == "001_create_users")
            #expect(result[1] == "002_create_posts")
        }

        @Test("Skip already applied migrations")
        func skipApplied() async throws {
            let (runner, _) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            let first = try await runner.migrate()
            #expect(first.count == 1)
            let second = try await runner.migrate()
            #expect(second.isEmpty)
        }

        @Test("Rollback last batch")
        func rollback() async throws {
            let (runner, db) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            await runner.register(TestMigrationCreatePosts())
            _ = try await runner.migrate()

            let rows = try await db.query("SELECT name FROM sqlite_master WHERE type='table' AND name='users'")
            #expect(rows.count == 1)

            let rolled = try await runner.rollback()
            #expect(rolled.count == 2)
        }

        @Test("Rollback all batches")
        func rollbackAll() async throws {
            let (runner, _) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            _ = try await runner.migrate()
            await runner.register(TestMigrationCreatePosts())
            _ = try await runner.migrate()

            let rolled = try await runner.rollbackAll()
            #expect(rolled.count == 2)
        }

        @Test("Migration status")
        func status() async throws {
            let (runner, _) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            await runner.register(TestMigrationCreatePosts())
            _ = try await runner.migrate()

            await runner.register(TestMigrationAddEmail())
            let statuses = try await runner.status()
            #expect(statuses.count == 3)

            var appliedCount = 0
            var pendingCount = 0
            for info in statuses {
                switch info.status {
                case .applied: appliedCount += 1
                case .pending: pendingCount += 1
                }
            }
            #expect(appliedCount == 2)
            #expect(pendingCount == 1)
        }

        @Test("Pending count")
        func pendingCount() async throws {
            let (runner, _) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            await runner.register(TestMigrationCreatePosts())
            let count = try await runner.pendingCount()
            #expect(count == 2)
        }

        @Test("Pending count after migration")
        func pendingCountAfterMigrate() async throws {
            let (runner, _) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            _ = try await runner.migrate()
            let count = try await runner.pendingCount()
            #expect(count == 0)
        }

        @Test("Reset runs rollback then migrate")
        func reset() async throws {
            let (runner, _) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            _ = try await runner.migrate()
            let result = try await runner.reset()
            #expect(!result.isEmpty)
        }

        @Test("Register all migrations")
        func registerAll() async throws {
            let (runner, _) = try await makeRunner()
            await runner.registerAll([TestMigrationCreateUsers(), TestMigrationCreatePosts()])
            let count = try await runner.pendingCount()
            #expect(count == 2)
        }

        @Test("Migration creates actual tables")
        func migrationsCreateTables() async throws {
            let (runner, db) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            _ = try await runner.migrate()
            try await db.execute("INSERT INTO users (name) VALUES (?)", parameters: [.text("Alice")])
            let rows = try await db.query("SELECT name FROM users")
            #expect(rows.count == 1)
            #expect(rows[0].text("name") == "Alice")
        }

        @Test("Rollback removes tables")
        func rollbackRemovesTables() async throws {
            let (runner, db) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            _ = try await runner.migrate()
            _ = try await runner.rollback()
            let tables = try await db.query("SELECT name FROM sqlite_master WHERE type='table' AND name='users'")
            #expect(tables.isEmpty)
        }

        @Test("Batch tracking groups migrations")
        func batchTracking() async throws {
            let (runner, db) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            _ = try await runner.migrate()

            await runner.register(TestMigrationCreatePosts())
            _ = try await runner.migrate()

            let rows = try await db.query("SELECT DISTINCT batch FROM _prism_migrations ORDER BY batch")
            #expect(rows.count == 2)
        }

        @Test("Empty rollback returns nothing")
        func emptyRollback() async throws {
            let (runner, _) = try await makeRunner()
            let rolled = try await runner.rollback()
            #expect(rolled.isEmpty)
        }

        @Test("Migration record timestamp exists")
        func migrationTimestamp() async throws {
            let (runner, _) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            _ = try await runner.migrate()
            let statuses = try await runner.status()
            if case .applied(_, let appliedAt) = statuses.first?.status {
                #expect(!appliedAt.isEmpty)
            }
        }

        @Test("Multiple migrate calls are idempotent")
        func idempotentMigrate() async throws {
            let (runner, _) = try await makeRunner()
            await runner.register(TestMigrationCreateUsers())
            let first = try await runner.migrate()
            let second = try await runner.migrate()
            let third = try await runner.migrate()
            #expect(first.count == 1)
            #expect(second.isEmpty)
            #expect(third.isEmpty)
        }
    }
#endif
