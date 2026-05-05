#if canImport(SwiftData)
    import Foundation
    import SwiftData
    import Testing

    @testable import PrismStorage

    @Model
    final class TestItem {
        var name: String
        var value: Int

        init(name: String, value: Int) {
            self.name = name
            self.value = value
        }
    }

    @Suite("SDCont")
    struct PrismContainerTests {
        @Test("Create in-memory container")
        func inMemory() throws {
            let container = try PrismContainer.inMemory(for: [TestItem.self])
            #expect(container.schema.entities.count > 0)
        }

        @Test("Create local container")
        func local() throws {
            let container = try PrismContainer.create(
                for: [TestItem.self], inMemory: true
            )
            #expect(container.schema.entities.count > 0)
        }
    }

    @Suite("SDOps")
    struct PrismModelStoreTests {
        func makeStore() throws -> (PrismModelStore<TestItem>, ModelContainer) {
            let container = try PrismContainer.inMemory(for: [TestItem.self])
            let store = PrismModelStore<TestItem>(modelContainer: container)
            return (store, container)
        }

        @Test("Insert and count")
        func insertCount() async throws {
            let (store, _) = try makeStore()
            await store.insert(TestItem(name: "alpha", value: 1))
            let count = try await store.count()
            #expect(count == 1)
        }

        @Test("Insert batch and count")
        func insertBatch() async throws {
            let (store, _) = try makeStore()
            let items = (0..<5).map { TestItem(name: "item\($0)", value: $0) }
            await store.insertBatch(items)
            let count = try await store.count()
            #expect(count == 5)
        }

        @Test("Delete all")
        func deleteAll() async throws {
            let (store, _) = try makeStore()
            await store.insertBatch([
                TestItem(name: "a", value: 1),
                TestItem(name: "b", value: 2),
            ])
            try await store.deleteAll()
            #expect(try await store.count() == 0)
        }

        @Test("Exists check")
        func exists() async throws {
            let (store, _) = try makeStore()
            #expect(try await !store.exists())
            await store.insert(TestItem(name: "x", value: 0))
            #expect(try await store.exists())
        }

        @Test("Transaction saves")
        func transactionSuccess() async throws {
            let (store, _) = try makeStore()
            try await store.transaction { ctx in
                ctx.insert(TestItem(name: "tx", value: 42))
            }
            #expect(try await store.count() == 1)
        }

        @Test("Count with no items")
        func emptyCount() async throws {
            let (store, _) = try makeStore()
            #expect(try await store.count() == 0)
        }
    }

    @Suite("SDQry")
    struct PrismQueryTests {
        @Test("Build empty query")
        func emptyQuery() {
            let query = PrismQuery<TestItem>()
            let descriptor = query.build()
            #expect(descriptor.predicate == nil)
        }

        @Test("Build with limit")
        func limitQuery() {
            let query = PrismQuery<TestItem>().limit(5)
            let descriptor = query.build()
            #expect(descriptor.fetchLimit == 5)
        }

        @Test("Build with offset")
        func offsetQuery() {
            let query = PrismQuery<TestItem>().offset(10)
            let descriptor = query.build()
            #expect(descriptor.fetchOffset == 10)
        }

        @Test("Chain limit and offset")
        func chainQuery() {
            let query = PrismQuery<TestItem>().limit(20).offset(5)
            let descriptor = query.build()
            #expect(descriptor.fetchLimit == 20)
            #expect(descriptor.fetchOffset == 5)
        }
    }
#endif
