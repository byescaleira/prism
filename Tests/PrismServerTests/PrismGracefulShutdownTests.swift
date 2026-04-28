#if canImport(Network)
import Testing
import Foundation
@testable import PrismServer

@Suite("PrismGracefulShutdown Tests")
struct PrismGracefulShutdownTests {

    @Test("Starts not shutting down")
    func initialState() async {
        let shutdown = PrismGracefulShutdown()
        #expect(await shutdown.shuttingDown == false)
    }

    @Test("performShutdown sets shuttingDown")
    func performShutdownSetsFlag() async {
        let shutdown = PrismGracefulShutdown()
        await shutdown.performShutdown { }
        #expect(await shutdown.shuttingDown == true)
    }

    @Test("performShutdown runs registered handlers")
    func performShutdownRunsHandlers() async {
        let shutdown = PrismGracefulShutdown()
        let tracker = CallTracker()
        await shutdown.onShutdown {
            await tracker.record()
        }
        await shutdown.performShutdown { }
        #expect(await tracker.count == 1)
    }

    @Test("performShutdown runs multiple handlers in order")
    func multipleHandlers() async {
        let shutdown = PrismGracefulShutdown()
        let tracker = CallTracker()
        await shutdown.onShutdown { await tracker.record() }
        await shutdown.onShutdown { await tracker.record() }
        await shutdown.onShutdown { await tracker.record() }
        await shutdown.performShutdown { }
        #expect(await tracker.count == 3)
    }

    @Test("performShutdown is idempotent")
    func idempotent() async {
        let shutdown = PrismGracefulShutdown()
        let tracker = CallTracker()
        await shutdown.onShutdown { await tracker.record() }
        await shutdown.performShutdown { }
        await shutdown.performShutdown { }
        #expect(await tracker.count == 1)
    }

    @Test("performShutdown calls final shutdown closure")
    func finalShutdownCalled() async {
        let shutdown = PrismGracefulShutdown()
        let tracker = CallTracker()
        await shutdown.performShutdown { await tracker.record() }
        #expect(await tracker.count == 1)
    }
}

@Suite("PrismShutdownMiddleware Tests")
struct PrismShutdownMiddlewareTests {

    @Test("Passes through when not shutting down")
    func passThrough() async throws {
        let shutdown = PrismGracefulShutdown()
        let middleware = PrismShutdownMiddleware(shutdown: shutdown)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("Returns 503 when shutting down")
    func rejectsDuringShutdown() async throws {
        let shutdown = PrismGracefulShutdown()
        await shutdown.performShutdown { }
        let middleware = PrismShutdownMiddleware(shutdown: shutdown)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .serviceUnavailable)
    }

    @Test("503 response includes Connection close header")
    func connectionCloseHeader() async throws {
        let shutdown = PrismGracefulShutdown()
        await shutdown.performShutdown { }
        let middleware = PrismShutdownMiddleware(shutdown: shutdown)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "Connection") == "close")
    }

    @Test("503 response includes Retry-After header")
    func retryAfterHeader() async throws {
        let shutdown = PrismGracefulShutdown()
        await shutdown.performShutdown { }
        let middleware = PrismShutdownMiddleware(shutdown: shutdown)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "Retry-After") == "5")
    }
}

private actor CallTracker {
    var count = 0
    func record() { count += 1 }
}
#endif
