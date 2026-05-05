import Foundation
import Testing

@testable import PrismServer

@Suite("PrismHookRegistry Tests")
struct PrismHookRegistryTests {

    @Test("Runs request hooks")
    func requestHooks() async throws {
        let registry = PrismHookRegistry()
        await registry.onRequest { req in
            var modified = req
            modified.userInfo["hooked"] = "true"
            return modified
        }
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let result = try await registry.runRequestHooks(request)
        #expect(result.userInfo["hooked"] == "true")
    }

    @Test("Runs multiple request hooks in order")
    func multipleRequestHooks() async throws {
        let registry = PrismHookRegistry()
        await registry.onRequest { req in
            var modified = req
            modified.userInfo["step"] = "1"
            return modified
        }
        await registry.onRequest { req in
            var modified = req
            modified.userInfo["step"] = (modified.userInfo["step"] ?? "") + ",2"
            return modified
        }
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let result = try await registry.runRequestHooks(request)
        #expect(result.userInfo["step"] == "1,2")
    }

    @Test("Runs response hooks")
    func responseHooks() async throws {
        let registry = PrismHookRegistry()
        await registry.onResponse { _, response in
            var modified = response
            modified.headers.set(name: "X-Hooked", value: "yes")
            return modified
        }
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = PrismHTTPResponse.text("ok")
        let result = try await registry.runResponseHooks(request, response: response)
        #expect(result.headers.value(for: "X-Hooked") == "yes")
    }

    @Test("Error hook returns custom response")
    func errorHookReturns() async {
        let registry = PrismHookRegistry()
        await registry.onError { _, _ in
            .text("handled")
        }
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let result = await registry.runErrorHooks(NSError(domain: "test", code: 1), request: request)
        #expect(result != nil)
    }

    @Test("Error hook returns nil when not handling")
    func errorHookNil() async {
        let registry = PrismHookRegistry()
        await registry.onError { _, _ in nil }
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let result = await registry.runErrorHooks(NSError(domain: "test", code: 1), request: request)
        #expect(result == nil)
    }

    @Test("Hook counts track registrations")
    func hookCounts() async {
        let registry = PrismHookRegistry()
        #expect(await registry.requestHookCount == 0)
        await registry.onRequest { $0 }
        await registry.onResponse { _, resp in resp }
        await registry.onError { _, _ in nil }
        #expect(await registry.requestHookCount == 1)
        #expect(await registry.responseHookCount == 1)
        #expect(await registry.errorHookCount == 1)
    }
}

@Suite("PrismHooksMiddleware Tests")
struct PrismHooksMiddlewareTests {

    @Test("Passes through normally")
    func passThrough() async throws {
        let registry = PrismHookRegistry()
        let middleware = PrismHooksMiddleware(registry: registry)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("Applies request hooks before handler")
    func requestHooksBeforeHandler() async throws {
        let registry = PrismHookRegistry()
        await registry.onRequest { req in
            var modified = req
            modified.userInfo["injected"] = "value"
            return modified
        }
        let middleware = PrismHooksMiddleware(registry: registry)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { req in
            let injected = req.userInfo["injected"] ?? "missing"
            return .text(injected)
        }
        let bodyData = response.serialize()
        let bodyStr = String(data: bodyData, encoding: .utf8) ?? ""
        #expect(bodyStr.contains("value"))
    }

    @Test("Applies response hooks after handler")
    func responseHooksAfterHandler() async throws {
        let registry = PrismHookRegistry()
        await registry.onResponse { _, response in
            var modified = response
            modified.headers.set(name: "X-After", value: "done")
            return modified
        }
        let middleware = PrismHooksMiddleware(registry: registry)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-After") == "done")
    }

    @Test("Error hooks catch errors")
    func errorHooksCatch() async throws {
        let registry = PrismHookRegistry()
        await registry.onError { _, _ in
            .text("error handled")
        }
        let middleware = PrismHooksMiddleware(registry: registry)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in
            throw NSError(domain: "test", code: 1)
        }
        let bodyData = response.serialize()
        let bodyStr = String(data: bodyData, encoding: .utf8) ?? ""
        #expect(bodyStr.contains("error handled"))
    }
}
