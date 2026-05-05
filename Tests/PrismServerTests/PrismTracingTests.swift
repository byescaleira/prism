import Foundation
import Testing

@testable import PrismServer

@Suite("PrismRequestID Tests")
struct PrismRequestIDTests {

    @Test("Generate creates unique IDs")
    func uniqueGeneration() {
        let id1 = PrismRequestID.generate()
        let id2 = PrismRequestID.generate()
        #expect(id1.value != id2.value)
    }

    @Test("Value is lowercased UUID format")
    func lowercased() {
        let id = PrismRequestID.generate()
        #expect(id.value == id.value.lowercased())
        #expect(!id.value.isEmpty)
    }

    @Test("Description returns value")
    func description() {
        let id = PrismRequestID("test-id")
        #expect(id.description == "test-id")
    }

    @Test("Init with custom value")
    func customValue() {
        let id = PrismRequestID("my-custom-id")
        #expect(id.value == "my-custom-id")
    }
}

@Suite("PrismTraceContext Tests")
struct PrismTraceContextTests {

    @Test("Stores all fields")
    func storesFields() {
        let context = PrismTraceContext(
            requestID: "req-123",
            correlationID: "corr-456",
            parentID: "parent-789",
            extra: ["key": "val"]
        )
        #expect(context.requestID == "req-123")
        #expect(context.correlationID == "corr-456")
        #expect(context.parentID == "parent-789")
        #expect(context.extra["key"] == "val")
    }

    @Test("Defaults nil for optional fields")
    func defaults() {
        let context = PrismTraceContext(requestID: "req-1")
        #expect(context.correlationID == nil)
        #expect(context.parentID == nil)
        #expect(context.extra.isEmpty)
    }

    @Test("Elapsed returns positive duration")
    func elapsed() {
        let context = PrismTraceContext(requestID: "req-1")
        let duration = context.elapsed
        #expect(duration >= .zero)
    }
}

@Suite("PrismTracingMiddleware Tests")
struct PrismTracingMiddlewareTests {

    @Test("Adds X-Request-ID to response")
    func addsRequestID() async throws {
        let middleware = PrismTracingMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        let requestID = response.headers.value(for: "X-Request-ID")
        #expect(requestID != nil)
        #expect(!requestID!.isEmpty)
    }

    @Test("Reads existing X-Request-ID from request")
    func readsExisting() async throws {
        let middleware = PrismTracingMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/test")
        request.headers.set(name: "X-Request-ID", value: "existing-id-123")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-Request-ID") == "existing-id-123")
    }

    @Test("Generates ID when missing")
    func generatesWhenMissing() async throws {
        let middleware = PrismTracingMiddleware(generateIfMissing: true)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        let requestID = response.headers.value(for: "X-Request-ID")
        #expect(requestID != nil)
    }

    @Test("Skips when generateIfMissing false and no header")
    func skipsGeneration() async throws {
        let middleware = PrismTracingMiddleware(generateIfMissing: false)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        let requestID = response.headers.value(for: "X-Request-ID")
        #expect(requestID == nil)
    }

    @Test("Propagates correlation ID")
    func correlationID() async throws {
        let middleware = PrismTracingMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/test")
        request.headers.set(name: "X-Correlation-ID", value: "corr-abc")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-Correlation-ID") == "corr-abc")
    }

    @Test("Sets trace context in userInfo")
    func setsTraceContext() async throws {
        let middleware = PrismTracingMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/test")
        request.headers.set(name: "X-Request-ID", value: "trace-test")
        _ = try await middleware.handle(request) { req in
            #expect(req.userInfo["traceContext.requestID"] == "trace-test")
            return .text("ok")
        }
    }

    @Test("Custom header name")
    func customHeaderName() async throws {
        let middleware = PrismTracingMiddleware(headerName: "X-Trace-ID")
        var request = PrismHTTPRequest(method: .GET, uri: "/test")
        request.headers.set(name: "X-Trace-ID", value: "custom-trace")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.headers.value(for: "X-Trace-ID") == "custom-trace")
    }
}

@Suite("PrismTracingLogger Tests")
struct PrismTracingLoggerTests {

    @Test("Formats message with request ID")
    func formatMessage() {
        let logger = PrismTracingLogger(requestID: "req-123")
        let formatted = logger.log("Request processed")
        #expect(formatted == "[req-123] Request processed")
    }

    @Test("Formats with correlation ID")
    func formatWithCorrelation() {
        let logger = PrismTracingLogger(requestID: "req-1", correlationID: "corr-2")
        let formatted = logger.log("Done")
        #expect(formatted == "[req-1] [corr-2] Done")
    }

    @Test("Init from trace context")
    func fromContext() {
        let context = PrismTraceContext(requestID: "ctx-id", correlationID: "ctx-corr")
        let logger = PrismTracingLogger(context: context)
        #expect(logger.requestID == "ctx-id")
        #expect(logger.correlationID == "ctx-corr")
    }
}
