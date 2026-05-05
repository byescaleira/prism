import Foundation
import Testing

@testable import PrismServer

private struct TestItem: Codable, Sendable {
    let name: String
}

@Suite("PrismClientRequest Tests")
struct PrismClientRequestTests {

    @Test("Stores url, method, headers, body")
    func storesProperties() {
        let body = Data("test".utf8)
        let req = PrismClientRequest(
            url: "https://api.test.com/users", method: "POST", headers: ["Auth": "Bearer x"], body: body)
        #expect(req.url == "https://api.test.com/users")
        #expect(req.method == "POST")
        #expect(req.headers["Auth"] == "Bearer x")
        #expect(req.body == body)
    }

    @Test("Default method is GET")
    func defaultMethod() {
        let req = PrismClientRequest(url: "https://test.com")
        #expect(req.method == "GET")
        #expect(req.headers.isEmpty)
        #expect(req.body == nil)
    }

    @Test("Custom timeout")
    func customTimeout() {
        let req = PrismClientRequest(url: "https://test.com", timeout: 60)
        #expect(req.timeout == 60)
    }
}

@Suite("PrismClientResponse Tests")
struct PrismClientResponseTests {

    @Test("Text property decodes body as UTF-8")
    func textProperty() {
        let resp = PrismClientResponse(statusCode: 200, headers: [:], body: Data("hello world".utf8))
        #expect(resp.text == "hello world")
    }

    @Test("Text returns nil for nil body")
    func textNilBody() {
        let resp = PrismClientResponse(statusCode: 200, headers: [:], body: nil)
        #expect(resp.text == nil)
    }

    @Test("json() decodes body")
    func jsonDecode() throws {
        let json = #"{"name":"test"}"#
        let resp = PrismClientResponse(statusCode: 200, headers: [:], body: Data(json.utf8))
        let item = try resp.json(TestItem.self)
        #expect(item.name == "test")
    }

    @Test("json() throws for nil body")
    func jsonNilBody() {
        let resp = PrismClientResponse(statusCode: 200, headers: [:], body: nil)
        #expect(throws: PrismHTTPClientError.self) {
            try resp.json(TestItem.self)
        }
    }
}

@Suite("PrismHTTPClientConfig Tests")
struct PrismHTTPClientConfigTests {

    @Test("Default values")
    func defaults() {
        let config = PrismHTTPClientConfig()
        #expect(config.baseURL == nil)
        #expect(config.defaultHeaders.isEmpty)
        #expect(config.timeout == 30)
        #expect(config.retryCount == 0)
    }

    @Test("Custom values")
    func custom() {
        let config = PrismHTTPClientConfig(
            baseURL: "https://api.test.com",
            defaultHeaders: ["X-Api-Key": "abc"],
            timeout: 60,
            retryCount: 3,
            retryDelay: .seconds(2)
        )
        #expect(config.baseURL == "https://api.test.com")
        #expect(config.defaultHeaders["X-Api-Key"] == "abc")
        #expect(config.timeout == 60)
        #expect(config.retryCount == 3)
    }
}

@Suite("PrismHTTPClient Tests")
struct PrismHTTPClientTests {

    @Test("Init with default config")
    func initDefault() {
        let client = PrismHTTPClient()
        _ = client  // compiles and initializes
    }

    @Test("Init with custom config")
    func initCustom() {
        let config = PrismHTTPClientConfig(baseURL: "https://api.test.com", timeout: 10)
        let client = PrismHTTPClient(config: config)
        _ = client
    }
}
