import Foundation
import Testing

@testable import PrismServer

@Suite("PrismCSRFConfig Tests")
struct PrismCSRFConfigTests {

    @Test("Default configuration values")
    func defaults() {
        let config = PrismCSRFConfig()
        #expect(config.tokenLength == 32)
        #expect(config.cookieName == "_csrf")
        #expect(config.headerName == "X-CSRF-Token")
        #expect(config.formFieldName == "_token")
        #expect(config.safeMethods == Set([PrismHTTPMethod.GET, .HEAD, .OPTIONS]))
        #expect(config.secureCookie == true)
        #expect(config.cookiePath == "/")
    }

    @Test("Custom configuration values")
    func custom() {
        let config = PrismCSRFConfig(
            tokenLength: 64,
            cookieName: "my_csrf",
            headerName: "X-My-CSRF",
            formFieldName: "csrf_field",
            safeMethods: [.GET],
            secureCookie: false,
            cookiePath: "/app"
        )
        #expect(config.tokenLength == 64)
        #expect(config.cookieName == "my_csrf")
        #expect(config.headerName == "X-My-CSRF")
        #expect(config.formFieldName == "csrf_field")
        #expect(config.safeMethods == Set([PrismHTTPMethod.GET]))
        #expect(config.secureCookie == false)
        #expect(config.cookiePath == "/app")
    }
}

@Suite("PrismCSRFMiddleware Tests")
struct PrismCSRFMiddlewareTests {

    private func extractSetCookieValue(from response: PrismHTTPResponse, named cookieName: String) -> String? {
        let headers = response.headers.values(for: "Set-Cookie")
        for header in headers {
            if header.hasPrefix("\(cookieName)=") {
                let value = header.split(separator: ";").first.map(String.init) ?? ""
                return String(value.dropFirst(cookieName.count + 1))
            }
        }
        return nil
    }

    private func makeRequestWithCSRFCookie(
        method: PrismHTTPMethod, token: String, config: PrismCSRFConfig = PrismCSRFConfig()
    ) -> PrismHTTPRequest {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Cookie", value: "\(config.cookieName)=\(token)")
        return PrismHTTPRequest(method: method, uri: "/submit", headers: headers)
    }

    @Test("GET request generates CSRF token cookie")
    func getGeneratesCookie() async throws {
        let middleware = PrismCSRFMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/form")
        let response = try await middleware.handle(request) { _ in .text("ok") }

        let cookieValue = extractSetCookieValue(from: response, named: "_csrf")
        #expect(cookieValue != nil)
        #expect(!cookieValue!.isEmpty)
    }

    @Test("GET request stores token in userInfo")
    func getStoresUserInfo() async throws {
        let middleware = PrismCSRFMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/form")
        _ = try await middleware.handle(request) { req in
            #expect(req.userInfo["csrfToken"] != nil)
            #expect(!req.userInfo["csrfToken"]!.isEmpty)
            return .text("ok")
        }
    }

    @Test("POST without token returns 403")
    func postWithoutToken() async throws {
        let middleware = PrismCSRFMiddleware()
        let request = PrismHTTPRequest(method: .POST, uri: "/submit")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status.code == 403)
    }

    @Test("POST with valid header token passes")
    func postWithValidHeaderToken() async throws {
        let token = "test-csrf-token-abc123"
        let middleware = PrismCSRFMiddleware()
        var request = makeRequestWithCSRFCookie(method: .POST, token: token)
        request.headers.set(name: "X-CSRF-Token", value: token)

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("POST with valid form body token passes")
    func postWithValidFormToken() async throws {
        let token = "test-csrf-token-form456"
        let middleware = PrismCSRFMiddleware()
        var request = makeRequestWithCSRFCookie(method: .POST, token: token)
        request.body = "_token=\(token)".data(using: .utf8)

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("POST with mismatched token returns 403")
    func postMismatchedToken() async throws {
        let middleware = PrismCSRFMiddleware()
        var request = makeRequestWithCSRFCookie(method: .POST, token: "correct-token")
        request.headers.set(name: "X-CSRF-Token", value: "wrong-token")

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status.code == 403)
    }

    @Test("HEAD request is treated as safe method")
    func headIsSafe() async throws {
        let middleware = PrismCSRFMiddleware()
        let request = PrismHTTPRequest(method: .HEAD, uri: "/resource")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("OPTIONS request is treated as safe method")
    func optionsIsSafe() async throws {
        let middleware = PrismCSRFMiddleware()
        let request = PrismHTTPRequest(method: .OPTIONS, uri: "/resource")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("Custom config with different cookie and header names")
    func customConfig() async throws {
        let config = PrismCSRFConfig(cookieName: "my_csrf", headerName: "X-My-Token")
        let token = "custom-token-xyz"
        let middleware = PrismCSRFMiddleware(config: config)

        var headers = PrismHTTPHeaders()
        headers.set(name: "Cookie", value: "my_csrf=\(token)")
        headers.set(name: "X-My-Token", value: token)
        let request = PrismHTTPRequest(method: .POST, uri: "/submit", headers: headers)

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("Generated token is base64url encoded")
    func tokenIsBase64URL() async throws {
        let middleware = PrismCSRFMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/form")
        let response = try await middleware.handle(request) { _ in .text("ok") }

        let token = extractSetCookieValue(from: response, named: "_csrf")!
        #expect(!token.contains("+"))
        #expect(!token.contains("/"))
        #expect(!token.contains("="))
        #expect(!token.isEmpty)
    }

    @Test("Existing cookie token is preserved")
    func existingCookiePreserved() async throws {
        let existingToken = "already-set-token"
        let middleware = PrismCSRFMiddleware()
        var headers = PrismHTTPHeaders()
        headers.set(name: "Cookie", value: "_csrf=\(existingToken)")
        let request = PrismHTTPRequest(method: .GET, uri: "/form", headers: headers)

        let response = try await middleware.handle(request) { req in
            #expect(req.userInfo["csrfToken"] == existingToken)
            return .text("ok")
        }

        let newCookie = extractSetCookieValue(from: response, named: "_csrf")
        #expect(newCookie == nil)
    }

    @Test("POST stores token in userInfo on success")
    func postStoresUserInfo() async throws {
        let token = "valid-token-for-userinfo"
        let middleware = PrismCSRFMiddleware()
        var request = makeRequestWithCSRFCookie(method: .POST, token: token)
        request.headers.set(name: "X-CSRF-Token", value: token)

        _ = try await middleware.handle(request) { req in
            #expect(req.userInfo["csrfToken"] == token)
            return .text("ok")
        }
    }

    @Test("PUT request requires CSRF validation")
    func putRequiresValidation() async throws {
        let middleware = PrismCSRFMiddleware()
        let request = PrismHTTPRequest(method: .PUT, uri: "/update")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status.code == 403)
    }

    @Test("DELETE request requires CSRF validation")
    func deleteRequiresValidation() async throws {
        let middleware = PrismCSRFMiddleware()
        let request = PrismHTTPRequest(method: .DELETE, uri: "/remove")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status.code == 403)
    }

    @Test("PATCH request requires CSRF validation")
    func patchRequiresValidation() async throws {
        let middleware = PrismCSRFMiddleware()
        let request = PrismHTTPRequest(method: .PATCH, uri: "/patch")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status.code == 403)
    }
}
