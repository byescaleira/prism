import Testing
import Foundation
@testable import PrismServer

@Suite("PrismCacheStore Protocol Tests")
struct PrismCacheStoreProtocolTests {

    @Test("PrismMemoryCacheStore conforms to protocol")
    func conformance() async {
        let store: any PrismCacheStore = PrismMemoryCacheStore()
        _ = store
    }

    @Test("Set and get value")
    func setAndGet() async {
        let store = PrismMemoryCacheStore()
        let data = Data("hello".utf8)
        await store.set("key1", value: data, ttl: nil)
        let result = await store.get("key1")
        #expect(result == data)
    }

    @Test("Get returns nil for missing key")
    func getMissing() async {
        let store = PrismMemoryCacheStore()
        let result = await store.get("nonexistent")
        #expect(result == nil)
    }

    @Test("Has returns true for existing key")
    func hasExisting() async {
        let store = PrismMemoryCacheStore()
        await store.set("key1", value: Data("v".utf8), ttl: nil)
        let exists = await store.has("key1")
        #expect(exists == true)
    }

    @Test("Has returns false for missing key")
    func hasMissing() async {
        let store = PrismMemoryCacheStore()
        let exists = await store.has("nope")
        #expect(exists == false)
    }

    @Test("Remove deletes key")
    func remove() async {
        let store = PrismMemoryCacheStore()
        await store.set("key1", value: Data("v".utf8), ttl: nil)
        await store.remove("key1")
        let result = await store.get("key1")
        #expect(result == nil)
    }

    @Test("Clear removes all keys")
    func clear() async {
        let store = PrismMemoryCacheStore()
        await store.set("a", value: Data("1".utf8), ttl: nil)
        await store.set("b", value: Data("2".utf8), ttl: nil)
        await store.clear()
        #expect(await store.has("a") == false)
        #expect(await store.has("b") == false)
    }

    @Test("TTL expiry works")
    func ttlExpiry() async {
        let store = PrismMemoryCacheStore(defaultTTL: 0.1)
        await store.set("key1", value: Data("v".utf8), ttl: 0.1)
        try? await Task.sleep(for: .milliseconds(150))
        let result = await store.get("key1")
        #expect(result == nil)
    }

    @Test("Custom TTL overrides default")
    func customTTL() async {
        let store = PrismMemoryCacheStore(defaultTTL: 10)
        await store.set("key1", value: Data("v".utf8), ttl: 0.1)
        try? await Task.sleep(for: .milliseconds(150))
        let result = await store.get("key1")
        #expect(result == nil)
    }
}
