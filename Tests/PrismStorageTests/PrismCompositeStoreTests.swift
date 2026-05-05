import Foundation
import Testing

@testable import PrismStorage

@Suite("CmpstStore")
struct PrismCompositeStoreTests {
    func makeStore() -> (PrismCompositeStore, PrismDefaultsStore, PrismDefaultsStore) {
        let fast = PrismDefaultsStore(suite: "CmpstFast-\(UUID().uuidString)")
        let slow = PrismDefaultsStore(suite: "CmpstSlow-\(UUID().uuidString)")
        let composite = PrismCompositeStore(stores: [fast, slow])
        return (composite, fast, slow)
    }

    @Test("Save writes to all stores")
    func saveAll() throws {
        let (composite, fast, slow) = makeStore()
        try composite.save("val", forKey: "k")
        #expect(try fast.load(String.self, forKey: "k") == "val")
        #expect(try slow.load(String.self, forKey: "k") == "val")
    }

    @Test("Load from first store")
    func loadFirst() throws {
        let (composite, fast, _) = makeStore()
        try fast.save("cached", forKey: "k")
        let result = try composite.load(String.self, forKey: "k")
        #expect(result == "cached")
    }

    @Test("Load falls through and populates upstream")
    func loadFallthrough() throws {
        let (composite, fast, slow) = makeStore()
        try slow.save("deep", forKey: "k")
        #expect(try fast.load(String.self, forKey: "k") == nil)

        let result = try composite.load(String.self, forKey: "k")
        #expect(result == "deep")
        #expect(try fast.load(String.self, forKey: "k") == "deep")
    }

    @Test("Load missing from all returns nil")
    func loadMissing() throws {
        let (composite, _, _) = makeStore()
        #expect(try composite.load(String.self, forKey: "x") == nil)
    }

    @Test("Delete removes from all stores")
    func deleteAll() throws {
        let (composite, fast, slow) = makeStore()
        try composite.save("v", forKey: "k")
        try composite.delete(forKey: "k")
        #expect(try fast.load(String.self, forKey: "k") == nil)
        #expect(try slow.load(String.self, forKey: "k") == nil)
    }

    @Test("Exists checks all stores")
    func existsChecks() throws {
        let (composite, _, slow) = makeStore()
        #expect(try !composite.exists(forKey: "k"))
        try slow.save("v", forKey: "k")
        #expect(try composite.exists(forKey: "k"))
    }

    @Test("Clear clears all stores")
    func clearAll() throws {
        let (composite, fast, slow) = makeStore()
        try composite.save("a", forKey: "k1")
        try composite.save("b", forKey: "k2")
        try composite.clear()
        #expect(try fast.keys().isEmpty)
        #expect(try slow.keys().isEmpty)
    }

    @Test("Keys returns union")
    func keysUnion() throws {
        let (composite, fast, slow) = makeStore()
        try fast.save("a", forKey: "k1")
        try slow.save("b", forKey: "k2")
        let keys = try composite.keys().sorted()
        #expect(keys == ["k1", "k2"])
    }
}
