import Foundation

/// Protocol for application-level errors that map to HTTP responses.
public protocol PrismHTTPErrorResponse: Error, Sendable {
    var statusCode: PrismHTTPStatus { get }
    var errorCode: String { get }
    var message: String { get }
    var details: [String: String]? { get }
}

extension PrismHTTPErrorResponse {
    public var details: [String: String]? { nil }

    /// Converts to a structured JSON response.
    public func toResponse() -> PrismHTTPResponse {
        var dict: [String: Any] = [
            "error": errorCode,
            "message": message
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
    public let statusCode: PrismHTTPStatus
    public let errorCode: String
    public let message: String
    public let details: [String: String]?

    public init(status: PrismHTTPStatus, code: String, message: String, details: [String: String]? = nil) {
        self.statusCode = status
        self.errorCode = code
        self.message = message
        self.details = details
    }

    public static func badRequest(_ message: String, code: String = "BAD_REQUEST") -> PrismAppError {
        PrismAppError(status: .badRequest, code: code, message: message)
    }

    public static func unauthorized(_ message: String = "Unauthorized", code: String = "UNAUTHORIZED") -> PrismAppError {
        PrismAppError(status: .unauthorized, code: code, message: message)
    }

    public static func forbidden(_ message: String = "Forbidden", code: String = "FORBIDDEN") -> PrismAppError {
        PrismAppError(status: .forbidden, code: code, message: message)
    }

    public static func notFound(_ message: String = "Not Found", code: String = "NOT_FOUND") -> PrismAppError {
        PrismAppError(status: .notFound, code: code, message: message)
    }

    public static func conflict(_ message: String, code: String = "CONFLICT") -> PrismAppError {
        PrismAppError(status: .conflict, code: code, message: message)
    }

    public static func internalError(_ message: String = "Internal Server Error", code: String = "INTERNAL_ERROR") -> PrismAppError {
        PrismAppError(status: .internalServerError, code: code, message: message)
    }
}

/// Global error handling middleware.
public struct PrismErrorMiddleware: PrismMiddleware, Sendable {
    private let includeStackTrace: Bool
    private let customHandler: (@Sendable (Error, PrismHTTPRequest) -> PrismHTTPResponse?)?

    public init(
        includeStackTrace: Bool = false,
        customHandler: (@Sendable (Error, PrismHTTPRequest) -> PrismHTTPResponse?)? = nil
    ) {
        self.includeStackTrace = includeStackTrace
        self.customHandler = customHandler
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
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
                "message": "An unexpected error occurred"
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
    public let type: String
    public let title: String
    public let status: Int
    public let detail: String?
    public let instance: String?

    public init(type: String = "about:blank", title: String, status: Int, detail: String? = nil, instance: String? = nil) {
        self.type = type
        self.title = title
        self.status = status
        self.detail = detail
        self.instance = instance
    }

    public func toResponse() -> PrismHTTPResponse {
        var dict: [String: Any] = [
            "type": type,
            "title": title,
            "status": status
        ]
        if let detail { dict["detail"] = detail }
        if let instance { dict["instance"] = instance }

        let data = (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/problem+json")
        headers.set(name: "Content-Length", value: "\(data.count)")
        return PrismHTTPResponse(status: PrismHTTPStatus(code: status, reason: title), headers: headers, body: .data(data))
    }
}
