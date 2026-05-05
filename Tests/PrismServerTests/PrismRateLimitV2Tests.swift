import Foundation
import Testing

@testable import PrismServer

@Suite("PrismMemoryRateLimitStore Tests")
struct PrismMemoryRateLimitStoreTests {

    @Test("Records and counts hits")
    func recordAndCount() async {
        let store = PrismMemoryRateLimitStore()
        let now = Date()
        await store.recordHit(key: "user1", at: now)
        await store.recordHit(key: "user1", at: now.addingTimeInterval(1))
        let hits = await store.getWindowHits(key: "user1", windowStart: now.addingTimeInterval(-10))
        #expect(hits == 2)
    }

    @Test("Counts only hits within window")
    func windowFiltering() async {
        let store = PrismMemoryRateLimitStore()
        let now = Date()
        await store.recordHit(key: "k", at: now.addingTimeInterval(-120))
        await store.recordHit(key: "k", at: now)
        let hits = await store.getWindowHits(key: "k", windowStart: now.addingTimeInterval(-60))
        #expect(hits == 1)
    }

    @Test("Reset clears hits")
    func reset() async {
        let store = PrismMemoryRateLimitStore()
        await store.recordHit(key: "k", at: Date())
        await store.reset(key: "k")
        let hits = await store.getWindowHits(key: "k", windowStart: Date.distantPast)
        #expect(hits == 0)
    }

    @Test("Different keys are independent")
    func independentKeys() async {
        let store = PrismMemoryRateLimitStore()
        let now = Date()
        await store.recordHit(key: "a", at: now)
        await store.recordHit(key: "b", at: now)
        await store.recordHit(key: "b", at: now)
        #expect(await store.getWindowHits(key: "a", windowStart: now.addingTimeInterval(-10)) == 1)
        #expect(await store.getWindowHits(key: "b", windowStart: now.addingTimeInterval(-10)) == 2)
    }
}

@Suite("PrismRateLimitConfig Tests")
struct PrismRateLimitConfigTests {

    @Test("perIP factory")
    func perIP() {
        let config = PrismRateLimitConfig.perIP(max: 100)
        #expect(config.maxRequests == 100)
        #expect(config.windowSeconds == 60)
    }

    @Test("perHeader factory")
    func perHeader() {
        let config = PrismRateLimitConfig.perHeader("X-API-Key", max: 50, windowSeconds: 120)
        #expect(config.maxRequests == 50)
        #expect(config.windowSeconds == 120)
    }

    @Test("global factory")
    func global() {
        let config = PrismRateLimitConfig.global(max: 1000, windowSeconds: 60)
        #expect(config.maxRequests == 1000)
    }
}

@Suite("PrismSlidingWindowMiddleware Tests")
struct PrismSlidingWindowMiddlewareTests {

    @Test("Allows requests under limit")
    func allowsUnderLimit() async throws {
        let config = PrismRateLimitConfig.global(max: 5, windowSeconds: 60)
        let middleware = PrismSlidingWindowMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("Returns 429 when exceeded")
    func returns429() async throws {
        let config = PrismRateLimitConfig.global(max: 2, windowSeconds: 60)
        let middleware = PrismSlidingWindowMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")

        _ = try await middleware.handle(request) { _ in .text("ok") }
        _ = try await middleware.handle(request) { _ in .text("ok") }
        let third = try await middleware.handle(request) { _ in .text("ok") }
        #expect(third.status == .tooManyRequests)
    }

    @Test("Adds X-RateLimit headers")
    func rateLimitHeaders() async throws {
        let config = PrismRateLimitConfig.global(max: 10, windowSeconds: 60)
        let middleware = PrismSlidingWindowMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-RateLimit-Limit") == "10")
        #expect(response.headers.value(for: "X-RateLimit-Remaining") != nil)
    }
}
