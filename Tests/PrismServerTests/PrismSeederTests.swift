#if canImport(SQLite3)
import Testing
import Foundation
@testable import PrismServer

struct TestUserSeeder: PrismSeederProtocol, Sendable {
    let name = "users_seeder"
    func run(_ db: PrismDatabase) async throws {
        try await db.execute("INSERT INTO test_data (key, value) VALUES (?, ?)", parameters: [.text("user1"), .text("Alice")])
        try await db.execute("INSERT INTO test_data (key, value) VALUES (?, ?)", parameters: [.text("user2"), .text("Bob")])
    }
}

struct TestProductSeeder: PrismSeederProtocol, Sendable {
    let name = "products_seeder"
    func run(_ db: PrismDatabase) async throws {
        try await db.execute("INSERT INTO test_data (key, value) VALUES (?, ?)", parameters: [.text("prod1"), .text("Widget")])
    }
}

struct TestCategorySeeder: PrismSeederProtocol, Sendable {
    let name = "categories_seeder"
    func run(_ db: PrismDatabase) async throws {
        try await db.execute("INSERT INTO test_data (key, value) VALUES (?, ?)", parameters: [.text("cat1"), .text("Electronics")])
    }
}

@Suite("PrismSeeder Tests")
struct PrismSeederTests {

    func makeSeeder() async throws -> (PrismSeederRunner, PrismDatabase) {
        let db = try PrismDatabase(path: ":memory:")
        try await db.execute("CREATE TABLE test_data (key TEXT PRIMARY KEY, value TEXT)")
        let seeder = PrismSeederRunner(database: db)
        return (seeder, db)
    }

    @Test("Run all seeders")
    func runSeeders() async throws {
        let (seeder, db) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        await seeder.register(TestProductSeeder())
        let result = try await seeder.seed()
        #expect(result.count == 2)
        let rows = try await db.query("SELECT * FROM test_data")
        #expect(rows.count == 3)
    }

    @Test("Skip already run seeders")
    func skipRun() async throws {
        let (seeder, _) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        _ = try await seeder.seed()
        let second = try await seeder.seed()
        #expect(second.isEmpty)
    }

    @Test("Seed specific seeder")
    func seedSpecific() async throws {
        let (seeder, db) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        await seeder.register(TestProductSeeder())
        let result = try await seeder.seedSpecific(["products_seeder"])
        #expect(result.count == 1)
        #expect(result[0] == "products_seeder")
        let rows = try await db.query("SELECT * FROM test_data")
        #expect(rows.count == 1)
    }

    @Test("Seed specific nonexistent throws")
    func seedSpecificNotFound() async throws {
        let (seeder, _) = try await makeSeeder()
        do {
            _ = try await seeder.seedSpecific(["nonexistent"])
            #expect(Bool(false), "Should have thrown")
        } catch is PrismSeederError {
            // expected
        }
    }

    @Test("Reset clears and reseeds")
    func reset() async throws {
        let (seeder, db) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        _ = try await seeder.seed()
        let before = try await db.query("SELECT * FROM test_data")
        #expect(before.count == 2)

        _ = try await seeder.reset(tables: ["test_data"])
        let after = try await db.query("SELECT * FROM test_data")
        #expect(after.count == 2)
    }

    @Test("Status shows run state")
    func status() async throws {
        let (seeder, _) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        await seeder.register(TestProductSeeder())
        _ = try await seeder.seedSpecific(["users_seeder"])
        let statuses = try await seeder.status()
        #expect(statuses.count == 2)
        let userStatus = statuses.first(where: { $0.name == "users_seeder" })
        let productStatus = statuses.first(where: { $0.name == "products_seeder" })
        #expect(userStatus?.ran == true)
        #expect(productStatus?.ran == false)
    }

    @Test("Pending count")
    func pendingCount() async throws {
        let (seeder, _) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        await seeder.register(TestProductSeeder())
        let count = try await seeder.pendingCount()
        #expect(count == 2)
    }

    @Test("Pending count after seeding")
    func pendingCountAfter() async throws {
        let (seeder, _) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        _ = try await seeder.seed()
        let count = try await seeder.pendingCount()
        #expect(count == 0)
    }

    @Test("Register all seeders")
    func registerAll() async throws {
        let (seeder, _) = try await makeSeeder()
        await seeder.registerAll([TestUserSeeder(), TestProductSeeder(), TestCategorySeeder()])
        let count = try await seeder.pendingCount()
        #expect(count == 3)
    }

    @Test("Status has ranAt timestamp")
    func statusTimestamp() async throws {
        let (seeder, _) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        _ = try await seeder.seed()
        let statuses = try await seeder.status()
        let userStatus = statuses.first(where: { $0.name == "users_seeder" })
        #expect(userStatus?.ranAt != nil)
    }

    @Test("Multiple seed calls idempotent")
    func idempotentSeed() async throws {
        let (seeder, db) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        _ = try await seeder.seed()
        _ = try await seeder.seed()
        _ = try await seeder.seed()
        let rows = try await db.query("SELECT * FROM test_data")
        #expect(rows.count == 2)
    }

    @Test("Seeder data persists")
    func dataPersists() async throws {
        let (seeder, db) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        _ = try await seeder.seed()
        let rows = try await db.query("SELECT value FROM test_data WHERE key = ?", parameters: [.text("user1")])
        #expect(rows.first?.text("value") == "Alice")
    }

    @Test("Skip already run specific seeder")
    func skipAlreadyRunSpecific() async throws {
        let (seeder, _) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        _ = try await seeder.seed()
        let result = try await seeder.seedSpecific(["users_seeder"])
        #expect(result.isEmpty)
    }

    @Test("Seed order matches registration")
    func seedOrder() async throws {
        let (seeder, _) = try await makeSeeder()
        await seeder.register(TestProductSeeder())
        await seeder.register(TestUserSeeder())
        let result = try await seeder.seed()
        #expect(result[0] == "products_seeder")
        #expect(result[1] == "users_seeder")
    }

    @Test("Empty seed returns nothing")
    func emptySeed() async throws {
        let (seeder, _) = try await makeSeeder()
        let result = try await seeder.seed()
        #expect(result.isEmpty)
    }

    @Test("Reset with empty tables")
    func resetEmptyTables() async throws {
        let (seeder, _) = try await makeSeeder()
        await seeder.register(TestUserSeeder())
        _ = try await seeder.reset(tables: [])
        let count = try await seeder.pendingCount()
        #expect(count == 0)
    }
}
#endif
