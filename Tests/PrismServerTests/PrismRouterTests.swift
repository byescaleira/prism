import Foundation
import Testing

@testable import PrismServer

@Suite("PrismRouter Tests")
struct PrismRouterTests {

    @Test("Routes GET request to correct handler")
    func routeGET() async throws {
        let router = PrismRouter(
            routes: [
                PrismRoute(method: .GET, pattern: "/health") { _ in .text("ok") }
            ],
            middlewares: [],
            groups: []
        )

        let request = PrismHTTPRequest(method: .GET, uri: "/health")
        let response = try await router.handle(request)
        #expect(response.status == .ok)
        #expect(response.body.data == Data("ok".utf8))
    }

    @Test("Returns 404 for unmatched route")
    func notFound() async throws {
        let router = PrismRouter(routes: [], middlewares: [], groups: [])
        let request = PrismHTTPRequest(method: .GET, uri: "/missing")
        let response = try await router.handle(request)
        #expect(response.status == .notFound)
    }

    @Test("Route with parameters")
    func routeParams() async throws {
        let router = PrismRouter(
            routes: [
                PrismRoute(method: .GET, pattern: "/users/:id") { req in
                    .text("User \(req.parameter("id") ?? "?")")
                }
            ],
            middlewares: [],
            groups: []
        )

        let request = PrismHTTPRequest(method: .GET, uri: "/users/42")
        let response = try await router.handle(request)
        #expect(response.body.data == Data("User 42".utf8))
    }

    @Test("Middleware modifies response")
    func middlewareChain() async throws {
        struct AddHeaderMiddleware: PrismMiddleware {
            func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws
                -> PrismHTTPResponse
            {
                var response = try await next(request)
                response.headers.set(name: "X-Custom", value: "added")
                return response
            }
        }

        let router = PrismRouter(
            routes: [
                PrismRoute(method: .GET, pattern: "/test") { _ in .text("ok") }
            ],
            middlewares: [AddHeaderMiddleware()],
            groups: []
        )

        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await router.handle(request)
        #expect(response.headers.value(for: "X-Custom") == "added")
    }

    @Test("Method mismatch returns 404")
    func methodMismatch() async throws {
        let router = PrismRouter(
            routes: [
                PrismRoute(method: .POST, pattern: "/data") { _ in .text("ok") }
            ],
            middlewares: [],
            groups: []
        )

        let request = PrismHTTPRequest(method: .GET, uri: "/data")
        let response = try await router.handle(request)
        #expect(response.status == .notFound)
    }

    @Test("Route group with prefix")
    func routeGroup() async throws {
        let group = PrismRouteGroup(
            prefix: "/api",
            middlewares: [],
            routes: [
                PrismRoute(method: .GET, pattern: "/users") { _ in .text("users") }
            ],
            subgroups: []
        )

        let router = PrismRouter(routes: [], middlewares: [], groups: [group])
        let request = PrismHTTPRequest(method: .GET, uri: "/api/users")
        let response = try await router.handle(request)
        #expect(response.body.data == Data("users".utf8))
    }
}
