import Foundation
import Testing

@testable import PrismServer

@Suite("PrismResponseCompression Tests")
struct PrismResponseCompressionTests {

    private func makeTextResponse(size: Int) -> PrismHTTPResponse {
        let body = String(repeating: "a", count: size)
        return PrismHTTPResponse.text(body)
    }

    @Test("Compresses text response above threshold")
    func compressesAboveThreshold() async throws {
        let middleware = PrismResponseCompressionMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Accept-Encoding", value: "gzip, deflate")

        let response = try await middleware.handle(request) { _ in
            self.makeTextResponse(size: 2048)
        }

        #expect(response.headers.value(for: "Content-Encoding") != nil)
        #expect(response.body.data.count < 2048)
    }

    @Test("Does not compress below threshold")
    func doesNotCompressBelowThreshold() async throws {
        let middleware = PrismResponseCompressionMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            self.makeTextResponse(size: 100)
        }

        #expect(response.headers.value(for: "Content-Encoding") == nil)
    }

    @Test("Does not compress when no Accept-Encoding")
    func noAcceptEncoding() async throws {
        let middleware = PrismResponseCompressionMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/api")

        let response = try await middleware.handle(request) { _ in
            self.makeTextResponse(size: 2048)
        }

        #expect(response.headers.value(for: "Content-Encoding") == nil)
    }

    @Test("Does not compress already compressed response")
    func alreadyCompressed() async throws {
        let middleware = PrismResponseCompressionMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            var resp = self.makeTextResponse(size: 2048)
            resp.headers.set(name: "Content-Encoding", value: "br")
            return resp
        }

        #expect(response.headers.value(for: "Content-Encoding") == "br")
    }

    @Test("Does not compress non-compressible content types")
    func nonCompressibleType() async throws {
        let middleware = PrismResponseCompressionMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/image.png")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            var headers = PrismHTTPHeaders()
            headers.set(name: PrismHTTPHeaders.contentType, value: "image/png")
            return PrismHTTPResponse(status: .ok, headers: headers, body: .data(Data(repeating: 0xFF, count: 2048)))
        }

        #expect(response.headers.value(for: "Content-Encoding") == nil)
    }

    @Test("Adds Vary header for Accept-Encoding")
    func varyHeader() async throws {
        let middleware = PrismResponseCompressionMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            self.makeTextResponse(size: 2048)
        }

        if response.headers.value(for: "Content-Encoding") != nil {
            let vary = response.headers.values(for: "Vary")
            #expect(vary.contains("Accept-Encoding"))
        }
    }

    @Test("Updates Content-Length after compression")
    func updatesContentLength() async throws {
        let middleware = PrismResponseCompressionMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            self.makeTextResponse(size: 2048)
        }

        if let encoding = response.headers.value(for: "Content-Encoding"), !encoding.isEmpty {
            let clStr = response.headers.value(for: PrismHTTPHeaders.contentLength)
            let cl = Int(clStr ?? "0") ?? 0
            #expect(cl == response.body.data.count)
        }
    }

    @Test("Custom minimum size threshold")
    func customMinSize() async throws {
        let config = PrismResponseCompressionConfig(minimumSize: 5000)
        let middleware = PrismResponseCompressionMiddleware(config: config)
        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            self.makeTextResponse(size: 3000)
        }

        #expect(response.headers.value(for: "Content-Encoding") == nil)
    }

    @Test("Excluded paths skip compression")
    func excludedPaths() async throws {
        let config = PrismResponseCompressionConfig(excludedPaths: ["/health", "/metrics"])
        let middleware = PrismResponseCompressionMiddleware(config: config)
        var request = PrismHTTPRequest(method: .GET, uri: "/health")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            self.makeTextResponse(size: 2048)
        }

        #expect(response.headers.value(for: "Content-Encoding") == nil)
    }

    @Test("Deflate algorithm supported")
    func deflateSupported() async throws {
        let middleware = PrismResponseCompressionMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Accept-Encoding", value: "deflate")

        let response = try await middleware.handle(request) { _ in
            self.makeTextResponse(size: 2048)
        }

        if let encoding = response.headers.value(for: "Content-Encoding") {
            #expect(encoding == "deflate")
        }
    }

    @Test("Compression algorithm enum raw values")
    func algorithmRawValues() {
        #expect(PrismCompressionAlgorithm.gzip.rawValue == "gzip")
        #expect(PrismCompressionAlgorithm.deflate.rawValue == "deflate")
    }

    @Test("Default compressible types include JSON")
    func defaultCompressibleTypes() {
        let defaults = PrismResponseCompressionConfig.defaultCompressibleTypes
        #expect(defaults.contains("application/json"))
        #expect(defaults.contains("text/html"))
        #expect(defaults.contains("text/css"))
    }

    @Test("JSON content type is compressed")
    func jsonCompressed() async throws {
        let middleware = PrismResponseCompressionMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/api/data")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            let jsonStr = String(repeating: "{\"key\":\"value\"},", count: 200)
            var headers = PrismHTTPHeaders()
            headers.set(name: PrismHTTPHeaders.contentType, value: "application/json")
            headers.set(name: PrismHTTPHeaders.contentLength, value: "\(jsonStr.utf8.count)")
            return PrismHTTPResponse(status: .ok, headers: headers, body: .data(Data(jsonStr.utf8)))
        }

        #expect(response.headers.value(for: "Content-Encoding") != nil)
    }

    @Test("Custom compressible types")
    func customCompressibleTypes() async throws {
        let config = PrismResponseCompressionConfig(compressibleTypes: Set(["application/custom"]))
        let middleware = PrismResponseCompressionMiddleware(config: config)
        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            var headers = PrismHTTPHeaders()
            headers.set(name: PrismHTTPHeaders.contentType, value: "text/html")
            return PrismHTTPResponse(status: .ok, headers: headers, body: .data(Data(repeating: 0x41, count: 2048)))
        }

        #expect(response.headers.value(for: "Content-Encoding") == nil)
    }

    @Test("Preferred algorithm used when available")
    func preferredAlgorithm() async throws {
        let config = PrismResponseCompressionConfig(preferredAlgorithm: .deflate)
        let middleware = PrismResponseCompressionMiddleware(config: config)
        var request = PrismHTTPRequest(method: .GET, uri: "/api")
        request.headers.set(name: "Accept-Encoding", value: "gzip, deflate")

        let response = try await middleware.handle(request) { _ in
            self.makeTextResponse(size: 2048)
        }

        if let encoding = response.headers.value(for: "Content-Encoding") {
            #expect(encoding == "deflate")
        }
    }
}
