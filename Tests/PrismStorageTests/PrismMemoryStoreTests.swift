import Foundation
import Testing

@testable import PrismStorage

@Suite("MemStore")
struct PrismMemoryStoreTests {
    @Test("Save and load")
    func saveLoad() async throws {
        let store = PrismMemoryStore()
        try await store.save("value", forKey: "key")
        let loaded = try await store.load(String.self, forKey: "key")
        #expect(loaded == "value")
    }

    @Test("Load missing returns nil")
    func loadMissing() async throws {
        let store = PrismMemoryStore()
        let result = try await store.load(Int.self, forKey: "nope")
        #expect(result == nil)
    }

    @Test("Delete removes entry")
    func delete() async throws {
        let store = PrismMemoryStore()
        try await store.save(42, forKey: "num")
        try await store.delete(forKey: "num")
        #expect(try await !store.exists(forKey: "num"))
    }

    @Test("Exists check")
    func exists() async throws {
        let store = PrismMemoryStore()
        #expect(try await !store.exists(forKey: "x"))
        try await store.save(1, forKey: "x")
        #expect(try await store.exists(forKey: "x"))
    }

    @Test("Clear removes all")
    func clear() async throws {
        let store = PrismMemoryStore()
        try await store.save(1, forKey: "a")
        try await store.save(2, forKey: "b")
        try await store.clear()
        #expect(await store.count() == 0)
    }

    @Test("LRU eviction")
    func lruEviction() async throws {
        let store = PrismMemoryStore(maxEntries: 3)
        try await store.save(1, forKey: "a")
        try await store.save(2, forKey: "b")
        try await store.save(3, forKey: "c")
        try await store.save(4, forKey: "d")
        #expect(await store.count() == 3)
        #expect(try await !store.exists(forKey: "a"))
        #expect(try await store.exists(forKey: "d"))
    }

    @Test("LRU access refreshes position")
    func lruAccessRefresh() async throws {
        let store = PrismMemoryStore(maxEntries: 3)
        try await store.save(1, forKey: "a")
        try await store.save(2, forKey: "b")
        try await store.save(3, forKey: "c")
        _ = try await store.load(Int.self, forKey: "a")
        try await store.save(4, forKey: "d")
        #expect(try await store.exists(forKey: "a"))
        #expect(try await !store.exists(forKey: "b"))
    }

    @Test("TTL expiration")
    func ttlExpiration() async throws {
        let store = PrismMemoryStore()
        try await store.save("temp", forKey: "exp", ttl: 0.1)
        try await Task.sleep(for: .milliseconds(200))
        let loaded = try await store.load(String.self, forKey: "exp")
        #expect(loaded == nil)
    }

    @Test("Statistics tracking")
    func statistics() async throws {
        let store = PrismMemoryStore()
        try await store.save("v", forKey: "k")
        _ = try await store.load(String.self, forKey: "k")
        _ = try await store.load(String.self, forKey: "missing")

        let stats = await store.statistics()
        #expect(stats.writes == 1)
        #expect(stats.hits == 1)
        #expect(stats.misses == 1)
        #expect(stats.hitRate == 0.5)
    }

    @Test("Eviction stats")
    func evictionStats() async throws {
        let store = PrismMemoryStore(maxEntries: 2)
        try await store.save(1, forKey: "a")
        try await store.save(2, forKey: "b")
        try await store.save(3, forKey: "c")

        let stats = await store.statistics()
        #expect(stats.evictions == 1)
    }

    @Test("Codable round trip")
    func codableRoundTrip() async throws {
        struct Payload: Codable, Sendable, Equatable {
            let id: Int
            let tags: [String]
        }
        let store = PrismMemoryStore()
        let original = Payload(id: 1, tags: ["swift", "prism"])
        try await store.save(original, forKey: "payload")
        let loaded = try await store.load(Payload.self, forKey: "payload")
        #expect(loaded == original)
    }

    @Test("Keys returns non-expired keys")
    func keysExcludeExpired() async throws {
        let store = PrismMemoryStore()
        try await store.save("alive", forKey: "a", ttl: 3600)
        try await store.save("dead", forKey: "b", ttl: 0.1)
        try await Task.sleep(for: .milliseconds(200))
        let keys = try await store.keys()
        #expect(keys.contains("a"))
        #expect(!keys.contains("b"))
    }

    @Test("Empty hit rate is zero")
    func emptyHitRate() async {
        let store = PrismMemoryStore()
        let stats = await store.statistics()
        #expect(stats.hitRate == 0)
    }
}

@Suite("MemStats")
struct PrismMemoryStatsTests {
    @Test("Default stats are zero")
    func defaults() {
        let stats = PrismMemoryStats()
        #expect(stats.hits == 0)
        #expect(stats.misses == 0)
        #expect(stats.writes == 0)
        #expect(stats.evictions == 0)
        #expect(stats.expirations == 0)
    }

    @Test("Stats are equatable")
    func equatable() {
        let a = PrismMemoryStats()
        let b = PrismMemoryStats()
        #expect(a == b)
    }
}
