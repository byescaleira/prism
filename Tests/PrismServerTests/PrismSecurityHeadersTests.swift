import Testing

@testable import PrismServer

@Suite("PrismSecurityHeadersConfig Tests")
struct PrismSecurityHeadersConfigTests {

    @Test("Default config has standard four headers")
    func defaultConfig() {
        let config = PrismSecurityHeadersConfig.default
        #expect(config.contentTypeOptions == "nosniff")
        #expect(config.frameOptions == "DENY")
        #expect(config.xssProtection == "1; mode=block")
        #expect(config.referrerPolicy == "strict-origin-when-cross-origin")
        #expect(config.contentSecurityPolicy == nil)
        #expect(config.permissionsPolicy == nil)
        #expect(config.crossOriginEmbedderPolicy == nil)
        #expect(config.crossOriginOpenerPolicy == nil)
        #expect(config.crossOriginResourcePolicy == nil)
    }

    @Test("Strict config includes all nine headers")
    func strictConfig() {
        let config = PrismSecurityHeadersConfig.strict
        #expect(config.contentTypeOptions == "nosniff")
        #expect(config.frameOptions == "DENY")
        #expect(config.xssProtection == "1; mode=block")
        #expect(config.referrerPolicy == "strict-origin-when-cross-origin")
        #expect(config.contentSecurityPolicy == "default-src 'self'")
        #expect(config.permissionsPolicy == "camera=(), microphone=(), geolocation=()")
        #expect(config.crossOriginEmbedderPolicy == "require-corp")
        #expect(config.crossOriginOpenerPolicy == "same-origin")
        #expect(config.crossOriginResourcePolicy == "same-origin")
    }

    @Test("Custom config with only CSP")
    func customCSPOnly() {
        let config = PrismSecurityHeadersConfig(
            contentTypeOptions: nil,
            frameOptions: nil,
            xssProtection: nil,
            referrerPolicy: nil,
            contentSecurityPolicy: "default-src 'self'; script-src 'unsafe-inline'"
        )
        #expect(config.contentTypeOptions == nil)
        #expect(config.frameOptions == nil)
        #expect(config.contentSecurityPolicy == "default-src 'self'; script-src 'unsafe-inline'")
    }
}

@Suite("PrismHelmetMiddleware Tests")
struct PrismHelmetMiddlewareTests {

    @Test("Default config adds four standard headers")
    func defaultHeaders() async throws {
        let middleware = PrismHelmetMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-Content-Type-Options") == "nosniff")
        #expect(response.headers.value(for: "X-Frame-Options") == "DENY")
        #expect(response.headers.value(for: "X-XSS-Protection") == "1; mode=block")
        #expect(response.headers.value(for: "Referrer-Policy") == "strict-origin-when-cross-origin")
    }

    @Test("Default config does not add optional headers")
    func defaultOmitsOptional() async throws {
        let middleware = PrismHelmetMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "Content-Security-Policy") == nil)
        #expect(response.headers.value(for: "Permissions-Policy") == nil)
        #expect(response.headers.value(for: "Cross-Origin-Embedder-Policy") == nil)
        #expect(response.headers.value(for: "Cross-Origin-Opener-Policy") == nil)
        #expect(response.headers.value(for: "Cross-Origin-Resource-Policy") == nil)
    }

    @Test("Strict config adds all nine headers")
    func strictHeaders() async throws {
        let middleware = PrismHelmetMiddleware(config: .strict)
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-Content-Type-Options") == "nosniff")
        #expect(response.headers.value(for: "X-Frame-Options") == "DENY")
        #expect(response.headers.value(for: "X-XSS-Protection") == "1; mode=block")
        #expect(response.headers.value(for: "Referrer-Policy") == "strict-origin-when-cross-origin")
        #expect(response.headers.value(for: "Content-Security-Policy") == "default-src 'self'")
        #expect(response.headers.value(for: "Permissions-Policy") == "camera=(), microphone=(), geolocation=()")
        #expect(response.headers.value(for: "Cross-Origin-Embedder-Policy") == "require-corp")
        #expect(response.headers.value(for: "Cross-Origin-Opener-Policy") == "same-origin")
        #expect(response.headers.value(for: "Cross-Origin-Resource-Policy") == "same-origin")
    }

    @Test("Custom CSP header applied")
    func customCSP() async throws {
        let config = PrismSecurityHeadersConfig(contentSecurityPolicy: "script-src 'self' cdn.example.com")
        let middleware = PrismHelmetMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "Content-Security-Policy") == "script-src 'self' cdn.example.com")
    }

    @Test("Nil headers not added to response")
    func nilHeadersOmitted() async throws {
        let config = PrismSecurityHeadersConfig(
            contentTypeOptions: nil,
            frameOptions: nil,
            xssProtection: nil,
            referrerPolicy: nil
        )
        let middleware = PrismHelmetMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-Content-Type-Options") == nil)
        #expect(response.headers.value(for: "X-Frame-Options") == nil)
        #expect(response.headers.value(for: "X-XSS-Protection") == nil)
        #expect(response.headers.value(for: "Referrer-Policy") == nil)
    }

    @Test("Preserves response body and status")
    func preservesResponse() async throws {
        let middleware = PrismHelmetMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .created, body: .text("created"))
        }
        #expect(response.status == .created)
    }

    @Test("Works with POST requests")
    func postRequests() async throws {
        let middleware = PrismHelmetMiddleware(config: .strict)
        let request = PrismHTTPRequest(method: .POST, uri: "/submit")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-Content-Type-Options") == "nosniff")
        #expect(response.headers.value(for: "Content-Security-Policy") == "default-src 'self'")
    }

    @Test("Config with only specific headers")
    func selectiveHeaders() async throws {
        let config = PrismSecurityHeadersConfig(
            contentTypeOptions: "nosniff",
            frameOptions: nil,
            xssProtection: nil,
            referrerPolicy: nil,
            contentSecurityPolicy: "default-src 'none'",
            permissionsPolicy: "camera=()"
        )
        let middleware = PrismHelmetMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-Content-Type-Options") == "nosniff")
        #expect(response.headers.value(for: "X-Frame-Options") == nil)
        #expect(response.headers.value(for: "X-XSS-Protection") == nil)
        #expect(response.headers.value(for: "Referrer-Policy") == nil)
        #expect(response.headers.value(for: "Content-Security-Policy") == "default-src 'none'")
        #expect(response.headers.value(for: "Permissions-Policy") == "camera=()")
    }
}
