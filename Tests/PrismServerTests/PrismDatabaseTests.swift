#if canImport(SQLite3)
    import Testing
    import Foundation
    @testable import PrismServer

    @Suite("PrismDatabase Tests")
    struct PrismDatabaseTests {

        @Test("Create in-memory database")
        func createInMemory() throws {
            _ = try PrismDatabase(path: ":memory:")
        }

        @Test("Execute CREATE TABLE and INSERT")
        func createAndInsert() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
            try await db.execute("INSERT INTO users (name) VALUES (?)", parameters: [.text("Alice")])
            let id = await db.lastInsertID
            #expect(id == 1)
        }

        @Test("Query rows")
        func queryRows() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE items (id INTEGER PRIMARY KEY, value TEXT)")
            try await db.execute("INSERT INTO items (value) VALUES (?)", parameters: [.text("one")])
            try await db.execute("INSERT INTO items (value) VALUES (?)", parameters: [.text("two")])

            let rows = try await db.query("SELECT * FROM items ORDER BY id")
            #expect(rows.count == 2)
            #expect(rows[0].text("value") == "one")
            #expect(rows[1].text("value") == "two")
        }

        @Test("Query first row")
        func queryFirst() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY, v TEXT)")
            try await db.execute("INSERT INTO t (v) VALUES (?)", parameters: [.text("val")])
            let row = try await db.queryFirst("SELECT * FROM t")
            #expect(row?.text("v") == "val")
        }

        @Test("Query returns empty for no results")
        func queryEmpty() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY)")
            let rows = try await db.query("SELECT * FROM t")
            #expect(rows.isEmpty)
        }

        @Test("Transaction commits on success")
        func transactionCommit() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY, v TEXT)")

            try await db.transaction { db in
                try db.execute("INSERT INTO t (v) VALUES (?)", parameters: [.text("a")])
                try db.execute("INSERT INTO t (v) VALUES (?)", parameters: [.text("b")])
            }

            let count = try await db.query("SELECT COUNT(*) as c FROM t")
            #expect(count.first?.int("c") == 2)
        }

        @Test("Transaction rolls back on error")
        func transactionRollback() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY, v TEXT NOT NULL)")

            do {
                try await db.transaction { db in
                    try db.execute("INSERT INTO t (v) VALUES (?)", parameters: [.text("ok")])
                    try db.execute("INSERT INTO t (v) VALUES (?)", parameters: [.null])
                }
            } catch {}

            let count = try await db.query("SELECT COUNT(*) as c FROM t")
            #expect(count.first?.int("c") == 0)
        }

        @Test("All value types")
        func allValueTypes() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE t (i INTEGER, d REAL, t TEXT, b BLOB)")
            try await db.execute(
                "INSERT INTO t VALUES (?, ?, ?, ?)",
                parameters: [.int(42), .double(3.14), .text("hello"), .blob(Data([1, 2, 3]))]
            )
            let row = try await db.queryFirst("SELECT * FROM t")!
            #expect(row.int("i") == 42)
            #expect(row.double("d")! > 3.13)
            #expect(row.text("t") == "hello")
            #expect(row.blob("b") == Data([1, 2, 3]))
        }

        @Test("NULL values")
        func nullValues() async throws {
            let db = try PrismDatabase()
            try await db.execute("CREATE TABLE t (v TEXT)")
            try await db.execute("INSERT INTO t VALUES (?)", parameters: [.null])
            let row = try await db.queryFirst("SELECT * FROM t")!
            #expect(row["v"].isNull)
        }
    }

    @Suite("PrismDatabaseValue Tests")
    struct PrismDatabaseValueTests {

        @Test("Value accessors")
        func accessors() {
            #expect(PrismDatabaseValue.int(42).intValue == 42)
            #expect(PrismDatabaseValue.double(3.14).doubleValue == 3.14)
            #expect(PrismDatabaseValue.text("hello").textValue == "hello")
            #expect(PrismDatabaseValue.blob(Data([1])).blobValue == Data([1]))
            #expect(PrismDatabaseValue.null.isNull)
        }

        @Test("Wrong accessor returns nil")
        func wrongAccessor() {
            #expect(PrismDatabaseValue.int(1).textValue == nil)
            #expect(PrismDatabaseValue.text("hi").intValue == nil)
        }
    }

    @Suite("PrismRow Tests")
    struct PrismRowTests {

        @Test("Subscript returns value")
        func subscript_() {
            let row = PrismRow(values: ["name": .text("Alice")])
            #expect(row["name"].textValue == "Alice")
        }

        @Test("Missing column returns null")
        func missingColumn() {
            let row = PrismRow(values: [:])
            #expect(row["missing"].isNull)
        }
    }
#endif
