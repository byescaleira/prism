import Foundation
import Testing

@testable import PrismServer

@Suite("PrismAPIVersion Tests")
struct PrismAPIVersionTests {

    @Test("Parse v1")
    func parseV1() {
        let version = PrismAPIVersion.parse("v1")
        #expect(version?.major == 1)
        #expect(version?.minor == 0)
    }

    @Test("Parse v2.3")
    func parseV2_3() {
        let version = PrismAPIVersion.parse("v2.3")
        #expect(version?.major == 2)
        #expect(version?.minor == 3)
    }

    @Test("Parse without v prefix")
    func parseNoPrefix() {
        let version = PrismAPIVersion.parse("1")
        #expect(version?.major == 1)
        #expect(version?.minor == 0)
    }

    @Test("Parse with minor no prefix")
    func parseMinorNoPrefix() {
        let version = PrismAPIVersion.parse("3.1")
        #expect(version?.major == 3)
        #expect(version?.minor == 1)
    }

    @Test("Comparison")
    func comparison() {
        let v1 = PrismAPIVersion(major: 1)
        let v2 = PrismAPIVersion(major: 2)
        let v1_1 = PrismAPIVersion(major: 1, minor: 1)
        #expect(v1 < v2)
        #expect(v1 < v1_1)
        #expect(v2 > v1_1)
    }

    @Test("Description")
    func description() {
        #expect(PrismAPIVersion(major: 1).description == "v1")
        #expect(PrismAPIVersion(major: 2, minor: 3).description == "v2.3")
    }

    @Test("Equality")
    func equality() {
        let a = PrismAPIVersion(major: 1, minor: 0)
        let b = PrismAPIVersion.parse("v1")
        #expect(a == b)
    }

    @Test("Parse invalid returns nil")
    func parseInvalid() {
        #expect(PrismAPIVersion.parse("abc") == nil)
    }
}

@Suite("PrismVersioningMiddleware Tests")
struct PrismVersioningMiddlewareTests {

    @Test("Header strategy extracts version")
    func headerStrategy() async throws {
        let middleware = PrismVersioningMiddleware(
            strategy: .header("Accept-Version"),
            supportedVersions: [PrismAPIVersion(major: 1), PrismAPIVersion(major: 2)],
            defaultVersion: PrismAPIVersion(major: 1)
        )
        var request = PrismHTTPRequest(method: .GET, uri: "/users")
        request.headers.set(name: "Accept-Version", value: "v2")

        let response = try await middleware.handle(request) { req in
            let version = req.apiVersion
            return .text("version: \(version?.description ?? "none")")
        }
        #expect(response.status == .ok)
    }

    @Test("Returns 400 for unsupported version")
    func unsupportedVersion() async throws {
        let middleware = PrismVersioningMiddleware(
            strategy: .header("Accept-Version"),
            supportedVersions: [PrismAPIVersion(major: 1)],
            defaultVersion: PrismAPIVersion(major: 1)
        )
        var request = PrismHTTPRequest(method: .GET, uri: "/users")
        request.headers.set(name: "Accept-Version", value: "v99")

        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .badRequest)
    }

    @Test("Uses default version when missing")
    func defaultVersion() async throws {
        let middleware = PrismVersioningMiddleware(
            strategy: .header("Accept-Version"),
            supportedVersions: [PrismAPIVersion(major: 1)],
            defaultVersion: PrismAPIVersion(major: 1)
        )
        let request = PrismHTTPRequest(method: .GET, uri: "/users")
        let response = try await middleware.handle(request) { req in
            let version = req.apiVersion
            return .text("version: \(version?.description ?? "none")")
        }
        #expect(response.status == .ok)
    }

    @Test("URL prefix strategy extracts version")
    func urlPrefixStrategy() async throws {
        let middleware = PrismVersioningMiddleware(
            strategy: .urlPrefix,
            supportedVersions: [PrismAPIVersion(major: 1), PrismAPIVersion(major: 2)],
            defaultVersion: PrismAPIVersion(major: 1)
        )
        let request = PrismHTTPRequest(method: .GET, uri: "/v2/users")
        let response = try await middleware.handle(request) { req in
            let version = req.apiVersion
            return .text("version: \(version?.description ?? "none")")
        }
        #expect(response.status == .ok)
    }

    @Test("Query param strategy extracts version")
    func queryParamStrategy() async throws {
        let middleware = PrismVersioningMiddleware(
            strategy: .queryParam("version"),
            supportedVersions: [PrismAPIVersion(major: 1)],
            defaultVersion: PrismAPIVersion(major: 1)
        )
        let request = PrismHTTPRequest(method: .GET, uri: "/users?version=v1")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }
}

@Suite("PrismVersionedRouter Tests")
struct PrismVersionedRouterTests {

    @Test("Routes to correct version handler")
    func routeByVersion() async throws {
        var router = PrismVersionedRouter()
        router.route(version: PrismAPIVersion(major: 1), .GET, "/users") { _ in .text("v1 users") }
        router.route(version: PrismAPIVersion(major: 2), .GET, "/users") { _ in .text("v2 users") }

        var request = PrismHTTPRequest(method: .GET, uri: "/users")
        request.userInfo["apiVersion"] = "v2"
        let response = try await router.handle(request)
        #expect(response != nil)
    }

    @Test("Returns nil for no matching route")
    func noMatch() async throws {
        let router = PrismVersionedRouter()
        let request = PrismHTTPRequest(method: .GET, uri: "/missing")
        let response = try await router.handle(request)
        #expect(response == nil)
    }
}
