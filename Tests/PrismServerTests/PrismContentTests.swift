import Foundation
import Testing

@testable import PrismServer

@Suite("PrismContentNegotiation Tests")
struct PrismContentNegotiationTests {

    @Test("Decode JSON body")
    func decodeJSON() throws {
        struct User: Codable, Equatable {
            let name: String
            let age: Int
        }
        let json = #"{"name":"Alice","age":30}"#
        let request = PrismHTTPRequest(method: .POST, uri: "/users", body: Data(json.utf8))
        let user = try request.decodeJSON(User.self)
        #expect(user == User(name: "Alice", age: 30))
    }

    @Test("Decode JSON with empty body throws")
    func decodeEmptyBody() {
        let request = PrismHTTPRequest(method: .POST, uri: "/users")
        #expect(throws: PrismContentError.self) {
            _ = try request.decodeJSON([String: String].self)
        }
    }

    @Test("Decode invalid JSON throws")
    func decodeInvalidJSON() {
        let request = PrismHTTPRequest(method: .POST, uri: "/users", body: Data("not json".utf8))
        #expect(throws: PrismContentError.self) {
            _ = try request.decodeJSON([String: String].self)
        }
    }

    @Test("Form data parsing")
    func formData() {
        let body = Data("name=Alice&age=30&city=S%C3%A3o%20Paulo".utf8)
        let request = PrismHTTPRequest(method: .POST, uri: "/form", body: body)
        let form = request.formData
        #expect(form["name"] == "Alice")
        #expect(form["age"] == "30")
        #expect(form["city"] == "São Paulo")
    }

    @Test("Form data with nil body")
    func formDataNilBody() {
        let request = PrismHTTPRequest(method: .POST, uri: "/form")
        #expect(request.formData.isEmpty)
    }

    @Test("Body string")
    func bodyString() {
        let request = PrismHTTPRequest(method: .POST, uri: "/echo", body: Data("hello".utf8))
        #expect(request.bodyString == "hello")
    }
}

@Suite("PrismMultipart Tests")
struct PrismMultipartTests {

    let parser = PrismMultipartParser()

    @Test("Extract boundary from Content-Type")
    func extractBoundary() {
        let ct = "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW"
        let boundary = parser.extractBoundary(from: ct)
        #expect(boundary == "----WebKitFormBoundary7MA4YWxkTrZu0gW")
    }

    @Test("Extract quoted boundary")
    func extractQuotedBoundary() {
        let ct = #"multipart/form-data; boundary="my-boundary""#
        let boundary = parser.extractBoundary(from: ct)
        #expect(boundary == "my-boundary")
    }

    @Test("Parse simple multipart body")
    func parseSimple() throws {
        let boundary = "testboundary"
        let body =
            "--\(boundary)\r\nContent-Disposition: form-data; name=\"field1\"\r\n\r\nvalue1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"field2\"\r\n\r\nvalue2\r\n--\(boundary)--\r\n"

        let parts = try parser.parse(data: Data(body.utf8), boundary: boundary)
        #expect(parts.count == 2)
        #expect(parts[0].name == "field1")
        #expect(parts[0].stringValue == "value1")
        #expect(parts[1].name == "field2")
        #expect(parts[1].stringValue == "value2")
    }

    @Test("Parse file upload part")
    func parseFileUpload() throws {
        let boundary = "testboundary"
        let body =
            "--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"test.txt\"\r\nContent-Type: text/plain\r\n\r\nfile content here\r\n--\(boundary)--\r\n"

        let parts = try parser.parse(data: Data(body.utf8), boundary: boundary)
        #expect(parts.count == 1)
        #expect(parts[0].name == "file")
        #expect(parts[0].filename == "test.txt")
        #expect(parts[0].contentType == "text/plain")
    }

    @Test("Request multipartParts with wrong content type throws")
    func wrongContentType() {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/json")
        let request = PrismHTTPRequest(method: .POST, uri: "/upload", headers: headers, body: Data("test".utf8))
        #expect(throws: PrismContentError.self) {
            _ = try request.multipartParts()
        }
    }
}

@Suite("PrismMIMEType Tests")
struct PrismMIMETypeTests {

    @Test("Common MIME types")
    func commonTypes() {
        #expect(PrismMIMEType.forExtension("html") == "text/html; charset=utf-8")
        #expect(PrismMIMEType.forExtension("json") == "application/json; charset=utf-8")
        #expect(PrismMIMEType.forExtension("png") == "image/png")
        #expect(PrismMIMEType.forExtension("css") == "text/css; charset=utf-8")
        #expect(PrismMIMEType.forExtension("js") == "application/javascript; charset=utf-8")
        #expect(PrismMIMEType.forExtension("pdf") == "application/pdf")
    }

    @Test("Unknown extension returns octet-stream")
    func unknownExtension() {
        #expect(PrismMIMEType.forExtension("xyz") == "application/octet-stream")
    }

    @Test("Case insensitive")
    func caseInsensitive() {
        #expect(PrismMIMEType.forExtension("HTML") == "text/html; charset=utf-8")
        #expect(PrismMIMEType.forExtension("PNG") == "image/png")
    }
}
