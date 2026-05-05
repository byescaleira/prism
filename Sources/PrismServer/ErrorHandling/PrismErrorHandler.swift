import Foundation

/// Protocol for application-level errors that map to HTTP responses.
public protocol PrismHTTPErrorResponse: Error, Sendable {
    /// The HTTP status code for this error.
    var statusCode: PrismHTTPStatus { get }
    /// A machine-readable error code string.
    var errorCode: String { get }
    /// A human-readable error message.
    var message: String { get }
    /// Optional additional details about the error.
    var details: [String: String]? { get }
}

extension PrismHTTPErrorResponse {
    /// Default implementation returning nil details.
    public var details: [String: String]? { nil }

    /// Converts to a structured JSON response.
    public func toResponse() -> PrismHTTPResponse {
        var dict: [String: Any] = [
            "error": errorCode,
            "message": message,
        ]
        if let details { dict["details"] = details }
        let data = (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/json; charset=utf-8")
        headers.set(name: "Content-Length", value: "\(data.count)")
        return PrismHTTPResponse(status: statusCode, headers: headers, body: .data(data))
    }
}

/// Common HTTP errors with structured responses.
public struct PrismAppError: PrismHTTPErrorResponse {
    /// The HTTP status code for this error.
    public let statusCode: PrismHTTPStatus
    /// A machine-readable error code string.
    public let errorCode: String
    /// A human-readable error message.
    public let message: String
    /// Optional additional details about the error.
    public let details: [String: String]?

    /// Creates an application error with the given status, code, message, and optional details.
    public init(status: PrismHTTPStatus, code: String, message: String, details: [String: String]? = nil) {
        self.statusCode = status
        self.errorCode = code
        self.message = message
        self.details = details
    }

    /// Creates a 400 Bad Request error.
    public static func badRequest(_ message: String, code: String = "BAD_REQUEST") -> PrismAppError {
        PrismAppError(status: .badRequest, code: code, message: message)
    }

    /// Creates a 401 Unauthorized error.
    public static func unauthorized(_ message: String = "Unauthorized", code: String = "UNAUTHORIZED") -> PrismAppError
    {
        PrismAppError(status: .unauthorized, code: code, message: message)
    }

    /// Creates a 403 Forbidden error.
    public static func forbidden(_ message: String = "Forbidden", code: String = "FORBIDDEN") -> PrismAppError {
        PrismAppError(status: .forbidden, code: code, message: message)
    }

    /// Creates a 404 Not Found error.
    public static func notFound(_ message: String = "Not Found", code: String = "NOT_FOUND") -> PrismAppError {
        PrismAppError(status: .notFound, code: code, message: message)
    }

    /// Creates a 409 Conflict error.
    public static func conflict(_ message: String, code: String = "CONFLICT") -> PrismAppError {
        PrismAppError(status: .conflict, code: code, message: message)
    }

    /// Creates a 500 Internal Server Error.
    public static func internalError(_ message: String = "Internal Server Error", code: String = "INTERNAL_ERROR")
        -> PrismAppError
    {
        PrismAppError(status: .internalServerError, code: code, message: message)
    }
}

/// Global error handling middleware.
public struct PrismErrorMiddleware: PrismMiddleware, Sendable {
    private let includeStackTrace: Bool
    private let customHandler: (@Sendable (Error, PrismHTTPRequest) -> PrismHTTPResponse?)?

    /// Creates an error middleware with optional stack trace inclusion and custom handler.
    public init(
        includeStackTrace: Bool = false,
        customHandler: (@Sendable (Error, PrismHTTPRequest) -> PrismHTTPResponse?)? = nil
    ) {
        self.includeStackTrace = includeStackTrace
        self.customHandler = customHandler
    }

    /// Catches errors thrown by downstream handlers and converts them to structured responses.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        do {
            return try await next(request)
        } catch let error as PrismHTTPErrorResponse {
            return error.toResponse()
        } catch {
            if let handler = customHandler, let response = handler(error, request) {
                return response
            }

            var dict: [String: Any] = [
                "error": "INTERNAL_ERROR",
                "message": "An unexpected error occurred",
            ]

            if includeStackTrace {
                dict["debug"] = "\(error)"
            }

            let data = (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
            var headers = PrismHTTPHeaders()
            headers.set(name: "Content-Type", value: "application/json; charset=utf-8")
            headers.set(name: "Content-Length", value: "\(data.count)")
            return PrismHTTPResponse(status: .internalServerError, headers: headers, body: .data(data))
        }
    }
}

/// Problem Details response (RFC 7807).
public struct PrismProblemDetails: Sendable {
    /// The URI identifying the problem type.
    public let type: String
    /// A short human-readable summary of the problem.
    public let title: String
    /// The HTTP status code for this problem.
    public let status: Int
    /// A detailed explanation of the problem.
    public let detail: String?
    /// A URI identifying the specific occurrence of the problem.
    public let instance: String?

    /// Creates a problem details response with the given fields.
    public init(
        type: String = "about:blank", title: String, status: Int, detail: String? = nil, instance: String? = nil
    ) {
        self.type = type
        self.title = title
        self.status = status
        self.detail = detail
        self.instance = instance
    }

    /// Converts this problem details to an HTTP response with application/problem+json content type.
    public func toResponse() -> PrismHTTPResponse {
        var dict: [String: Any] = [
            "type": type,
            "title": title,
            "status": status,
        ]
        if let detail { dict["detail"] = detail }
        if let instance { dict["instance"] = instance }

        let data = (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/problem+json")
        headers.set(name: "Content-Length", value: "\(data.count)")
        return PrismHTTPResponse(
            status: PrismHTTPStatus(code: status, reason: title), headers: headers, body: .data(data))
    }
}
