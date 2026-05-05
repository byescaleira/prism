import Foundation

/// HTTP response status codes as defined in RFC 7231.
public struct PrismHTTPStatus: Sendable, Equatable, Hashable {
    /// The numeric HTTP status code.
    public let code: Int
    /// The human-readable reason phrase.
    public let reason: String

    /// Creates an HTTP status with a numeric code and reason phrase.
    public init(code: Int, reason: String) {
        self.code = code
        self.reason = reason
    }

    // MARK: - 1xx Informational
    /// HTTP 100 Continue.
    public static let `continue` = PrismHTTPStatus(code: 100, reason: "Continue")
    /// HTTP 101 Switching Protocols.
    public static let switchingProtocols = PrismHTTPStatus(code: 101, reason: "Switching Protocols")

    // MARK: - 2xx Success
    /// HTTP 200 OK.
    public static let ok = PrismHTTPStatus(code: 200, reason: "OK")
    /// HTTP 201 Created.
    public static let created = PrismHTTPStatus(code: 201, reason: "Created")
    /// HTTP 202 Accepted.
    public static let accepted = PrismHTTPStatus(code: 202, reason: "Accepted")
    /// HTTP 204 No Content.
    public static let noContent = PrismHTTPStatus(code: 204, reason: "No Content")
    /// HTTP 206 Partial Content.
    public static let partialContent = PrismHTTPStatus(code: 206, reason: "Partial Content")

    // MARK: - 3xx Redirection
    /// HTTP 301 Moved Permanently.
    public static let movedPermanently = PrismHTTPStatus(code: 301, reason: "Moved Permanently")
    /// HTTP 302 Found.
    public static let found = PrismHTTPStatus(code: 302, reason: "Found")
    /// HTTP 304 Not Modified.
    public static let notModified = PrismHTTPStatus(code: 304, reason: "Not Modified")
    /// HTTP 307 Temporary Redirect.
    public static let temporaryRedirect = PrismHTTPStatus(code: 307, reason: "Temporary Redirect")
    /// HTTP 308 Permanent Redirect.
    public static let permanentRedirect = PrismHTTPStatus(code: 308, reason: "Permanent Redirect")

    // MARK: - 4xx Client Errors
    /// HTTP 400 Bad Request.
    public static let badRequest = PrismHTTPStatus(code: 400, reason: "Bad Request")
    /// HTTP 401 Unauthorized.
    public static let unauthorized = PrismHTTPStatus(code: 401, reason: "Unauthorized")
    /// HTTP 403 Forbidden.
    public static let forbidden = PrismHTTPStatus(code: 403, reason: "Forbidden")
    /// HTTP 404 Not Found.
    public static let notFound = PrismHTTPStatus(code: 404, reason: "Not Found")
    /// HTTP 405 Method Not Allowed.
    public static let methodNotAllowed = PrismHTTPStatus(code: 405, reason: "Method Not Allowed")
    /// HTTP 409 Conflict.
    public static let conflict = PrismHTTPStatus(code: 409, reason: "Conflict")
    /// HTTP 410 Gone.
    public static let gone = PrismHTTPStatus(code: 410, reason: "Gone")
    /// HTTP 429 Too Many Requests.
    public static let tooManyRequests = PrismHTTPStatus(code: 429, reason: "Too Many Requests")
    /// HTTP 422 Unprocessable Entity.
    public static let unprocessableEntity = PrismHTTPStatus(code: 422, reason: "Unprocessable Entity")
    /// HTTP 408 Request Timeout.
    public static let requestTimeout = PrismHTTPStatus(code: 408, reason: "Request Timeout")
    /// HTTP 413 Request Entity Too Large.
    public static let requestEntityTooLarge = PrismHTTPStatus(code: 413, reason: "Request Entity Too Large")
    /// HTTP 416 Range Not Satisfiable.
    public static let rangeNotSatisfiable = PrismHTTPStatus(code: 416, reason: "Range Not Satisfiable")

    // MARK: - 5xx Server Errors
    /// HTTP 500 Internal Server Error.
    public static let internalServerError = PrismHTTPStatus(code: 500, reason: "Internal Server Error")
    /// HTTP 501 Not Implemented.
    public static let notImplemented = PrismHTTPStatus(code: 501, reason: "Not Implemented")
    /// HTTP 502 Bad Gateway.
    public static let badGateway = PrismHTTPStatus(code: 502, reason: "Bad Gateway")
    /// HTTP 503 Service Unavailable.
    public static let serviceUnavailable = PrismHTTPStatus(code: 503, reason: "Service Unavailable")
    /// HTTP 504 Gateway Timeout.
    public static let gatewayTimeout = PrismHTTPStatus(code: 504, reason: "Gateway Timeout")
}
