import Foundation

/// HTTP response status codes as defined in RFC 7231.
public struct PrismHTTPStatus: Sendable, Equatable, Hashable {
    /// The numeric HTTP status code.
    public let code: Int
    /// The human-readable reason phrase.
    public let reason: String

    public init(code: Int, reason: String) {
        self.code = code
        self.reason = reason
    }

    // MARK: - 1xx Informational
    public static let `continue` = PrismHTTPStatus(code: 100, reason: "Continue")
    public static let switchingProtocols = PrismHTTPStatus(code: 101, reason: "Switching Protocols")

    // MARK: - 2xx Success
    public static let ok = PrismHTTPStatus(code: 200, reason: "OK")
    public static let created = PrismHTTPStatus(code: 201, reason: "Created")
    public static let accepted = PrismHTTPStatus(code: 202, reason: "Accepted")
    public static let noContent = PrismHTTPStatus(code: 204, reason: "No Content")
    public static let partialContent = PrismHTTPStatus(code: 206, reason: "Partial Content")

    // MARK: - 3xx Redirection
    public static let movedPermanently = PrismHTTPStatus(code: 301, reason: "Moved Permanently")
    public static let found = PrismHTTPStatus(code: 302, reason: "Found")
    public static let notModified = PrismHTTPStatus(code: 304, reason: "Not Modified")
    public static let temporaryRedirect = PrismHTTPStatus(code: 307, reason: "Temporary Redirect")
    public static let permanentRedirect = PrismHTTPStatus(code: 308, reason: "Permanent Redirect")

    // MARK: - 4xx Client Errors
    public static let badRequest = PrismHTTPStatus(code: 400, reason: "Bad Request")
    public static let unauthorized = PrismHTTPStatus(code: 401, reason: "Unauthorized")
    public static let forbidden = PrismHTTPStatus(code: 403, reason: "Forbidden")
    public static let notFound = PrismHTTPStatus(code: 404, reason: "Not Found")
    public static let methodNotAllowed = PrismHTTPStatus(code: 405, reason: "Method Not Allowed")
    public static let conflict = PrismHTTPStatus(code: 409, reason: "Conflict")
    public static let gone = PrismHTTPStatus(code: 410, reason: "Gone")
    public static let tooManyRequests = PrismHTTPStatus(code: 429, reason: "Too Many Requests")
    public static let unprocessableEntity = PrismHTTPStatus(code: 422, reason: "Unprocessable Entity")
    public static let requestTimeout = PrismHTTPStatus(code: 408, reason: "Request Timeout")
    public static let requestEntityTooLarge = PrismHTTPStatus(code: 413, reason: "Request Entity Too Large")
    public static let rangeNotSatisfiable = PrismHTTPStatus(code: 416, reason: "Range Not Satisfiable")

    // MARK: - 5xx Server Errors
    public static let internalServerError = PrismHTTPStatus(code: 500, reason: "Internal Server Error")
    public static let notImplemented = PrismHTTPStatus(code: 501, reason: "Not Implemented")
    public static let badGateway = PrismHTTPStatus(code: 502, reason: "Bad Gateway")
    public static let serviceUnavailable = PrismHTTPStatus(code: 503, reason: "Service Unavailable")
    public static let gatewayTimeout = PrismHTTPStatus(code: 504, reason: "Gateway Timeout")
}
