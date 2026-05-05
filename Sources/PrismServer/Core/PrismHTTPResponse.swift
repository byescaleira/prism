import Foundation

/// An HTTP response to be sent back to the client.
public struct PrismHTTPResponse: Sendable {
    /// The HTTP status code and reason.
    public var status: PrismHTTPStatus
    /// The response headers.
    public var headers: PrismHTTPHeaders
    /// The response body.
    public var body: PrismHTTPBody

    /// Creates an HTTP response with the given status, headers, and body.
    public init(
        status: PrismHTTPStatus = .ok,
        headers: PrismHTTPHeaders = PrismHTTPHeaders(),
        body: PrismHTTPBody = .empty
    ) {
        self.status = status
        self.headers = headers
        self.body = body
    }

    // MARK: - Convenience Factories

    /// Creates a 200 OK response with a JSON-encoded body.
    public static func json<T: Encodable>(_ value: T, status: PrismHTTPStatus = .ok, encoder: JSONEncoder = JSONEncoder()) -> PrismHTTPResponse {
        do {
            let data = try encoder.encode(value)
            var headers = PrismHTTPHeaders()
            headers.set(name: PrismHTTPHeaders.contentType, value: "application/json; charset=utf-8")
            headers.set(name: PrismHTTPHeaders.contentLength, value: "\(data.count)")
            return PrismHTTPResponse(status: status, headers: headers, body: .data(data))
        } catch {
            return PrismHTTPResponse(status: .internalServerError, body: .text("Encoding error"))
        }
    }

    /// Creates a response with a plain text body.
    public static func text(_ string: String, status: PrismHTTPStatus = .ok) -> PrismHTTPResponse {
        let data = Data(string.utf8)
        var headers = PrismHTTPHeaders()
        headers.set(name: PrismHTTPHeaders.contentType, value: "text/plain; charset=utf-8")
        headers.set(name: PrismHTTPHeaders.contentLength, value: "\(data.count)")
        return PrismHTTPResponse(status: status, headers: headers, body: .data(data))
    }

    /// Creates a response with an HTML body.
    public static func html(_ string: String, status: PrismHTTPStatus = .ok) -> PrismHTTPResponse {
        let data = Data(string.utf8)
        var headers = PrismHTTPHeaders()
        headers.set(name: PrismHTTPHeaders.contentType, value: "text/html; charset=utf-8")
        headers.set(name: PrismHTTPHeaders.contentLength, value: "\(data.count)")
        return PrismHTTPResponse(status: status, headers: headers, body: .data(data))
    }

    /// Creates a redirect response.
    public static func redirect(to location: String, permanent: Bool = false) -> PrismHTTPResponse {
        var headers = PrismHTTPHeaders()
        headers.set(name: PrismHTTPHeaders.location, value: location)
        return PrismHTTPResponse(
            status: permanent ? .movedPermanently : .temporaryRedirect,
            headers: headers,
            body: .empty
        )
    }

    /// Creates a 204 No Content response.
    public static let noContent = PrismHTTPResponse(status: .noContent)

    /// Serializes this response to raw HTTP/1.1 bytes.
    public func serialize() -> Data {
        var result = Data()
        let statusLine = "HTTP/1.1 \(status.code) \(status.reason)\r\n"
        result.append(contentsOf: statusLine.utf8)

        for entry in headers.entries {
            result.append(contentsOf: "\(entry.name): \(entry.value)\r\n".utf8)
        }

        let bodyData = body.data
        if headers.value(for: PrismHTTPHeaders.contentLength) == nil && !bodyData.isEmpty {
            result.append(contentsOf: "\(PrismHTTPHeaders.contentLength): \(bodyData.count)\r\n".utf8)
        }

        if headers.value(for: PrismHTTPHeaders.server) == nil {
            result.append(contentsOf: "\(PrismHTTPHeaders.server): PrismServer\r\n".utf8)
        }

        result.append(contentsOf: "\r\n".utf8)
        result.append(bodyData)
        return result
    }
}

/// Represents the body of an HTTP response.
public enum PrismHTTPBody: Sendable {
    /// An empty body with no content.
    case empty
    /// A body containing raw binary data.
    case data(Data)
    /// A body containing a UTF-8 text string.
    case text(String)

    /// The raw bytes of the body.
    public var data: Data {
        switch self {
        case .empty: Data()
        case .data(let d): d
        case .text(let s): Data(s.utf8)
        }
    }

    /// Whether the body has content.
    public var isEmpty: Bool {
        switch self {
        case .empty: true
        case .data(let d): d.isEmpty
        case .text(let s): s.isEmpty
        }
    }
}
