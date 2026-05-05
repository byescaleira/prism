import Foundation
import Testing

@testable import PrismServer

@Suite("PrismStreamWriter Tests")
struct PrismStreamWriterTests {

    @Test("Formats chunks correctly")
    func chunkFormat() async {
        let writer = PrismStreamWriter()
        await writer.write("hello")
        let data = await writer.serialize()
        let str = String(data: data, encoding: .utf8)!
        #expect(str.hasPrefix("5\r\nhello\r\n"))
        #expect(str.hasSuffix("0\r\n\r\n"))
    }

    @Test("Multiple chunks serialize in order")
    func multipleChunks() async {
        let writer = PrismStreamWriter()
        await writer.write("ab")
        await writer.write("cde")
        let data = await writer.serialize()
        let str = String(data: data, encoding: .utf8)!
        #expect(str.contains("2\r\nab\r\n"))
        #expect(str.contains("3\r\ncde\r\n"))
        #expect(str.hasSuffix("0\r\n\r\n"))
    }

    @Test("End marks stream as ended")
    func end() async {
        let writer = PrismStreamWriter()
        await writer.end()
        #expect(await writer.isEnded == true)
    }

    @Test("Write after end is ignored")
    func writeAfterEnd() async {
        let writer = PrismStreamWriter()
        await writer.write("before")
        await writer.end()
        await writer.write("after")
        let data = await writer.serialize()
        let str = String(data: data, encoding: .utf8)!
        #expect(str.contains("before"))
        #expect(!str.contains("after"))
    }
}

@Suite("PrismChunkedResponse Tests")
struct PrismChunkedResponseTests {

    @Test("Has Transfer-Encoding header")
    func transferEncoding() {
        let response = PrismChunkedResponse.chunked(contentType: "text/plain")
        #expect(response.headers.value(for: "Transfer-Encoding") == "chunked")
        #expect(response.headers.value(for: "Content-Type") == "text/plain")
    }
}

@Suite("PrismHTTPRequest bodyChunks Tests")
struct PrismBodyChunksTests {

    @Test("Splits body into chunks")
    func bodyChunks() {
        let body = Data(repeating: 0x41, count: 20)
        let request = PrismHTTPRequest(method: .POST, uri: "/upload", body: body)
        let chunks = request.bodyChunks(size: 8)
        #expect(chunks.count == 3)
        #expect(chunks[0].count == 8)
        #expect(chunks[1].count == 8)
        #expect(chunks[2].count == 4)
    }

    @Test("Empty body returns empty array")
    func emptyBody() {
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let chunks = request.bodyChunks()
        #expect(chunks.isEmpty)
    }
}
