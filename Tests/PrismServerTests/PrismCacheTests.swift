import Foundation
import Testing

@testable import PrismServer

@Suite("PrismCache Tests")
struct PrismCacheTests {

    @Test("Set and get value")
    func setAndGet() async {
        let cache = PrismCache<String, String>(maxEntries: 100)
        await cache.set("key", value: "value")
        let result = await cache.get("key")
        #expect(result == "value")
    }

    @Test("Get returns nil for missing key")
    func missingKey() async {
        let cache = PrismCache<String, String>()
        let result = await cache.get("missing")
        #expect(result == nil)
    }

    @Test("Has returns correct status")
    func hasKey() async {
        let cache = PrismCache<String, Int>()
        await cache.set("a", value: 1)
        #expect(await cache.has("a") == true)
        #expect(await cache.has("b") == false)
    }

    @Test("Remove key")
    func removeKey() async {
        let cache = PrismCache<String, String>()
        await cache.set("key", value: "value")
        await cache.remove("key")
        #expect(await cache.get("key") == nil)
    }

    @Test("Clear removes all entries")
    func clearCache() async {
        let cache = PrismCache<String, String>()
        await cache.set("a", value: "1")
        await cache.set("b", value: "2")
        await cache.clear()
        #expect(await cache.count == 0)
    }

    @Test("LRU eviction when max entries exceeded")
    func lruEviction() async {
        let cache = PrismCache<String, String>(maxEntries: 3)
        await cache.set("a", value: "1")
        await cache.set("b", value: "2")
        await cache.set("c", value: "3")
        await cache.set("d", value: "4")
        #expect(await cache.get("a") == nil)
        #expect(await cache.get("d") == "4")
    }

    @Test("TTL expiration")
    func ttlExpiration() async throws {
        let cache = PrismCache<String, String>(defaultTTL: 0.1)
        await cache.set("key", value: "value")
        try await Task.sleep(for: .milliseconds(150))
        #expect(await cache.get("key") == nil)
    }

    @Test("Custom TTL per entry")
    func customTTL() async throws {
        let cache = PrismCache<String, String>(defaultTTL: 10)
        await cache.set("short", value: "value", ttl: 0.1)
        try await Task.sleep(for: .milliseconds(150))
        #expect(await cache.get("short") == nil)
    }

    @Test("Purge expired entries")
    func purgeExpired() async throws {
        let cache = PrismCache<String, String>(defaultTTL: 0.1)
        await cache.set("a", value: "1")
        await cache.set("b", value: "2")
        try await Task.sleep(for: .milliseconds(150))
        await cache.purgeExpired()
        #expect(await cache.count == 0)
    }

    @Test("Count tracks entries")
    func count() async {
        let cache = PrismCache<String, Int>()
        #expect(await cache.count == 0)
        await cache.set("a", value: 1)
        #expect(await cache.count == 1)
        await cache.set("b", value: 2)
        #expect(await cache.count == 2)
    }

    @Test("LRU promotes accessed keys")
    func lruPromotion() async {
        let cache = PrismCache<String, String>(maxEntries: 3)
        await cache.set("a", value: "1")
        await cache.set("b", value: "2")
        await cache.set("c", value: "3")
        _ = await cache.get("a")
        await cache.set("d", value: "4")
        #expect(await cache.get("a") == "1")
        #expect(await cache.get("b") == nil)
    }
}

@Suite("PrismResponseCacheMiddleware Tests")
struct PrismResponseCacheMiddlewareTests {

    @Test("Caches GET responses")
    func cacheGET() async throws {
        let middleware = PrismResponseCacheMiddleware(ttl: 60)

        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let first = try await middleware.handle(request) { _ in .text("response") }
        #expect(first.headers.value(for: "X-Cache") == "MISS")

        let second = try await middleware.handle(request) { _ in .text("different") }
        #expect(second.headers.value(for: "X-Cache") == "HIT")
    }

    @Test("Does not cache POST requests by default")
    func noCachePOST() async throws {
        let middleware = PrismResponseCacheMiddleware()
        let request = PrismHTTPRequest(method: .POST, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-Cache") == nil)
    }

    @Test("ETag and If-None-Match returns 304")
    func etagNotModified() async throws {
        let middleware = PrismResponseCacheMiddleware(ttl: 60)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")

        let first = try await middleware.handle(request) { _ in .text("data") }
        let etag = first.headers.value(for: "ETag")!

        var secondReq = PrismHTTPRequest(method: .GET, uri: "/test")
        secondReq.headers.set(name: "If-None-Match", value: etag)
        let second = try await middleware.handle(secondReq) { _ in .text("data") }
        #expect(second.status == .notModified)
    }
}
