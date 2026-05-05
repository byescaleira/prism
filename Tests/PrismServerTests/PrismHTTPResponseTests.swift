import Foundation
import Testing

@testable import PrismServer

@Suite("PrismHTTPResponse Tests")
struct PrismHTTPResponseTests {

    @Test("JSON response factory")
    func jsonResponse() {
        struct User: Codable { let name: String }
        let response = PrismHTTPResponse.json(User(name: "Alice"))
        #expect(response.status == .ok)
        #expect(response.headers.value(for: "Content-Type") == "application/json; charset=utf-8")
        #expect(!response.body.isEmpty)
    }

    @Test("Text response factory")
    func textResponse() {
        let response = PrismHTTPResponse.text("Hello")
        #expect(response.status == .ok)
        #expect(response.headers.value(for: "Content-Type") == "text/plain; charset=utf-8")
        #expect(response.body.data == Data("Hello".utf8))
    }

    @Test("HTML response factory")
    func htmlResponse() {
        let response = PrismHTTPResponse.html("<h1>Hello</h1>")
        #expect(response.headers.value(for: "Content-Type") == "text/html; charset=utf-8")
    }

    @Test("Redirect response")
    func redirectResponse() {
        let response = PrismHTTPResponse.redirect(to: "/login")
        #expect(response.status == .temporaryRedirect)
        #expect(response.headers.value(for: "Location") == "/login")
    }

    @Test("Permanent redirect")
    func permanentRedirect() {
        let response = PrismHTTPResponse.redirect(to: "/new-url", permanent: true)
        #expect(response.status == .movedPermanently)
    }

    @Test("No content response")
    func noContentResponse() {
        let response = PrismHTTPResponse.noContent
        #expect(response.status == .noContent)
        #expect(response.body.isEmpty)
    }

    @Test("Serialize response")
    func serialize() {
        let response = PrismHTTPResponse.text("OK")
        let data = response.serialize()
        let string = String(data: data, encoding: .utf8)!
        #expect(string.contains("HTTP/1.1 200 OK"))
        #expect(string.contains("Content-Type: text/plain"))
        #expect(string.contains("OK"))
    }

    @Test("Serialize includes Server header")
    func serializeServerHeader() {
        let response = PrismHTTPResponse(status: .ok)
        let string = String(data: response.serialize(), encoding: .utf8)!
        #expect(string.contains("Server: PrismServer"))
    }

    @Test("JSON encoding error returns 500")
    func jsonEncodingError() {
        let response = PrismHTTPResponse.json(Double.infinity)
        #expect(response.status == .internalServerError)
    }

    @Test("JSON response with custom status")
    func jsonCustomStatus() {
        let response = PrismHTTPResponse.json(["id": 1], status: .created)
        #expect(response.status == .created)
    }
}

@Suite("PrismHTTPBody Tests")
struct PrismHTTPBodyTests {

    @Test("Empty body")
    func emptyBody() {
        let body = PrismHTTPBody.empty
        #expect(body.isEmpty)
        #expect(body.data.isEmpty)
    }

    @Test("Data body")
    func dataBody() {
        let data = Data("test".utf8)
        let body = PrismHTTPBody.data(data)
        #expect(!body.isEmpty)
        #expect(body.data == data)
    }

    @Test("Text body")
    func textBody() {
        let body = PrismHTTPBody.text("hello")
        #expect(!body.isEmpty)
        #expect(body.data == Data("hello".utf8))
    }
}
