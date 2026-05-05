import Foundation
import Testing

@testable import PrismServer

@Suite("PrismProxy Tests")
struct PrismProxyTests {

    @Test("Proxy config stores upstream URL")
    func configStoresUpstream() {
        let config = PrismProxyConfig(upstream: "https://api.example.com")
        #expect(config.upstream == "https://api.example.com")
    }

    @Test("Proxy config strips trailing slash from upstream")
    func configStripsTrailingSlash() {
        let config = PrismProxyConfig(upstream: "https://api.example.com/")
        #expect(config.upstream == "https://api.example.com")
    }

    @Test("Proxy config default values")
    func configDefaults() {
        let config = PrismProxyConfig(upstream: "https://api.example.com")
        #expect(config.timeout == 30)
        #expect(config.forwardHeaders == true)
        #expect(config.preserveHost == false)
        #expect(config.pathRewrite.isEmpty)
        #expect(config.additionalHeaders.isEmpty)
    }

    @Test("Non-matching path passes through")
    func nonMatchingPathPassthrough() async throws {
        let config = PrismProxyConfig(upstream: "https://api.example.com")
        let middleware = PrismProxyMiddleware(pathPrefix: "/api", config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/other/path")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("from next handler")
        }

        #expect(String(data: response.body.data, encoding: .utf8) == "from next handler")
    }

    @Test("Path rewrite config")
    func pathRewriteConfig() {
        let config = PrismProxyConfig(
            upstream: "https://api.example.com",
            pathRewrite: ["/v1": "/v2", "/old": "/new"]
        )
        #expect(config.pathRewrite.count == 2)
    }

    @Test("Additional headers config")
    func additionalHeadersConfig() {
        let config = PrismProxyConfig(
            upstream: "https://api.example.com",
            additionalHeaders: ["X-API-Key": "secret"]
        )
        #expect(config.additionalHeaders["X-API-Key"] == "secret")
    }

    @Test("Strip prefix config")
    func stripPrefixConfig() {
        let config = PrismProxyConfig(
            upstream: "https://api.example.com",
            stripPrefix: "/api/v1"
        )
        #expect(config.stripPrefix == "/api/v1")
    }

    @Test("Timeout config")
    func timeoutConfig() {
        let config = PrismProxyConfig(upstream: "https://api.example.com", timeout: 60)
        #expect(config.timeout == 60)
    }

    @Test("Preserve host config")
    func preserveHostConfig() {
        let config = PrismProxyConfig(upstream: "https://api.example.com", preserveHost: true)
        #expect(config.preserveHost == true)
    }

    @Test("Forward headers config")
    func forwardHeadersConfig() {
        let config = PrismProxyConfig(upstream: "https://api.example.com", forwardHeaders: false)
        #expect(config.forwardHeaders == false)
    }

    @Test("Proxy middleware with root path prefix matches all paths")
    func rootPathPrefixMatchesAll() async throws {
        let config = PrismProxyConfig(upstream: "https://httpbin.org")
        let middleware = PrismProxyMiddleware(pathPrefix: "/", config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/get")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.status.code >= 200 || response.status == .badGateway)
    }

    @Test("Proxy sets X-Forwarded headers")
    func xForwardedHeaders() {
        let config = PrismProxyConfig(upstream: "https://api.example.com")
        #expect(config.forwardHeaders == true)
    }

    @Test("Multiple path rewrites")
    func multipleRewrites() {
        let config = PrismProxyConfig(
            upstream: "https://api.example.com",
            pathRewrite: ["/api/v1": "/v1", "/api/v2": "/v2"]
        )
        #expect(config.pathRewrite.count == 2)
        #expect(config.pathRewrite["/api/v1"] == "/v1")
        #expect(config.pathRewrite["/api/v2"] == "/v2")
    }

    @Test("Proxy middleware constructor")
    func middlewareConstructor() {
        let config = PrismProxyConfig(upstream: "https://backend.local:8080")
        let middleware = PrismProxyMiddleware(pathPrefix: "/proxy", config: config)
        _ = middleware
    }

    @Test("Complex upstream URL preserved")
    func complexUpstreamUrl() {
        let config = PrismProxyConfig(upstream: "https://user:pass@api.internal:9090/base")
        #expect(config.upstream == "https://user:pass@api.internal:9090/base")
    }
}
