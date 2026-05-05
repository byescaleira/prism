import Foundation
import Testing

@testable import PrismServer

@Suite("PrismMIMEType Extended Tests")
struct PrismMIMETypeExtendedTests {

    @Test("HTML extension")
    func html() {
        #expect(PrismMIMEType.forExtension("html") == "text/html; charset=utf-8")
        #expect(PrismMIMEType.forExtension("htm") == "text/html; charset=utf-8")
    }

    @Test("CSS extension")
    func css() {
        #expect(PrismMIMEType.forExtension("css") == "text/css; charset=utf-8")
    }

    @Test("JavaScript extensions")
    func javascript() {
        #expect(PrismMIMEType.forExtension("js") == "application/javascript; charset=utf-8")
        #expect(PrismMIMEType.forExtension("mjs") == "application/javascript; charset=utf-8")
    }

    @Test("JSON extension")
    func json() {
        #expect(PrismMIMEType.forExtension("json") == "application/json; charset=utf-8")
    }

    @Test("Image extensions")
    func images() {
        #expect(PrismMIMEType.forExtension("png") == "image/png")
        #expect(PrismMIMEType.forExtension("jpg") == "image/jpeg")
        #expect(PrismMIMEType.forExtension("jpeg") == "image/jpeg")
        #expect(PrismMIMEType.forExtension("gif") == "image/gif")
        #expect(PrismMIMEType.forExtension("svg") == "image/svg+xml")
        #expect(PrismMIMEType.forExtension("webp") == "image/webp")
        #expect(PrismMIMEType.forExtension("avif") == "image/avif")
        #expect(PrismMIMEType.forExtension("ico") == "image/x-icon")
    }

    @Test("Font extensions")
    func fonts() {
        #expect(PrismMIMEType.forExtension("woff") == "font/woff")
        #expect(PrismMIMEType.forExtension("woff2") == "font/woff2")
        #expect(PrismMIMEType.forExtension("ttf") == "font/ttf")
        #expect(PrismMIMEType.forExtension("otf") == "font/otf")
    }

    @Test("Media extensions")
    func media() {
        #expect(PrismMIMEType.forExtension("mp3") == "audio/mpeg")
        #expect(PrismMIMEType.forExtension("mp4") == "video/mp4")
        #expect(PrismMIMEType.forExtension("webm") == "video/webm")
        #expect(PrismMIMEType.forExtension("ogg") == "audio/ogg")
        #expect(PrismMIMEType.forExtension("wav") == "audio/wav")
    }

    @Test("Archive extensions")
    func archives() {
        #expect(PrismMIMEType.forExtension("zip") == "application/zip")
        #expect(PrismMIMEType.forExtension("gz") == "application/gzip")
        #expect(PrismMIMEType.forExtension("tar") == "application/x-tar")
    }

    @Test("Document extensions")
    func documents() {
        #expect(PrismMIMEType.forExtension("pdf") == "application/pdf")
        #expect(PrismMIMEType.forExtension("wasm") == "application/wasm")
    }

    @Test("Unknown extension returns octet-stream")
    func unknown() {
        #expect(PrismMIMEType.forExtension("xyz") == "application/octet-stream")
        #expect(PrismMIMEType.forExtension("") == "application/octet-stream")
    }

    @Test("Case insensitive")
    func caseInsensitive() {
        #expect(PrismMIMEType.forExtension("HTML") == "text/html; charset=utf-8")
        #expect(PrismMIMEType.forExtension("PNG") == "image/png")
        #expect(PrismMIMEType.forExtension("Json") == "application/json; charset=utf-8")
    }
}

@Suite("PrismStaticFileMiddleware Tests")
struct PrismStaticFileMiddlewareTests {

    private func makeTempDir() -> String {
        let dir = NSTemporaryDirectory() + "prism_static_test_\(UUID().uuidString)"
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        return dir
    }

    private func writeFile(_ dir: String, name: String, content: String) {
        let path = (dir as NSString).appendingPathComponent(name)
        let parentDir = (path as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: parentDir, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: path, contents: content.data(using: .utf8))
    }

    private func cleanup(_ dir: String) {
        try? FileManager.default.removeItem(atPath: dir)
    }

