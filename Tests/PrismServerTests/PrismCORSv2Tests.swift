import Foundation
import Testing

@testable import PrismServer

@Suite("PrismCORSv2 Tests")
struct PrismCORSv2Tests {

    @Test("Default config allows any origin")
    func defaultConfigAnyOrigin() async throws {
        let middleware = PrismCORSv2Middleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/api/test")
        request.headers.set(name: "Origin", value: "https://example.com")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        #expect(response.headers.value(for: "Access-Control-Allow-Origin") == "*")
    }

    @Test("Exact origins only allow listed origins")
    func exactOrigins() async throws {
        let config = PrismCORSv2Config(allowedOrigins: .exact(["https://app.com"]))
        let middleware = PrismCORSv2Middleware(config: config)

        var request = PrismHTTPRequest(method: .GET, uri: "/api/test")
        request.headers.set(name: "Origin", value: "https://app.com")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        #expect(response.headers.value(for: "Access-Control-Allow-Origin") == "https://app.com")
    }

    @Test("Exact origins reject unlisted origins")
    func exactOriginsReject() async throws {
        let config = PrismCORSv2Config(allowedOrigins: .exact(["https://app.com"]))
        let middleware = PrismCORSv2Middleware(config: config)

        var request = PrismHTTPRequest(method: .GET, uri: "/api/test")
        request.headers.set(name: "Origin", value: "https://evil.com")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        #expect(response.headers.value(for: "Access-Control-Allow-Origin") == nil)
    }

    @Test("Reflect origin policy echoes the origin")
    func reflectOrigin() async throws {
        let config = PrismCORSv2Config(allowedOrigins: .reflect)
        let middleware = PrismCORSv2Middleware(config: config)

        var request = PrismHTTPRequest(method: .GET, uri: "/api/test")
        request.headers.set(name: "Origin", value: "https://any-site.com")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        #expect(response.headers.value(for: "Access-Control-Allow-Origin") == "https://any-site.com")
    }

    @Test("Custom origin checker")
    func customOriginChecker() async throws {
        let config = PrismCORSv2Config(
            allowedOrigins: .custom { origin in
                origin.hasSuffix(".myapp.com")
            })
        let middleware = PrismCORSv2Middleware(config: config)

        var req1 = PrismHTTPRequest(method: .GET, uri: "/api")
        req1.headers.set(name: "Origin", value: "https://sub.myapp.com")
        let res1 = try await middleware.handle(req1) { _ in PrismHTTPResponse.text("ok") }
        #expect(res1.headers.value(for: "Access-Control-Allow-Origin") == "https://sub.myapp.com")

        var req2 = PrismHTTPRequest(method: .GET, uri: "/api")
        req2.headers.set(name: "Origin", value: "https://evil.com")
        let res2 = try await middleware.handle(req2) { _ in PrismHTTPResponse.text("ok") }
        #expect(res2.headers.value(for: "Access-Control-Allow-Origin") == nil)
    }

    @Test("Preflight returns 204 with correct headers")
    func preflightRequest() async throws {
        let config = PrismCORSv2Config(maxAge: 3600)
        let middleware = PrismCORSv2Middleware(config: config)

        var request = PrismHTTPRequest(method: .OPTIONS, uri: "/api/test")
        request.headers.set(name: "Origin", value: "https://app.com")
        request.headers.set(name: "Access-Control-Request-Method", value: "POST")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.status == .noContent)
        #expect(response.headers.value(for: "Access-Control-Max-Age") == "3600")
        #expect(response.headers.value(for: "Access-Control-Allow-Methods") != nil)
    }

    @Test("Credentials header set when enabled")
    func credentialsHeader() async throws {
        let config = PrismCORSv2Config(allowedOrigins: .reflect, allowCredentials: true)
        let middleware = PrismCORSv2Middleware(config: config)

        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Origin", value: "https://app.com")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        #expect(response.headers.value(for: "Access-Control-Allow-Credentials") == "true")
    }

    @Test("Exposed headers set correctly")
    func exposedHeaders() async throws {
        let config = PrismCORSv2Config(exposedHeaders: ["X-Custom", "X-Total"])
        let middleware = PrismCORSv2Middleware(config: config)

        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Origin", value: "https://app.com")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        let exposed = response.headers.value(for: "Access-Control-Expose-Headers") ?? ""
        #expect(exposed.contains("X-Custom"))
        #expect(exposed.contains("X-Total"))
    }

    @Test("Route override uses different config")
    func routeOverride() async throws {
        let defaultConfig = PrismCORSv2Config(allowedOrigins: .none)
        let apiConfig = PrismCORSv2Config(allowedOrigins: .any)
        let middleware = PrismCORSv2Middleware(config: defaultConfig, routeOverrides: ["/api": apiConfig])

        var apiReq = PrismHTTPRequest(method: .GET, uri: "/api/data")
        apiReq.headers.set(name: "Origin", value: "https://test.com")

        let apiRes = try await middleware.handle(apiReq) { _ in PrismHTTPResponse.text("ok") }
        #expect(apiRes.headers.value(for: "Access-Control-Allow-Origin") == "*")

        var otherReq = PrismHTTPRequest(method: .GET, uri: "/other")
        otherReq.headers.set(name: "Origin", value: "https://test.com")

        let otherRes = try await middleware.handle(otherReq) { _ in PrismHTTPResponse.text("ok") }
        #expect(otherRes.headers.value(for: "Access-Control-Allow-Origin") == nil)
    }

    @Test("Vary header added for non-wildcard origins")
    func varyHeader() async throws {
        let config = PrismCORSv2Config(allowedOrigins: .reflect)
        let middleware = PrismCORSv2Middleware(config: config)

        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Origin", value: "https://app.com")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        let vary = response.headers.values(for: "Vary")
        #expect(vary.contains("Origin"))
    }

    @Test("No Vary header for wildcard origin")
    func noVaryForWildcard() async throws {
        let config = PrismCORSv2Config(allowedOrigins: .any)
        let middleware = PrismCORSv2Middleware(config: config)

        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Origin", value: "https://app.com")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        let vary = response.headers.values(for: "Vary")
        #expect(!vary.contains("Origin"))
    }

    @Test("Preflight continue passes to next handler")
    func preflightContinue() async throws {
        let config = PrismCORSv2Config(preflightContinue: true)
        let middleware = PrismCORSv2Middleware(config: config)

        var request = PrismHTTPRequest(method: .OPTIONS, uri: "/api")
        request.headers.set(name: "Origin", value: "https://app.com")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("custom options response")
        }

        let body = String(data: response.body.data, encoding: .utf8)
        #expect(body == "custom options response")
    }

    @Test("None origin policy blocks all origins")
    func noneOriginPolicy() async throws {
        let config = PrismCORSv2Config(allowedOrigins: .none)
        let middleware = PrismCORSv2Middleware(config: config)

        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Origin", value: "https://app.com")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        #expect(response.headers.value(for: "Access-Control-Allow-Origin") == nil)
    }

    @Test("Origin policy isAllowed works correctly")
    func originPolicyIsAllowed() {
        #expect(PrismCORSOriginPolicy.any.isAllowed("https://anything.com") == true)
        #expect(PrismCORSOriginPolicy.none.isAllowed("https://anything.com") == false)
        #expect(PrismCORSOriginPolicy.exact(["https://a.com"]).isAllowed("https://a.com") == true)
        #expect(PrismCORSOriginPolicy.exact(["https://a.com"]).isAllowed("https://b.com") == false)
        #expect(PrismCORSOriginPolicy.reflect.isAllowed("https://anything.com") == true)
    }
}
