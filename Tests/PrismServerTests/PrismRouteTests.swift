import Foundation
import Testing

@testable import PrismServer

@Suite("PrismRoute Tests")
struct PrismRouteTests {

    @Test("Exact path match")
    func exactMatch() {
        let route = PrismRoute(method: .GET, pattern: "/users") { _ in .text("ok") }
        let params = route.match(path: "/users")
        #expect(params != nil)
        #expect(params?.isEmpty == true)
    }

    @Test("Path with parameter")
    func parameterMatch() {
        let route = PrismRoute(method: .GET, pattern: "/users/:id") { _ in .text("ok") }
        let params = route.match(path: "/users/42")
        #expect(params?["id"] == "42")
    }

    @Test("Multiple parameters")
    func multipleParams() {
        let route = PrismRoute(method: .GET, pattern: "/users/:userId/posts/:postId") { _ in .text("ok") }
        let params = route.match(path: "/users/1/posts/99")
        #expect(params?["userId"] == "1")
        #expect(params?["postId"] == "99")
    }

    @Test("No match on different segment count")
    func noMatchDifferentCount() {
        let route = PrismRoute(method: .GET, pattern: "/users/:id") { _ in .text("ok") }
        #expect(route.match(path: "/users") == nil)
        #expect(route.match(path: "/users/1/extra") == nil)
    }

    @Test("No match on wrong literal")
    func noMatchWrongLiteral() {
        let route = PrismRoute(method: .GET, pattern: "/users/:id") { _ in .text("ok") }
        #expect(route.match(path: "/posts/1") == nil)
    }

    @Test("Wildcard match")
    func wildcardMatch() {
        let route = PrismRoute(method: .GET, pattern: "/files/*") { _ in .text("ok") }
        let params = route.match(path: "/files/path/to/file.txt")
        #expect(params?["*"] == "path/to/file.txt")
    }

    @Test("Root path match")
    func rootMatch() {
        let route = PrismRoute(method: .GET, pattern: "/") { _ in .text("ok") }
        let params = route.match(path: "/")
        #expect(params != nil)
    }

    @Test("RouteSegment parsing")
    func segmentParsing() {
        let segments = RouteSegment.parse("/users/:id/posts")
        #expect(segments.count == 3)
    }
}
