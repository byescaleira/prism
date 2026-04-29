import Testing
import Foundation
@testable import PrismServer

@Suite("PrismMultipartStreaming Tests")
struct PrismMultipartStreamingTests {

    private func buildMultipartBody(boundary: String, parts: [(name: String, filename: String?, contentType: String?, data: Data)]) -> Data {
        var body = Data()
        for part in parts {
            body.append(Data("--\(boundary)\r\n".utf8))
            var disposition = "Content-Disposition: form-data; name=\"\(part.name)\""
            if let filename = part.filename {
                disposition += "; filename=\"\(filename)\""
            }
            body.append(Data("\(disposition)\r\n".utf8))
            if let ct = part.contentType {
                body.append(Data("Content-Type: \(ct)\r\n".utf8))
            }
            body.append(Data("\r\n".utf8))
            body.append(part.data)
            body.append(Data("\r\n".utf8))
        }
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }

    @Test("Extract boundary from content type")
    func extractBoundary() {
        let ct = "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW"
        let boundary = PrismMultipartStreamParser.extractBoundary(from: ct)
        #expect(boundary == "----WebKitFormBoundary7MA4YWxkTrZu0gW")
    }

    @Test("Extract boundary with quotes")
    func extractBoundaryQuoted() {
        let ct = "multipart/form-data; boundary=\"abc123\""
        let boundary = PrismMultipartStreamParser.extractBoundary(from: ct)
        #expect(boundary == "abc123")
    }

    @Test("Returns nil for missing boundary")
    func missingBoundary() {
        let ct = "multipart/form-data"
        let boundary = PrismMultipartStreamParser.extractBoundary(from: ct)
        #expect(boundary == nil)
    }

    @Test("Parse single text part")
    func parseSinglePart() throws {
        let boundary = "test-boundary"
        let body = buildMultipartBody(boundary: boundary, parts: [
            (name: "field", filename: nil, contentType: nil, data: Data("hello".utf8))
        ])

        let parser = PrismMultipartStreamParser(boundary: boundary)
        let parts = try parser.parse(body)

        #expect(parts.count == 1)
        #expect(parts[0].name == "field")
        #expect(parts[0].filename == nil)
        #expect(String(data: parts[0].data, encoding: .utf8) == "hello")
    }

    @Test("Parse multiple parts")
    func parseMultipleParts() throws {
        let boundary = "multi-boundary"
        let body = buildMultipartBody(boundary: boundary, parts: [
            (name: "name", filename: nil, contentType: nil, data: Data("John".utf8)),
            (name: "email", filename: nil, contentType: nil, data: Data("john@test.com".utf8))
        ])

        let parser = PrismMultipartStreamParser(boundary: boundary)
        let parts = try parser.parse(body)

        #expect(parts.count == 2)
        #expect(parts[0].name == "name")
        #expect(parts[1].name == "email")
    }

    @Test("Parse file upload part")
    func parseFileUpload() throws {
        let boundary = "file-boundary"
        let fileData = Data("file content here".utf8)
        let body = buildMultipartBody(boundary: boundary, parts: [
            (name: "avatar", filename: "photo.jpg", contentType: "image/jpeg", data: fileData)
        ])

        let parser = PrismMultipartStreamParser(boundary: boundary)
        let parts = try parser.parse(body)

        #expect(parts.count == 1)
        #expect(parts[0].name == "avatar")
        #expect(parts[0].filename == "photo.jpg")
        #expect(parts[0].contentType == "image/jpeg")
        #expect(parts[0].data == fileData)
    }

