import Foundation
import PrismFoundation

/// Output format options for structured logging.
public enum PrismLogFormat: Sendable {
    case text
    case json
}

/// Log destination that writes formatted entries to a file on disk.
public struct PrismFileLogDestination: PrismLogDestination {
    private let filePath: String
    private let fileHandle: FileHandle?

    /// Creates a new `PrismFileLogDestination` with the specified configuration.
    public init(filePath: String) {
        self.filePath = filePath
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil)
        }
        self.fileHandle = FileHandle(forWritingAtPath: filePath)
        self.fileHandle?.seekToEndOfFile()
    }

    /// Writes a log entry as a formatted text line to the file.
    public func write(_ entry: PrismLogEntry) {
        let line = "[\(entry.timestamp)] [\(entry.level)] [\(entry.category)] \(entry.message)\n"
        if let data = line.data(using: .utf8) {
            fileHandle?.write(data)
        }
    }
}

/// Log destination that writes entries as JSON objects to standard output.
public struct PrismJSONLogDestination: PrismLogDestination {
    /// Creates a new `PrismJSONLogDestination` with the specified configuration.
    public init() {}

    /// Writes a log entry as a JSON object to standard output.
    public func write(_ entry: PrismLogEntry) {
        var dict: [String: Any] = [
            "level": "\(entry.level)",
            "message": entry.message,
            "category": entry.category,
            "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
            "file": entry.file,
            "line": entry.line
        ]
        if !entry.metadata.isEmpty {
            dict["metadata"] = entry.metadata
        }
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
           let str = String(data: data, encoding: .utf8) {
            print(str)
        }
    }
}

/// Middleware that logs request and response details with timing.
public struct PrismLoggerMiddleware: PrismMiddleware {
    private let logger: PrismStructuredLogger
    private let logRequestBody: Bool
    private let logResponseBody: Bool

    /// Creates a new `PrismLoggerMiddleware` with the specified configuration.
    public init(
        logger: PrismStructuredLogger,
        logRequestBody: Bool = false,
        logResponseBody: Bool = false
    ) {
        self.logger = logger
        self.logRequestBody = logRequestBody
        self.logResponseBody = logResponseBody
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        let start = ContinuousClock.now
        let requestId = request.userInfo["requestId"] ?? UUID().uuidString

        var metadata: [String: String] = [
            "method": request.method.rawValue,
            "path": request.path,
            "requestId": requestId
        ]

        if let contentLength = request.contentLength {
            metadata["requestSize"] = "\(contentLength)"
        }

        if logRequestBody, let body = request.body, !body.isEmpty {
            metadata["requestBody"] = String(data: body.prefix(1024), encoding: .utf8) ?? "<binary>"
        }

        await logger.info("→ \(request.method.rawValue) \(request.path)", category: "http", metadata: metadata)

        do {
            let response = try await next(request)
            let elapsed = ContinuousClock.now - start
            let ms = elapsed.components.seconds * 1000 + Int64(elapsed.components.attoseconds / 1_000_000_000_000_000)

            var responseMeta = metadata
            responseMeta["status"] = "\(response.status.code)"
            responseMeta["duration_ms"] = "\(ms)"
            responseMeta["responseSize"] = "\(response.body.data.count)"

            let level: PrismLogLevel = response.status.code >= 500 ? .error :
                                        response.status.code >= 400 ? .warning : .info

            await logger.log(level, "← \(response.status.code) \(request.method.rawValue) \(request.path) (\(ms)ms)", category: "http", metadata: responseMeta)

            return response
        } catch {
            let elapsed = ContinuousClock.now - start
            let ms = elapsed.components.seconds * 1000 + Int64(elapsed.components.attoseconds / 1_000_000_000_000_000)

            var errorMeta = metadata
            errorMeta["error"] = "\(error)"
            errorMeta["duration_ms"] = "\(ms)"

            await logger.error("✗ \(request.method.rawValue) \(request.path) (\(ms)ms): \(error)", category: "http", metadata: errorMeta)
            throw error
        }
    }
}

/// Middleware that assigns a unique request ID to each request.
public struct PrismRequestIdMiddleware: PrismMiddleware {
    private let headerName: String

    /// Creates a new `PrismRequestIdMiddleware` with the specified configuration.
    public init(headerName: String = "X-Request-ID") {
        self.headerName = headerName
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        var req = request
        let requestId = request.headers.value(for: headerName) ?? UUID().uuidString
        req.userInfo["requestId"] = requestId

        var response = try await next(req)
        response.headers.set(name: headerName, value: requestId)
        return response
    }
}
