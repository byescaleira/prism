import Foundation
import Testing

@testable import PrismStorage

@Suite("BatchOp")
struct PrismBatchOperationTests {
    func makeWriter() -> (PrismBatchWriter, PrismDefaultsStore) {
        let store = PrismDefaultsStore(suite: "BatchTest-\(UUID().uuidString)")
        return (PrismBatchWriter(store: store), store)
    }

    @Test("Execute save actions")
    func executeSave() throws {
        let (writer, store) = makeWriter()
        let actions: [PrismBatchAction<String>] = [
            .save(key: "a", value: "1"),
            .save(key: "b", value: "2"),
            .save(key: "c", value: "3"),
        ]
        let result = try writer.execute(actions)
        #expect(result.total == 3)
        #expect(result.succeeded == 3)
        #expect(result.failed == 0)
        #expect(result.allSucceeded)
        #expect(try store.load(String.self, forKey: "b") == "2")
    }

    @Test("Execute delete actions")
    func executeDelete() throws {
        let (writer, store) = makeWriter()
        try store.save("x", forKey: "d1")
        try store.save("y", forKey: "d2")
        let actions: [PrismBatchAction<String>] = [
            .delete(key: "d1"),
            .delete(key: "d2"),
        ]
        let result = try writer.execute(actions)
        #expect(result.total == 2)
        #expect(result.allSucceeded)
        #expect(try store.load(String.self, forKey: "d1") == nil)
    }

    @Test("SaveAll convenience")
    func saveAll() throws {
        let (writer, store) = makeWriter()
        let items: [(key: String, value: Int)] = [
            ("n1", 10), ("n2", 20), ("n3", 30),
        ]
        let result = try writer.saveAll(items)
        #expect(result.total == 3)
        #expect(result.allSucceeded)
        #expect(try store.load(Int.self, forKey: "n2") == 20)
    }

    @Test("DeleteAll convenience")
    func deleteAll() throws {
        let (writer, store) = makeWriter()
        try store.save("a", forKey: "k1")
        try store.save("b", forKey: "k2")
        let result = try writer.deleteAll(["k1", "k2"])
        #expect(result.total == 2)
        #expect(result.allSucceeded)
    }

    @Test("BatchResult equatable")
    func resultEquatable() {
        let a = PrismBatchResult(total: 5, succeeded: 4, failed: 1)
        let b = PrismBatchResult(total: 5, succeeded: 4, failed: 1)
        #expect(a == b)
        #expect(!a.allSucceeded)
    }
}
