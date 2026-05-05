import Foundation
import Testing

@testable import PrismServer

@Suite("PrismRequestTimeout Tests")
struct PrismRequestTimeoutTests {

    @Test("Fast request completes normally")
    func fastRequest() async throws {
        let middleware = PrismRequestTimeoutMiddleware(timeout: .seconds(5))
        let request = PrismHTTPRequest(method: .GET, uri: "/fast")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("quick response")
        }

        #expect(response.status == .ok)
        #expect(String(data: response.body.data, encoding: .utf8) == "quick response")
    }

    @Test("Slow request returns 408")
    func slowRequest408() async throws {
        let middleware = PrismRequestTimeoutMiddleware(timeout: .milliseconds(50))
        let request = PrismHTTPRequest(method: .GET, uri: "/slow")

        let response = try await middleware.handle(request) { _ in
            try await Task.sleep(for: .milliseconds(500))
            return PrismHTTPResponse.text("too slow")
        }

        #expect(response.status == .requestTimeout)
    }

    @Test("Timeout config with path-specific timeout")
    func pathSpecificTimeout() async throws {
        let config = PrismRequestTimeoutConfig(
            defaultTimeout: .milliseconds(50),
            timeoutByPath: ["/upload": .seconds(60)]
        )
        let middleware = PrismRequestTimeoutMiddleware(config: config)
        let request = PrismHTTPRequest(method: .POST, uri: "/upload/large")

        let response = try await middleware.handle(request) { _ in
            try await Task.sleep(for: .milliseconds(100))
            return PrismHTTPResponse.text("uploaded")
        }

        #expect(response.status == .ok)
    }

    @Test("Method-specific timeout")
    func methodSpecificTimeout() async throws {
        let config = PrismRequestTimeoutConfig(
            defaultTimeout: .milliseconds(50),
            timeoutByMethod: [.POST: .seconds(5)]
        )
        let middleware = PrismRequestTimeoutMiddleware(config: config)
        let request = PrismHTTPRequest(method: .POST, uri: "/data")

        let response = try await middleware.handle(request) { _ in
            try await Task.sleep(for: .milliseconds(100))
            return PrismHTTPResponse.text("posted")
        }

        #expect(response.status == .ok)
    }

    @Test("UserInfo timeout override")
    func userInfoOverride() async throws {
        let config = PrismRequestTimeoutConfig(defaultTimeout: .milliseconds(50))
        let middleware = PrismRequestTimeoutMiddleware(config: config)
        var request = PrismHTTPRequest(method: .GET, uri: "/custom")
        request.userInfo["timeout"] = "5.0"

        let response = try await middleware.handle(request) { _ in
            try await Task.sleep(for: .milliseconds(100))
            return PrismHTTPResponse.text("custom timeout")
        }

        #expect(response.status == .ok)
    }

    @Test("Timeout response body contains message")
    func timeoutResponseBody() async throws {
        let middleware = PrismRequestTimeoutMiddleware(timeout: .milliseconds(50))
        let request = PrismHTTPRequest(method: .GET, uri: "/slow")

        let response = try await middleware.handle(request) { _ in
            try await Task.sleep(for: .seconds(5))
            return PrismHTTPResponse.text("never")
        }

        let body = String(data: response.body.data, encoding: .utf8) ?? ""
        #expect(body.contains("timed out"))
    }

    @Test("Default timeout config uses 30 seconds")
    func defaultConfig() {
        let config = PrismRequestTimeoutConfig()
        #expect(config.defaultTimeout == .seconds(30))
    }

    @Test("Multiple concurrent requests each get timeout")
    func concurrentTimeouts() async throws {
        let middleware = PrismRequestTimeoutMiddleware(timeout: .seconds(5))

        async let r1 = middleware.handle(PrismHTTPRequest(method: .GET, uri: "/a")) { _ in
            PrismHTTPResponse.text("a")
        }
        async let r2 = middleware.handle(PrismHTTPRequest(method: .GET, uri: "/b")) { _ in
            PrismHTTPResponse.text("b")
        }

        let (res1, res2) = try await (r1, r2)
        #expect(res1.status == .ok)
        #expect(res2.status == .ok)
    }

    @Test("Timeout error type")
    func timeoutErrorType() {
        let error = PrismTimeoutError.requestTimedOut(timeout: .seconds(30))
        switch error {
        case .requestTimedOut(let timeout):
            #expect(timeout == .seconds(30))
        }
    }

    @Test("Config preserves all parameters")
    func configParameters() {
        let config = PrismRequestTimeoutConfig(
            defaultTimeout: .seconds(10),
            timeoutByPath: ["/api": .seconds(5)],
            timeoutByMethod: [.POST: .seconds(60)]
        )
        #expect(config.defaultTimeout == .seconds(10))
        #expect(config.timeoutByPath["/api"] == .seconds(5))
        #expect(config.timeoutByMethod[.POST] == .seconds(60))
    }

    @Test("Convenience init with Duration")
    func convenienceInit() async throws {
        let middleware = PrismRequestTimeoutMiddleware(timeout: .seconds(10))
        let request = PrismHTTPRequest(method: .GET, uri: "/test")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        #expect(response.status == .ok)
    }

    @Test("Path timeout takes priority over method timeout")
    func pathOverMethod() async throws {
        let config = PrismRequestTimeoutConfig(
            defaultTimeout: .milliseconds(50),
            timeoutByPath: ["/upload": .seconds(5)],
            timeoutByMethod: [.POST: .milliseconds(50)]
        )
        let middleware = PrismRequestTimeoutMiddleware(config: config)
        let request = PrismHTTPRequest(method: .POST, uri: "/upload/file")

        let response = try await middleware.handle(request) { _ in
            try await Task.sleep(for: .milliseconds(100))
            return PrismHTTPResponse.text("uploaded")
        }

        #expect(response.status == .ok)
    }

    @Test("Request that throws error propagates through timeout")
    func errorPropagation() async throws {
        let middleware = PrismRequestTimeoutMiddleware(timeout: .seconds(5))
        let request = PrismHTTPRequest(method: .GET, uri: "/error")

        do {
            _ = try await middleware.handle(request) { _ in
                throw PrismMultipartStreamError.invalidBoundary
            }
            #expect(Bool(false), "Should have thrown")
        } catch {
            #expect(error is PrismMultipartStreamError)
        }
    }

    @Test("Empty path overrides map does not affect default")
    func emptyOverrides() async throws {
        let config = PrismRequestTimeoutConfig(
            defaultTimeout: .seconds(5),
            timeoutByPath: [:],
            timeoutByMethod: [:]
        )
        let middleware = PrismRequestTimeoutMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        #expect(response.status == .ok)
    }

    @Test("Status code 408 for timeout")
    func statusCode408() {
        #expect(PrismHTTPStatus.requestTimeout.code == 408)
        #expect(PrismHTTPStatus.requestTimeout.reason == "Request Timeout")
    }
}