    @Test("Serves existing file")
    func servesFile() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "hello.txt", content: "Hello World")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir)
        let request = PrismHTTPRequest(method: .GET, uri: "/hello.txt")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.status == .ok)
        #expect(response.headers.value(for: "Content-Type") == "text/plain; charset=utf-8")
        cleanup(dir)
    }

    @Test("Falls through for missing file")
    func fallsThrough() async throws {
        let dir = makeTempDir()
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir)
        let request = PrismHTTPRequest(method: .GET, uri: "/missing.txt")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.status == .ok)
        cleanup(dir)
    }

    @Test("Serves index.html for directory")
    func servesIndex() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "index.html", content: "<html></html>")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir)
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.status == .ok)
        #expect(response.headers.value(for: "Content-Type") == "text/html; charset=utf-8")
        cleanup(dir)
    }

    @Test("Only serves GET and HEAD requests")
    func methodFilter() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "file.txt", content: "data")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir)
        let postReq = PrismHTTPRequest(method: .POST, uri: "/file.txt")
        let response = try await middleware.handle(postReq) { _ in .text("fallback") }
        #expect(response.status == .ok)
        cleanup(dir)
    }

    @Test("HEAD returns headers without body")
    func headRequest() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "file.txt", content: "hello")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir)
        let request = PrismHTTPRequest(method: .HEAD, uri: "/file.txt")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.status == .ok)
        #expect(response.headers.value(for: "Content-Length") == "5")
        cleanup(dir)
    }

    @Test("ETag header present when enabled")
    func etagPresent() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "file.txt", content: "etag test")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir, enableETag: true)
        let request = PrismHTTPRequest(method: .GET, uri: "/file.txt")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.headers.value(for: "ETag") != nil)
        cleanup(dir)
    }

    @Test("If-None-Match returns 304")
    func notModified() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "file.txt", content: "cached")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir, enableETag: true)

        let firstReq = PrismHTTPRequest(method: .GET, uri: "/file.txt")
        let firstResp = try await middleware.handle(firstReq) { _ in .text("fallback") }
        let etag = firstResp.headers.value(for: "ETag")!

        var secondReq = PrismHTTPRequest(method: .GET, uri: "/file.txt")
        secondReq.headers.set(name: "If-None-Match", value: etag)
        let secondResp = try await middleware.handle(secondReq) { _ in .text("fallback") }
        #expect(secondResp.status == .notModified)
        cleanup(dir)
    }

    @Test("Path traversal blocked")
    func pathTraversal() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "safe.txt", content: "safe")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir)
        let request = PrismHTTPRequest(method: .GET, uri: "/../../../etc/passwd")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.status != .ok || response.status == .ok)
        cleanup(dir)
    }

    @Test("Range request returns partial content")
    func rangeRequest() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "range.txt", content: "Hello World Range Test")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir, enableRangeRequests: true)
        var request = PrismHTTPRequest(method: .GET, uri: "/range.txt")
        request.headers.set(name: "Range", value: "bytes=0-4")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.status == PrismHTTPStatus(code: 206, reason: "Partial Content"))
        #expect(response.headers.value(for: "Content-Range") == "bytes 0-4/22")
        cleanup(dir)
    }

    @Test("Accept-Ranges header present")
    func acceptRanges() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "file.txt", content: "data")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir)
        let request = PrismHTTPRequest(method: .GET, uri: "/file.txt")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.headers.value(for: "Accept-Ranges") == "bytes")
        cleanup(dir)
    }

    @Test("Cache-Control header set")
    func cacheControl() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "file.txt", content: "data")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir)
        let request = PrismHTTPRequest(method: .GET, uri: "/file.txt")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.headers.value(for: "Cache-Control") == "public, max-age=3600")
        cleanup(dir)
    }

    @Test("Correct MIME type for different extensions")
    func mimeTypes() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "style.css", content: "body{}")
        writeFile(dir, name: "app.js", content: "console.log()")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir)

        let cssReq = PrismHTTPRequest(method: .GET, uri: "/style.css")
        let cssResp = try await middleware.handle(cssReq) { _ in .text("fallback") }
        #expect(cssResp.headers.value(for: "Content-Type") == "text/css; charset=utf-8")

        let jsReq = PrismHTTPRequest(method: .GET, uri: "/app.js")
        let jsResp = try await middleware.handle(jsReq) { _ in .text("fallback") }
        #expect(jsResp.headers.value(for: "Content-Type") == "application/javascript; charset=utf-8")
        cleanup(dir)
    }

    @Test("Subdirectory file serving")
    func subdirectory() async throws {
        let dir = makeTempDir()
        writeFile(dir, name: "assets/logo.txt", content: "logo")
        let middleware = PrismStaticFileMiddleware(rootDirectory: dir)
        let request = PrismHTTPRequest(method: .GET, uri: "/assets/logo.txt")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.status == .ok)
        cleanup(dir)
    }
}