    @Test("Rejects part exceeding max size")
    func rejectsLargePart() throws {
        let boundary = "size-boundary"
        let largeData = Data(repeating: 0x41, count: 1024)
        let body = buildMultipartBody(boundary: boundary, parts: [
            (name: "big", filename: "large.bin", contentType: "application/octet-stream", data: largeData)
        ])

        let parser = PrismMultipartStreamParser(boundary: boundary, maxPartSize: 512)

        #expect(throws: PrismMultipartStreamError.self) {
            _ = try parser.parse(body)
        }
    }

    @Test("Rejects too many parts")
    func rejectsTooManyParts() throws {
        let boundary = "many-boundary"
        var parts: [(name: String, filename: String?, contentType: String?, data: Data)] = []
        for i in 0..<5 {
            parts.append((name: "field\(i)", filename: nil, contentType: nil, data: Data("v\(i)".utf8)))
        }
        let body = buildMultipartBody(boundary: boundary, parts: parts)

        let parser = PrismMultipartStreamParser(boundary: boundary, maxParts: 3)

        #expect(throws: PrismMultipartStreamError.self) {
            _ = try parser.parse(body)
        }
    }

    @Test("Empty body returns no parts")
    func emptyBody() throws {
        let parser = PrismMultipartStreamParser(boundary: "empty")
        let parts = try parser.parse(Data())
        #expect(parts.isEmpty)
    }

    @Test("Progress callback is called")
    func progressCallback() throws {
        let boundary = "progress-boundary"
        let body = buildMultipartBody(boundary: boundary, parts: [
            (name: "a", filename: nil, contentType: nil, data: Data("1".utf8)),
            (name: "b", filename: nil, contentType: nil, data: Data("2".utf8))
        ])

        let parser = PrismMultipartStreamParser(boundary: boundary)
        let counter = ProgressCounter()

        _ = try parser.parse(body) { progress in
            counter.add(progress)
        }

        #expect(counter.count == 2)
    }

    @Test("Async stream yields parts")
    func asyncStream() async throws {
        let boundary = "async-boundary"
        let body = buildMultipartBody(boundary: boundary, parts: [
            (name: "x", filename: nil, contentType: nil, data: Data("val".utf8))
        ])

        let parser = PrismMultipartStreamParser(boundary: boundary)
        var count = 0
        for await part in parser.parseAsync(body) {
            #expect(part.name == "x")
            count += 1
        }
        #expect(count == 1)
    }

    @Test("Mixed text and file parts")
    func mixedParts() throws {
        let boundary = "mixed"
        let body = buildMultipartBody(boundary: boundary, parts: [
            (name: "title", filename: nil, contentType: nil, data: Data("My Doc".utf8)),
            (name: "file", filename: "doc.pdf", contentType: "application/pdf", data: Data(repeating: 0xFF, count: 100))
        ])

        let parser = PrismMultipartStreamParser(boundary: boundary)
        let parts = try parser.parse(body)

        #expect(parts.count == 2)
        #expect(parts[0].filename == nil)
        #expect(parts[1].filename == "doc.pdf")
        #expect(parts[1].data.count == 100)
    }

    @Test("Multipart middleware populates userInfo")
    func multipartMiddleware() async throws {
        let boundary = "middleware-test"
        let body = buildMultipartBody(boundary: boundary, parts: [
            (name: "field", filename: nil, contentType: nil, data: Data("value".utf8)),
            (name: "file", filename: "test.txt", contentType: "text/plain", data: Data("content".utf8))
        ])

        let middleware = PrismMultipartStreamMiddleware()
        var request = PrismHTTPRequest(method: .POST, uri: "/upload")
        request.headers.set(name: PrismHTTPHeaders.contentType, value: "multipart/form-data; boundary=\(boundary)")
        request.body = body

        let response = try await middleware.handle(request) { req in
            #expect(req.userInfo["multipart.count"] == "2")
            #expect(req.userInfo["multipart.0.name"] == "field")
            #expect(req.userInfo["multipart.1.filename"] == "test.txt")
            return PrismHTTPResponse.text("ok")
        }

        #expect(response.status == .ok)
    }

    @Test("Multipart middleware passes through non-multipart requests")
    func multipartMiddlewarePassthrough() async throws {
        let middleware = PrismMultipartStreamMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/plain")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("plain response")
        }

        #expect(response.status == .ok)
    }

    @Test("PrismMultipartProgress fraction calculation")
    func progressFraction() {
        let progress = PrismMultipartProgress(bytesProcessed: 500, totalBytes: 1000, partsCompleted: 1)
        #expect(progress.fraction == 0.5)

        let noTotal = PrismMultipartProgress(bytesProcessed: 500, totalBytes: nil, partsCompleted: 1)
        #expect(noTotal.fraction == nil)
    }

    @Test("PrismStreamingPart initializer")
    func partInitializer() {
        let part = PrismStreamingPart(name: "test", filename: "f.txt", contentType: "text/plain", data: Data("hi".utf8))
        #expect(part.name == "test")
        #expect(part.filename == "f.txt")
        #expect(part.contentType == "text/plain")
        #expect(part.headers.isEmpty)
    }
}

final class ProgressCounter: @unchecked Sendable {
    private var updates: [PrismMultipartProgress] = []
    func add(_ p: PrismMultipartProgress) { updates.append(p) }
    var count: Int { updates.count }
}
