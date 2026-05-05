import Foundation
import Testing

@testable import PrismServer

@Suite("PrismCORSMiddleware Tests")
struct PrismCORSMiddlewareTests {

    @Test("Adds CORS headers to response")
    func corsHeaders() async throws {
        let middleware = PrismCORSMiddleware()
        var headers = PrismHTTPHeaders()
        headers.set(name: "Origin", value: "http://example.com")
        let request = PrismHTTPRequest(method: .GET, uri: "/test", headers: headers)

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "Access-Control-Allow-Origin") == "*")
        #expect(response.headers.value(for: "Access-Control-Allow-Methods") != nil)
    }

    @Test("OPTIONS preflight returns 204")
    func preflight() async throws {
        let middleware = PrismCORSMiddleware()
        let request = PrismHTTPRequest(method: .OPTIONS, uri: "/test")

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .noContent)
    }

    @Test("Custom allowed origins")
    func customOrigins() async throws {
        let middleware = PrismCORSMiddleware(allowedOrigins: ["http://allowed.com"])
        var headers = PrismHTTPHeaders()
        headers.set(name: "Origin", value: "http://allowed.com")
        let request = PrismHTTPRequest(method: .GET, uri: "/test", headers: headers)

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "Access-Control-Allow-Origin") == "http://allowed.com")
    }

    @Test("Credentials header when enabled")
    func credentials() async throws {
        let middleware = PrismCORSMiddleware(allowCredentials: true)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "Access-Control-Allow-Credentials") == "true")
    }
}

@Suite("PrismAuthMiddleware Tests")
struct PrismAuthMiddlewareTests {

    @Test("Missing auth header returns 401")
    func missingAuth() async throws {
        let middleware = PrismAuthMiddleware { _ in true }
        let request = PrismHTTPRequest(method: .GET, uri: "/secure")

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .unauthorized)
    }

    @Test("Invalid scheme returns 401")
    func invalidScheme() async throws {
        let middleware = PrismAuthMiddleware { _ in true }
        var headers = PrismHTTPHeaders()
        headers.set(name: "Authorization", value: "Basic dXNlcjpwYXNz")
        let request = PrismHTTPRequest(method: .GET, uri: "/secure", headers: headers)

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .unauthorized)
    }

    @Test("Valid token passes through")
    func validToken() async throws {
        let middleware = PrismAuthMiddleware { token in token == "valid-token" }
        var headers = PrismHTTPHeaders()
        headers.set(name: "Authorization", value: "Bearer valid-token")
        let request = PrismHTTPRequest(method: .GET, uri: "/secure", headers: headers)

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("Invalid token returns 401")
    func invalidToken() async throws {
        let middleware = PrismAuthMiddleware { _ in false }
        var headers = PrismHTTPHeaders()
        headers.set(name: "Authorization", value: "Bearer bad-token")
        let request = PrismHTTPRequest(method: .GET, uri: "/secure", headers: headers)

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .unauthorized)
    }

    @Test("Token stored in userInfo")
    func tokenInUserInfo() async throws {
        let middleware = PrismAuthMiddleware { _ in true }
        var headers = PrismHTTPHeaders()
        headers.set(name: "Authorization", value: "Bearer my-token")
        let request = PrismHTTPRequest(method: .GET, uri: "/secure", headers: headers)

        _ = try await middleware.handle(request) { req in
            #expect(req.userInfo["authToken"] == "my-token")
            return .text("ok")
        }
    }
}

@Suite("PrismRateLimitMiddleware Tests")
struct PrismRateLimitMiddlewareTests {

    @Test("Allows requests within limit")
    func withinLimit() async throws {
        let middleware = PrismRateLimitMiddleware(maxRequests: 5, windowSeconds: 60) { _ in "test-client" }
        let request = PrismHTTPRequest(method: .GET, uri: "/test")

        for _ in 0..<5 {
            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.status == .ok)
        }
    }

    @Test("Blocks requests over limit")
    func overLimit() async throws {
        let middleware = PrismRateLimitMiddleware(maxRequests: 2, windowSeconds: 60) { _ in "test-client" }
        let request = PrismHTTPRequest(method: .GET, uri: "/test")

        _ = try await middleware.handle(request) { _ in .text("ok") }
        _ = try await middleware.handle(request) { _ in .text("ok") }
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .tooManyRequests)
        #expect(response.headers.value(for: "Retry-After") == "60")
    }
}
