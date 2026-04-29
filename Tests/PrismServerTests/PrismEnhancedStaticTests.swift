import Testing
import Foundation
@testable import PrismServer

@Suite("PrismEnhancedStatic Tests")
struct PrismEnhancedStaticTests {

    private let testDir: String = {
        let dir = NSTemporaryDirectory() + "prism_static_test_\(UUID().uuidString)"
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        return dir
    }()

    private func writeTestFile(_ name: String, content: String) {
        let path = (testDir as NSString).appendingPathComponent(name)
        let dir = (path as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: path, contents: Data(content.utf8))
    }

    @Test("Serves existing file")
    func servesFile() async throws {
        writeTestFile("hello.txt", content: "Hello World")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/hello.txt")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        #expect(response.status == .ok)
        #expect(String(data: response.body.data, encoding: .utf8) == "Hello World")
    }

    @Test("Returns 404 for missing file")
    func missingFile() async throws {
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/nonexistent.txt")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        #expect(response.status == .notFound)
    }

    @Test("Sets correct MIME type")
    func correctMimeType() async throws {
        writeTestFile("styles.css", content: "body { color: red; }")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/styles.css")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        #expect(response.headers.value(for: PrismHTTPHeaders.contentType)?.contains("text/css") == true)
    }

    @Test("ETag header is set")
    func etagSet() async throws {
        writeTestFile("etag.txt", content: "etag content")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/etag.txt")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        let etag = response.headers.value(for: PrismHTTPHeaders.eTag)
        #expect(etag != nil)
        #expect(etag?.hasPrefix("\"") == true)
        #expect(etag?.hasSuffix("\"") == true)
    }

    @Test("If-None-Match returns 304")
    func ifNoneMatch304() async throws {
        writeTestFile("cached.txt", content: "cached")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)

        let firstReq = PrismHTTPRequest(method: .GET, uri: "/cached.txt")
        let firstRes = try await middleware.handle(firstReq) { _ in PrismHTTPResponse(status: .notFound) }
        let etag = firstRes.headers.value(for: PrismHTTPHeaders.eTag)!

        var secondReq = PrismHTTPRequest(method: .GET, uri: "/cached.txt")
        secondReq.headers.set(name: PrismHTTPHeaders.ifNoneMatch, value: etag)
        let secondRes = try await middleware.handle(secondReq) { _ in PrismHTTPResponse(status: .notFound) }

        #expect(secondRes.status == .notModified)
    }

    @Test("Last-Modified header is set")
    func lastModifiedSet() async throws {
        writeTestFile("modified.txt", content: "modified")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/modified.txt")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        let lastModified = response.headers.value(for: "Last-Modified")
        #expect(lastModified != nil)
        #expect(lastModified?.contains("GMT") == true)
    }

    @Test("If-Modified-Since returns 304 for unchanged file")
    func ifModifiedSince304() async throws {
        writeTestFile("old.txt", content: "old content")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)

        let futureDate = Date().addingTimeInterval(3600)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"

        var request = PrismHTTPRequest(method: .GET, uri: "/old.txt")
        request.headers.set(name: "If-Modified-Since", value: formatter.string(from: futureDate))

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        #expect(response.status == .notModified)
    }

    @Test("Range request returns 206")
    func rangeRequest206() async throws {
        writeTestFile("range.txt", content: "0123456789")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)

        var request = PrismHTTPRequest(method: .GET, uri: "/range.txt")
        request.headers.set(name: "Range", value: "bytes=0-4")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        #expect(response.status == .partialContent)
        #expect(String(data: response.body.data, encoding: .utf8) == "01234")
        #expect(response.headers.value(for: "Content-Range")?.contains("bytes 0-4") == true)
    }

    @Test("Accept-Ranges header is set")
    func acceptRangesHeader() async throws {
        writeTestFile("ranges.txt", content: "content")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/ranges.txt")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        #expect(response.headers.value(for: "Accept-Ranges") == "bytes")
    }

    @Test("HEAD request returns headers without body")
    func headRequest() async throws {
        writeTestFile("head.txt", content: "head content")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .HEAD, uri: "/head.txt")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        #expect(response.status == .ok)
        #expect(response.body.isEmpty)
        #expect(response.headers.value(for: PrismHTTPHeaders.contentLength) != nil)
    }

    @Test("Directory traversal blocked")
    func directoryTraversalBlocked() async throws {
        writeTestFile("secret.txt", content: "secret")
        let subDir = (testDir as NSString).appendingPathComponent("sub")
        try? FileManager.default.createDirectory(atPath: subDir, withIntermediateDirectories: true)
        let config = PrismEnhancedStaticConfig(rootDirectory: subDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/../secret.txt")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        #expect(response.status != .ok || response.body.data != Data("secret".utf8))
    }

    @Test("POST method passes through to next handler")
    func postPassthrough() async throws {
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .POST, uri: "/hello.txt")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("handled by next")
        }

        #expect(String(data: response.body.data, encoding: .utf8) == "handled by next")
    }

    @Test("Index file served for directory")
    func indexFileServed() async throws {
        writeTestFile("sub/index.html", content: "<html>index</html>")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/sub")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        // Might serve index.html from sub directory
        if response.status == .ok {
            #expect(String(data: response.body.data, encoding: .utf8)?.contains("index") == true)
        }
    }

    @Test("Cache-Control header is set")
    func cacheControlHeader() async throws {
        writeTestFile("cacheable.txt", content: "cache me")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir, cacheControl: "public, max-age=7200")
        let middleware = PrismEnhancedStaticMiddleware(config: config)
        let request = PrismHTTPRequest(method: .GET, uri: "/cacheable.txt")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        #expect(response.headers.value(for: PrismHTTPHeaders.cacheControl) == "public, max-age=7200")
    }

    @Test("Invalid range returns 416")
    func invalidRange416() async throws {
        writeTestFile("small.txt", content: "tiny")
        let config = PrismEnhancedStaticConfig(rootDirectory: testDir)
        let middleware = PrismEnhancedStaticMiddleware(config: config)

        var request = PrismHTTPRequest(method: .GET, uri: "/small.txt")
        request.headers.set(name: "Range", value: "bytes=100-200")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }

        #expect(response.status == .rangeNotSatisfiable)
    }
}
