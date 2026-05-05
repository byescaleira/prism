#if canImport(SQLite3)
    import Testing
    import Foundation
    @testable import PrismServer

    @Suite("PrismQueryBuilder Tests")
    struct PrismQueryBuilderTests {

        private func makeDB() async throws -> PrismDatabase {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)")
            try await db.execute("INSERT INTO users (name, age) VALUES (?, ?)", parameters: [.text("Alice"), .int(30)])
            try await db.execute("INSERT INTO users (name, age) VALUES (?, ?)", parameters: [.text("Bob"), .int(25)])
            try await db.execute(
                "INSERT INTO users (name, age) VALUES (?, ?)", parameters: [.text("Charlie"), .int(35)])
            return db
        }

        @Test("Get all rows")
        func getAll() async throws {
            let db = try await makeDB()
            let rows = try await db.table("users").get()
            #expect(rows.count == 3)
        }

        @Test("Where clause filters")
        func whereClause() async throws {
            let db = try await makeDB()
            let rows = try await db.table("users").where("name", .text("Alice")).get()
            #expect(rows.count == 1)
            #expect(rows[0].text("name") == "Alice")
        }

        @Test("First returns one row")
        func first() async throws {
            let db = try await makeDB()
            let row = try await db.table("users").orderBy("age").first()
            #expect(row?.text("name") == "Bob")
        }

        @Test("Count")
        func count() async throws {
            let db = try await makeDB()
            let count = try await db.table("users").count()
            #expect(count == 3)
        }

        @Test("Order by descending")
        func orderByDesc() async throws {
            let db = try await makeDB()
            let row = try await db.table("users").orderBy("age", ascending: false).first()
            #expect(row?.text("name") == "Charlie")
        }

        @Test("Limit and offset")
        func limitOffset() async throws {
            let db = try await makeDB()
            let rows = try await db.table("users").orderBy("id").limit(1).offset(1).get()
            #expect(rows.count == 1)
            #expect(rows[0].text("name") == "Bob")
        }

        @Test("Select specific columns")
        func selectColumns() async throws {
            let db = try await makeDB()
            let rows = try await db.table("users").select("name").get()
            #expect(rows[0]["name"].textValue != nil)
        }

        @Test("Insert returns row ID")
        func insert() async throws {
            let db = try await makeDB()
            let id = try await db.table("users").insert(["name": .text("Diana"), "age": .int(28)])
            #expect(id == 4)
        }

        @Test("Update modifies rows")
        func update() async throws {
            let db = try await makeDB()
            let count = try await db.table("users").where("name", .text("Alice")).update(["age": .int(31)])
            #expect(count == 1)
            let row = try await db.table("users").where("name", .text("Alice")).first()
            #expect(row?.int("age") == 31)
        }

        @Test("Delete removes rows")
        func delete() async throws {
            let db = try await makeDB()
            let count = try await db.table("users").where("name", .text("Bob")).delete()
            #expect(count == 1)
            let total = try await db.table("users").count()
            #expect(total == 2)
        }
    }

    @Suite("PrismMigration Tests")
    struct PrismMigrationTests {

        @Test("Apply migration creates table")
        func applyMigration() async throws {
            let db = try PrismDatabase()
            let migration = PrismMigration(
                version: 1,
                name: "create_users",
                up: "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)",
                down: "DROP TABLE users"
            )

            let migrator = PrismMigrator(database: db, migrations: [migration])
            try await migrator.migrate()

            try await db.execute("INSERT INTO users (name) VALUES (?)", parameters: [.text("Test")])
            let rows = try await db.query("SELECT * FROM users")
            #expect(rows.count == 1)
        }

        @Test("Skips already applied migrations")
        func skipApplied() async throws {
            let db = try PrismDatabase()
            let migration = PrismMigration(version: 1, name: "test", up: "CREATE TABLE t (id INTEGER PRIMARY KEY)")
            let migrator = PrismMigrator(database: db, migrations: [migration])

            try await migrator.migrate()
            try await migrator.migrate()

            let rows = try await db.query("SELECT * FROM _prism_migrations")
            #expect(rows.count == 1)
        }

        @Test("Rollback reverts last migration")
        func rollback() async throws {
            let db = try PrismDatabase()
            let migration = PrismMigration(
                version: 1,
                name: "create_t",
                up: "CREATE TABLE t (id INTEGER PRIMARY KEY)",
                down: "DROP TABLE t"
            )

            let migrator = PrismMigrator(database: db, migrations: [migration])
            try await migrator.migrate()
            try await migrator.rollback()

            let rows = try await db.query("SELECT * FROM _prism_migrations")
            #expect(rows.isEmpty)
        }
    }

    @Suite("PrismModel Tests")
    struct PrismModelTests {

        struct User: PrismModel {
            let id: Int
            let name: String
            let age: Int
        }

        @Test("Default table name")
        func defaultTableName() {
            #expect(User.tableName == "users")
        }

        @Test("Default primary key")
        func defaultPrimaryKey() {
            #expect(User.primaryKey == "id")
        }

        @Test("Insert and find model")
        func insertAndFind() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)")

            let user = User(id: 1, name: "Alice", age: 30)
            try await db.insert(user)

            let found = try await db.find(User.self, id: .int(1))
            #expect(found?.name == "Alice")
            #expect(found?.age == 30)
        }

        @Test("All returns all models")
        func allModels() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)")
            try await db.insert(User(id: 1, name: "Alice", age: 30))
            try await db.insert(User(id: 2, name: "Bob", age: 25))

            let users = try await db.all(User.self)
            #expect(users.count == 2)
        }

        @Test("Delete model")
        func deleteModel() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)")
            try await db.insert(User(id: 1, name: "Alice", age: 30))
            try await db.delete(User.self, id: .int(1))

            let found = try await db.find(User.self, id: .int(1))
            #expect(found == nil)
        }

        @Test("Find returns nil for missing")
        func findMissing() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)")
            let found = try await db.find(User.self, id: .int(999))
            #expect(found == nil)
        }
    }
#endif
