import Foundation
import Testing

@testable import PrismServer

@Suite("PrismHTTPParser Tests")
struct PrismHTTPParserTests {

    let parser = PrismHTTPParser()

    @Test("Parse simple GET request")
    func parseGET() throws {
        let raw = "GET /hello HTTP/1.1\r\nHost: localhost\r\n\r\n"
        let (request, consumed) = try parser.parse(Data(raw.utf8))
        #expect(request.method == .GET)
        #expect(request.path == "/hello")
        #expect(request.version == "HTTP/1.1")
        #expect(request.headers.value(for: "Host") == "localhost")
        #expect(consumed == raw.utf8.count)
    }

    @Test("Parse POST with body")
    func parsePOST() throws {
        let body = "{\"name\":\"test\"}"
        let raw =
            "POST /api/users HTTP/1.1\r\nContent-Type: application/json\r\nContent-Length: \(body.count)\r\n\r\n\(body)"
        let (request, _) = try parser.parse(Data(raw.utf8))
        #expect(request.method == .POST)
        #expect(request.path == "/api/users")
        #expect(request.bodyString == body)
        #expect(request.contentType == "application/json")
        #expect(request.contentLength == body.count)
    }

    @Test("Parse request with multiple headers")
    func multipleHeaders() throws {
        let raw = "GET / HTTP/1.1\r\nHost: example.com\r\nAccept: text/html\r\nUser-Agent: PrismTest\r\n\r\n"
        let (request, _) = try parser.parse(Data(raw.utf8))
        #expect(request.headers.value(for: "Host") == "example.com")
        #expect(request.headers.value(for: "Accept") == "text/html")
        #expect(request.headers.value(for: "User-Agent") == "PrismTest")
    }

    @Test("Parse request with query string")
    func queryString() throws {
        let raw = "GET /search?q=swift&lang=en HTTP/1.1\r\nHost: localhost\r\n\r\n"
        let (request, _) = try parser.parse(Data(raw.utf8))
        #expect(request.query("q") == "swift")
        #expect(request.query("lang") == "en")
    }

    @Test("Incomplete request throws")
    func incompleteRequest() {
        let raw = "GET /hello HTTP/1.1\r\nHost: local"
        #expect(throws: PrismHTTPParser.ParserError.self) {
            _ = try parser.parse(Data(raw.utf8))
        }
    }

    @Test("Invalid method throws")
    func invalidMethod() {
        let raw = "INVALID /hello HTTP/1.1\r\n\r\n"
        #expect(throws: PrismHTTPParser.ParserError.self) {
            _ = try parser.parse(Data(raw.utf8))
        }
    }

    @Test("Body too large throws")
    func bodyTooLarge() {
        let smallParser = PrismHTTPParser(maxBodySize: 5)
        let raw = "POST / HTTP/1.1\r\nContent-Length: 100\r\n\r\n" + String(repeating: "x", count: 100)
        #expect(throws: PrismHTTPParser.ParserError.self) {
            _ = try smallParser.parse(Data(raw.utf8))
        }
    }

    @Test("Incomplete body throws incompleteRequest")
    func incompleteBody() {
        let raw = "POST / HTTP/1.1\r\nContent-Length: 100\r\n\r\nshort"
        #expect(throws: PrismHTTPParser.ParserError.self) {
            _ = try parser.parse(Data(raw.utf8))
        }
    }

    @Test("Parse DELETE request")
    func parseDELETE() throws {
        let raw = "DELETE /users/42 HTTP/1.1\r\nHost: localhost\r\n\r\n"
        let (request, _) = try parser.parse(Data(raw.utf8))
        #expect(request.method == .DELETE)
        #expect(request.path == "/users/42")
    }

    @Test("No body when no Content-Length")
    func noBody() throws {
        let raw = "GET / HTTP/1.1\r\n\r\n"
        let (request, _) = try parser.parse(Data(raw.utf8))
        #expect(request.body == nil)
    }
}
