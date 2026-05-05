import Foundation
import Testing

@testable import PrismServer

@Suite("PrismHTTPRequest Tests")
struct PrismHTTPRequestTests {

    @Test("Path and query parsing from URI")
    func pathAndQuery() {
        let req = PrismHTTPRequest(method: .GET, uri: "/users?page=2&limit=10")
        #expect(req.path == "/users")
        #expect(req.query("page") == "2")
        #expect(req.query("limit") == "10")
    }

    @Test("URI without query string")
    func noQuery() {
        let req = PrismHTTPRequest(method: .GET, uri: "/health")
        #expect(req.path == "/health")
        #expect(req.queryParameters.isEmpty)
    }

    @Test("Query parameter with percent encoding")
    func percentEncoding() {
        let req = PrismHTTPRequest(method: .GET, uri: "/search?q=hello%20world")
        #expect(req.query("q") == "hello world")
    }

    @Test("Route parameters")
    func routeParameters() {
        var req = PrismHTTPRequest(method: .GET, uri: "/users/42")
        req.parameters = ["id": "42"]
        #expect(req.parameter("id") == "42")
        #expect(req.parameter("missing") == nil)
    }

    @Test("Content-Type header")
    func contentType() {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/json")
        let req = PrismHTTPRequest(method: .POST, uri: "/data", headers: headers)
        #expect(req.contentType == "application/json")
    }

    @Test("Content-Length header")
    func contentLength() {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Length", value: "42")
        let req = PrismHTTPRequest(method: .POST, uri: "/data", headers: headers)
        #expect(req.contentLength == 42)
    }

    @Test("Body string")
    func bodyString() {
        let body = Data("Hello, World!".utf8)
        let req = PrismHTTPRequest(method: .POST, uri: "/echo", body: body)
        #expect(req.bodyString == "Hello, World!")
    }

    @Test("UserInfo storage")
    func userInfo() {
        var req = PrismHTTPRequest(method: .GET, uri: "/")
        req.userInfo["userID"] = "123"
        #expect(req.userInfo["userID"] == "123")
    }

    @Test("Query parameter without value")
    func queryNoValue() {
        let req = PrismHTTPRequest(method: .GET, uri: "/search?verbose")
        #expect(req.query("verbose") == "")
    }
}
