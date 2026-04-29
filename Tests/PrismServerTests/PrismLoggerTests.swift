import Testing
import Foundation
@testable import PrismServer
@testable import PrismFoundation

@Suite("PrismLogger Tests")
struct PrismLoggerTests {

    @Test("JSON log destination formats output as JSON")
    func jsonLogDestination() {
        let dest = PrismJSONLogDestination()
        let entry = PrismLogEntry(level: .info, message: "test", category: "test")
        dest.write(entry)
    }

    @Test("File log destination writes to file")
    func fileLogDestination() throws {
        let tmpPath = NSTemporaryDirectory() + "prism_log_test_\(UUID().uuidString).log"
        defer { try? FileManager.default.removeItem(atPath: tmpPath) }

        let dest = PrismFileLogDestination(filePath: tmpPath)
        let entry = PrismLogEntry(level: .error, message: "test error", category: "app")
        dest.write(entry)

        let content = try String(contentsOfFile: tmpPath, encoding: .utf8)
        #expect(content.contains("test error"))
        #expect(content.contains("[error]"))
    }

    @Test("Logger middleware logs request and response")
    func loggerMiddleware() async throws {
        let logger = PrismStructuredLogger(minimumLevel: .trace, destinations: [])
        let middleware = PrismLoggerMiddleware(logger: logger)
        let request = PrismHTTPRequest(method: .GET, uri: "/api/test")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .ok, body: .text("hello"))
        }

        #expect(response.status == .ok)
        let entries = await logger.entries
        #expect(entries.count == 2)
        #expect(entries[0].message.contains("GET"))
        #expect(entries[1].message.contains("200"))
    }

    @Test("Logger middleware logs error responses")
    func loggerMiddlewareError() async throws {
        let logger = PrismStructuredLogger(minimumLevel: .trace, destinations: [])
        let middleware = PrismLoggerMiddleware(logger: logger)
        let request = PrismHTTPRequest(method: .POST, uri: "/api/fail")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .internalServerError, body: .text("fail"))
        }

        #expect(response.status == .internalServerError)
        let entries = await logger.entries
        #expect(entries.count == 2)
        #expect(entries[1].level == .error)
    }

    @Test("Logger middleware captures timing")
    func loggerMiddlewareTiming() async throws {
        let logger = PrismStructuredLogger(minimumLevel: .trace, destinations: [])
        let middleware = PrismLoggerMiddleware(logger: logger)
        let request = PrismHTTPRequest(method: .GET, uri: "/slow")

        _ = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        let entries = await logger.entries
        #expect(entries.count == 2)
        #expect(entries[1].metadata["duration_ms"] != nil)
    }

    @Test("Logger middleware propagates thrown errors")
    func loggerMiddlewareThrows() async throws {
        let logger = PrismStructuredLogger(minimumLevel: .trace, destinations: [])
        let middleware = PrismLoggerMiddleware(logger: logger)
        let request = PrismHTTPRequest(method: .GET, uri: "/error")

        do {
            _ = try await middleware.handle(request) { _ in
                throw PrismTimeoutError.requestTimedOut(timeout: .seconds(1))
            }
            #expect(Bool(false), "Should have thrown")
        } catch {
            let entries = await logger.entries
            #expect(entries.count == 2)
            #expect(entries[1].level == .error)
        }
    }

    @Test("Request ID middleware generates ID")
    func requestIdMiddleware() async throws {
        let middleware = PrismRequestIdMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/test")

        let response = try await middleware.handle(request) { req in
            let rid = req.userInfo["requestId"] ?? ""
            return PrismHTTPResponse.text(rid)
        }

        let rid = String(data: response.body.data, encoding: .utf8) ?? ""
        #expect(!rid.isEmpty)
        #expect(response.headers.value(for: "X-Request-ID") == rid)
    }

    @Test("Request ID middleware preserves existing ID")
    func requestIdPreservesExisting() async throws {
        let middleware = PrismRequestIdMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/test")
        request.headers.set(name: "X-Request-ID", value: "existing-id")

        let response = try await middleware.handle(request) { req in
            PrismHTTPResponse.text(req.userInfo["requestId"] ?? "")
        }

        let rid = String(data: response.body.data, encoding: .utf8)
        #expect(rid == "existing-id")
    }

    @Test("Request ID middleware uses custom header name")
    func requestIdCustomHeader() async throws {
        let middleware = PrismRequestIdMiddleware(headerName: "X-Trace-ID")
        var request = PrismHTTPRequest(method: .GET, uri: "/test")
        request.headers.set(name: "X-Trace-ID", value: "trace-123")

        let response = try await middleware.handle(request) { req in
            #expect(req.userInfo["requestId"] == "trace-123")
            return PrismHTTPResponse.text("ok")
        }

        #expect(response.headers.value(for: "X-Trace-ID") == "trace-123")
    }

    @Test("Logger middleware logs warning for 4xx responses")
    func loggerMiddleware4xx() async throws {
        let logger = PrismStructuredLogger(minimumLevel: .trace, destinations: [])
        let middleware = PrismLoggerMiddleware(logger: logger)
        let request = PrismHTTPRequest(method: .GET, uri: "/not-found")

        _ = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound, body: .text("not found"))
        }

        let entries = await logger.entries
        #expect(entries[1].level == .warning)
    }

    @Test("Logger middleware includes request size metadata")
    func loggerMiddlewareRequestSize() async throws {
        let logger = PrismStructuredLogger(minimumLevel: .trace, destinations: [])
        let middleware = PrismLoggerMiddleware(logger: logger)
        var request = PrismHTTPRequest(method: .POST, uri: "/data")
        request.body = Data("hello world".utf8)
        request.headers.set(name: PrismHTTPHeaders.contentLength, value: "11")

        _ = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        let entries = await logger.entries
        #expect(entries[0].metadata["requestSize"] == "11")
    }

    @Test("Logger middleware includes response size metadata")
    func loggerMiddlewareResponseSize() async throws {
        let logger = PrismStructuredLogger(minimumLevel: .trace, destinations: [])
        let middleware = PrismLoggerMiddleware(logger: logger)
        let request = PrismHTTPRequest(method: .GET, uri: "/data")

        _ = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("some response body")
        }

        let entries = await logger.entries
        #expect(entries[1].metadata["responseSize"] != nil)
        #expect(entries[1].metadata["responseSize"] != "0")
    }

    @Test("Logger middleware with request body logging")
    func loggerMiddlewareRequestBodyLogging() async throws {
        let logger = PrismStructuredLogger(minimumLevel: .trace, destinations: [])
        let middleware = PrismLoggerMiddleware(logger: logger, logRequestBody: true)
        var request = PrismHTTPRequest(method: .POST, uri: "/data")
        request.body = Data("{\"key\":\"value\"}".utf8)
        request.headers.set(name: PrismHTTPHeaders.contentLength, value: "15")

        _ = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }

        let entries = await logger.entries
        #expect(entries[0].metadata["requestBody"]?.contains("key") == true)
    }

    @Test("File log destination creates file if needed")
    func fileLogDestinationCreatesFile() {
        let tmpPath = NSTemporaryDirectory() + "prism_log_create_\(UUID().uuidString).log"
        defer { try? FileManager.default.removeItem(atPath: tmpPath) }

        #expect(!FileManager.default.fileExists(atPath: tmpPath))
        _ = PrismFileLogDestination(filePath: tmpPath)
        #expect(FileManager.default.fileExists(atPath: tmpPath))
    }

    @Test("Log format enum has correct cases")
    func logFormatEnum() {
        let text = PrismLogFormat.text
        let json = PrismLogFormat.json
        #expect(text != json)
    }
}
