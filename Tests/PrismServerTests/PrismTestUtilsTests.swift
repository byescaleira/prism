import Foundation
import Testing

@testable import PrismServer

private struct TestPayload: Codable, Sendable {
    let id: Int
    let name: String
}

@Suite("PrismRequestBuilder Tests")
struct PrismRequestBuilderTests {

    @Test("GET creates GET request")
    func getRequest() {
        let req = PrismRequestBuilder.get("/users").build()
        #expect(req.method == .GET)
        #expect(req.path == "/users")
    }

    @Test("POST creates POST request")
    func postRequest() {
        let req = PrismRequestBuilder.post("/users").build()
        #expect(req.method == .POST)
        #expect(req.path == "/users")
    }

    @Test("Header adds header")
    func header() {
        let req = PrismRequestBuilder.get("/test")
            .header("Authorization", "Bearer token")
            .build()
        #expect(req.headers.value(for: "Authorization") == "Bearer token")
    }

    @Test("Body sets body data")
    func bodyData() {
        let data = Data("hello".utf8)
        let req = PrismRequestBuilder.post("/test")
            .body(data)
            .build()
        #expect(req.body == data)
    }

    @Test("jsonBody encodes and sets content type")
    func jsonBody() {
        let payload = TestPayload(id: 1, name: "test")
        let req = PrismRequestBuilder.post("/test")
            .jsonBody(payload)
            .build()
        #expect(req.headers.value(for: "Content-Type") == "application/json")
        #expect(req.body != nil)
        let decoded = try? JSONDecoder().decode(TestPayload.self, from: req.body!)
        #expect(decoded?.name == "test")
    }

    @Test("Chaining multiple builders")
    func chaining() {
        let req = PrismRequestBuilder.put("/items/1")
            .header("Accept", "application/json")
            .header("X-Custom", "value")
            .body(Data("data".utf8))
            .build()
        #expect(req.method == .PUT)
        #expect(req.headers.value(for: "Accept") == "application/json")
        #expect(req.headers.value(for: "X-Custom") == "value")
    }
}

@Suite("PrismAssertResponse Tests")
struct PrismAssertResponseTests {

    @Test("assertStatus returns self on match")
    func assertStatusMatch() {
        let response = PrismHTTPResponse(status: .ok, body: .text("ok"))
        let assert = PrismAssertResponse(response)
        let result = assert.assertStatus(.ok)
        #expect(result.response.status == .ok)
    }

    @Test("bodyString returns text body")
    func bodyStringText() {
        let response = PrismHTTPResponse(status: .ok, body: .text("hello"))
        let assert = PrismAssertResponse(response)
        #expect(assert.bodyString == "hello")
    }

    @Test("bodyString returns data body as string")
    func bodyStringData() {
        let response = PrismHTTPResponse(status: .ok, body: .data(Data("data body".utf8)))
        let assert = PrismAssertResponse(response)
        #expect(assert.bodyString == "data body")
    }

    @Test("bodyString returns nil for empty")
    func bodyStringEmpty() {
        let response = PrismHTTPResponse(status: .ok, body: .empty)
        let assert = PrismAssertResponse(response)
        #expect(assert.bodyString == nil)
    }

    @Test("assertBodyContains returns self when body contains substring")
    func assertBodyContains() {
        let response = PrismHTTPResponse(status: .ok, body: .text("hello world"))
        let assert = PrismAssertResponse(response)
        let result = assert.assertBodyContains("world")
        #expect(result.response.status == .ok)
    }

    @Test("assertJSON decodes body")
    func assertJSON() throws {
        let json = #"{"id":1,"name":"test"}"#
        let response = PrismHTTPResponse(status: .ok, body: .data(Data(json.utf8)))
        let assert = PrismAssertResponse(response)
        let payload = try assert.assertJSON(TestPayload.self)
        #expect(payload.id == 1)
        #expect(payload.name == "test")
    }

    @Test("assertHeader returns self on match")
    func assertHeader() {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/json")
        let response = PrismHTTPResponse(status: .ok, headers: headers, body: .empty)
        let assert = PrismAssertResponse(response)
        let result = assert.assertHeader("Content-Type", "application/json")
        #expect(result.response.status == .ok)
    }
}
