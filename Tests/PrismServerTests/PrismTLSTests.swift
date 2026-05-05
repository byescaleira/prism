#if canImport(Network)
    import Testing
    import Foundation
    @testable import PrismServer

    @Suite("PrismTLSConfiguration Tests")
    struct PrismTLSConfigurationTests {

        @Test("Default configuration values")
        func defaultValues() {
            let config = PrismTLSConfiguration()
            #expect(config.identityPath == nil)
            #expect(config.passphrase == nil)
            #expect(config.minimumVersion == .tlsv12)
            #expect(config.hstsEnabled == true)
            #expect(config.hstsMaxAge == 31_536_000)
        }

        @Test("Custom configuration values")
        func customValues() {
            let config = PrismTLSConfiguration(
                identityPath: "/path/to/cert.p12",
                passphrase: "secret",
                minimumVersion: .tlsv13,
                hstsEnabled: false,
                hstsMaxAge: 86400
            )
            #expect(config.identityPath == "/path/to/cert.p12")
            #expect(config.passphrase == "secret")
            #expect(config.minimumVersion == .tlsv13)
            #expect(config.hstsEnabled == false)
            #expect(config.hstsMaxAge == 86400)
        }

        @Test("makeOptions throws for missing identity file")
        func makeOptionsThrowsMissingFile() async {
            let config = PrismTLSConfiguration(identityPath: "/nonexistent/cert.p12")
            #expect(throws: PrismHTTPError.self) {
                _ = try config.makeOptions()
            }
        }

        @Test("makeOptions succeeds without identity path")
        func makeOptionsNoIdentity() throws {
            let config = PrismTLSConfiguration()
            _ = try config.makeOptions()
        }
    }

    @Suite("TLSVersion Tests")
    struct TLSVersionTests {

        @Test("All TLS versions have valid nwVersion mapping")
        func allVersionsMap() {
            let versions: [TLSVersion] = [.tlsv10, .tlsv11, .tlsv12, .tlsv13]
            for version in versions {
                _ = version.nwVersion
            }
        }

        @Test("TLS 1.2 maps to correct protocol version")
        func tls12Mapping() {
            #expect(TLSVersion.tlsv12.nwVersion == .TLSv12)
        }

        @Test("TLS 1.3 maps to correct protocol version")
        func tls13Mapping() {
            #expect(TLSVersion.tlsv13.nwVersion == .TLSv13)
        }

        @Test("TLS 1.0 version is accessible")
        func tls10Mapping() {
            _ = TLSVersion.tlsv10.nwVersion
        }

        @Test("TLS 1.1 version is accessible")
        func tls11Mapping() {
            _ = TLSVersion.tlsv11.nwVersion
        }
    }

    @Suite("PrismHSTSMiddleware Tests")
    struct PrismHSTSMiddlewareTests {

        @Test("Default HSTS header")
        func defaultHeader() async throws {
            let middleware = PrismHSTSMiddleware()
            let request = PrismHTTPRequest(method: .GET, uri: "/test")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            let header = response.headers.value(for: "Strict-Transport-Security")
            #expect(header == "max-age=31536000; includeSubDomains")
        }

        @Test("Custom max-age")
        func customMaxAge() async throws {
            let middleware = PrismHSTSMiddleware(maxAge: 86400, includeSubDomains: false)
            let request = PrismHTTPRequest(method: .GET, uri: "/test")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            let header = response.headers.value(for: "Strict-Transport-Security")
            #expect(header == "max-age=86400")
        }

        @Test("includeSubDomains directive")
        func includeSubDomains() async throws {
            let middleware = PrismHSTSMiddleware(includeSubDomains: true)
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            let header = response.headers.value(for: "Strict-Transport-Security")!
            #expect(header.contains("includeSubDomains"))
        }

        @Test("Without includeSubDomains")
        func withoutIncludeSubDomains() async throws {
            let middleware = PrismHSTSMiddleware(includeSubDomains: false)
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            let header = response.headers.value(for: "Strict-Transport-Security")!
            #expect(!header.contains("includeSubDomains"))
        }

        @Test("Preload directive")
        func preloadEnabled() async throws {
            let middleware = PrismHSTSMiddleware(preload: true)
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            let header = response.headers.value(for: "Strict-Transport-Security")!
            #expect(header.contains("preload"))
        }

        @Test("Without preload")
        func preloadDisabled() async throws {
            let middleware = PrismHSTSMiddleware(preload: false)
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            let header = response.headers.value(for: "Strict-Transport-Security")!
            #expect(!header.contains("preload"))
        }

        @Test("Full HSTS header with all directives")
        func allDirectives() async throws {
            let middleware = PrismHSTSMiddleware(maxAge: 63_072_000, includeSubDomains: true, preload: true)
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            let header = response.headers.value(for: "Strict-Transport-Security")
            #expect(header == "max-age=63072000; includeSubDomains; preload")
        }

        @Test("HSTS header added to POST responses")
        func postRequest() async throws {
            let middleware = PrismHSTSMiddleware()
            let request = PrismHTTPRequest(method: .POST, uri: "/submit")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.headers.value(for: "Strict-Transport-Security") != nil)
        }
    }

    @Suite("PrismSecurityHeadersMiddleware Tests")
    struct PrismSecurityHeadersMiddlewareTests {

        @Test("Adds X-Content-Type-Options header")
        func contentTypeOptions() async throws {
            let middleware = PrismSecurityHeadersMiddleware()
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.headers.value(for: "X-Content-Type-Options") == "nosniff")
        }

        @Test("Adds X-Frame-Options header")
        func frameOptions() async throws {
            let middleware = PrismSecurityHeadersMiddleware()
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.headers.value(for: "X-Frame-Options") == "DENY")
        }

        @Test("Adds X-XSS-Protection header")
        func xssProtection() async throws {
            let middleware = PrismSecurityHeadersMiddleware()
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.headers.value(for: "X-XSS-Protection") == "1; mode=block")
        }

        @Test("Adds Referrer-Policy header")
        func referrerPolicy() async throws {
            let middleware = PrismSecurityHeadersMiddleware()
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.headers.value(for: "Referrer-Policy") == "strict-origin-when-cross-origin")
        }

        @Test("All security headers present in single response")
        func allHeadersPresent() async throws {
            let middleware = PrismSecurityHeadersMiddleware()
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.headers.value(for: "X-Content-Type-Options") != nil)
            #expect(response.headers.value(for: "X-Frame-Options") != nil)
            #expect(response.headers.value(for: "X-XSS-Protection") != nil)
            #expect(response.headers.value(for: "Referrer-Policy") != nil)
        }

        @Test("Security headers added to POST responses")
        func postRequest() async throws {
            let middleware = PrismSecurityHeadersMiddleware()
            let request = PrismHTTPRequest(method: .POST, uri: "/submit")
            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.headers.value(for: "X-Content-Type-Options") == "nosniff")
            #expect(response.headers.value(for: "X-Frame-Options") == "DENY")
        }

        @Test("Does not overwrite response body")
        func preservesBody() async throws {
            let middleware = PrismSecurityHeadersMiddleware()
            let request = PrismHTTPRequest(method: .GET, uri: "/")
            let response = try await middleware.handle(request) { _ in .text("hello world") }
            #expect(response.status == .ok)
        }
    }
#endif
