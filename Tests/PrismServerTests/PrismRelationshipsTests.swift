#if canImport(SQLite3)
    import Testing
    import Foundation
    @testable import PrismServer

    @Suite("PrismRelation Tests")
    struct PrismRelationTests {

        @Test("hasMany factory creates correct relation")
        func hasMany() {
            let rel = PrismRelation.hasMany("comments", foreignKey: "post_id")
            #expect(rel.type == .hasMany)
            #expect(rel.relatedTable == "comments")
            #expect(rel.foreignKey == "post_id")
            #expect(rel.localKey == "id")
        }

        @Test("belongsTo factory creates correct relation")
        func belongsTo() {
            let rel = PrismRelation.belongsTo("users", foreignKey: "user_id")
            #expect(rel.type == .belongsTo)
            #expect(rel.relatedTable == "users")
            #expect(rel.localKey == "user_id")
            #expect(rel.foreignKey == "id")
        }

        @Test("hasOne factory creates correct relation")
        func hasOne() {
            let rel = PrismRelation.hasOne("profiles", foreignKey: "user_id")
            #expect(rel.type == .hasOne)
            #expect(rel.relatedTable == "profiles")
            #expect(rel.foreignKey == "user_id")
        }

        @Test("Custom local key")
        func customLocalKey() {
            let rel = PrismRelation.hasMany("orders", foreignKey: "customer_id", localKey: "customer_id")
            #expect(rel.localKey == "customer_id")
        }

        @Test("PrismRelationType cases")
        func relationTypes() {
            let hm = PrismRelationType.hasMany
            let ho = PrismRelationType.hasOne
            let bt = PrismRelationType.belongsTo
            #expect(hm != ho)
            #expect(ho != bt)
        }
    }

    @Suite("PrismDatabase Relationship Queries")
    struct PrismDatabaseRelationshipTests {

        @Test("loadHasMany returns related rows")
        func loadHasMany() async throws {
            let db = try PrismDatabase(path: ":memory:")
            try await db.execute("CREATE TABLE posts (id INTEGER PRIMARY KEY, title TEXT)")
            try await db.execute("CREATE TABLE comments (id INTEGER PRIMARY KEY, post_id INTEGER, body TEXT)")
            try await db.execute("INSERT INTO posts (id, title) VALUES (1, 'Hello')")
            try await db.execute("INSERT INTO comments (id, post_id, body) VALUES (1, 1, 'Nice')")
            try await db.execute("INSERT INTO comments (id, post_id, body) VALUES (2, 1, 'Great')")
            try await db.execute("INSERT INTO comments (id, post_id, body) VALUES (3, 2, 'Other')")

            let rows = try await db.loadHasMany("comments", foreignKey: "post_id", localValue: "1")
            #expect(rows.count == 2)
            #expect(rows[0].text("body") == "Nice")
            #expect(rows[1].text("body") == "Great")
        }

        @Test("loadBelongsTo returns parent row")
        func loadBelongsTo() async throws {
            let db = try PrismDatabase(path: ":memory:")
            try await db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
            try await db.execute("INSERT INTO users (id, name) VALUES (1, 'Alice')")

            let row = try await db.loadBelongsTo("users", primaryKey: "id", foreignValue: "1")
            #expect(row != nil)
            #expect(row?.text("name") == "Alice")
        }

        @Test("loadBelongsTo returns nil for missing parent")
        func loadBelongsToMissing() async throws {
            let db = try PrismDatabase(path: ":memory:")
            try await db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")

            let row = try await db.loadBelongsTo("users", primaryKey: "id", foreignValue: "999")
            #expect(row == nil)
        }

        @Test("loadHasOne returns single related row")
        func loadHasOne() async throws {
            let db = try PrismDatabase(path: ":memory:")
            try await db.execute("CREATE TABLE profiles (id INTEGER PRIMARY KEY, user_id INTEGER, bio TEXT)")
            try await db.execute("INSERT INTO profiles (id, user_id, bio) VALUES (1, 1, 'Hello world')")

            let row = try await db.loadHasOne("profiles", foreignKey: "user_id", localValue: "1")
            #expect(row != nil)
            #expect(row?.text("bio") == "Hello world")
        }

        @Test("loadHasOne returns nil when none found")
        func loadHasOneNil() async throws {
            let db = try PrismDatabase(path: ":memory:")
            try await db.execute("CREATE TABLE profiles (id INTEGER PRIMARY KEY, user_id INTEGER, bio TEXT)")

            let row = try await db.loadHasOne("profiles", foreignKey: "user_id", localValue: "999")
            #expect(row == nil)
        }
    }
#endif
