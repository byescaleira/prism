import Foundation

/// A parsed HTTP request received by the server.
public struct PrismHTTPRequest: Sendable {
    /// The HTTP method (GET, POST, etc.).
    public let method: PrismHTTPMethod
    /// The raw request path including query string.
    public let uri: String
    /// The path component without query string.
    public let path: String
    /// The HTTP version string (e.g. "HTTP/1.1").
    public let version: String
    /// The request headers.
    public var headers: PrismHTTPHeaders
    /// The raw request body data.
    public var body: Data?
    /// Route path parameters extracted by the router (e.g. ":id" → "42").
    public var parameters: [String: String]
    /// Parsed query string parameters.
    public let queryParameters: [String: String]
    /// User-defined storage for passing data through middleware.
    public var userInfo: [String: String]

    /// Creates an HTTP request with the given method, URI, version, headers, body, and parameters.
    public init(
        method: PrismHTTPMethod,
        uri: String,
        version: String = "HTTP/1.1",
        headers: PrismHTTPHeaders = PrismHTTPHeaders(),
        body: Data? = nil,
        parameters: [String: String] = [:],
        userInfo: [String: String] = [:]
    ) {
        self.method = method
        self.uri = uri
        self.version = version
        self.headers = headers
        self.body = body
        self.parameters = parameters
        self.userInfo = userInfo

        let parts = uri.split(separator: "?", maxSplits: 1)
        self.path = String(parts.first ?? "/")

        var qp: [String: String] = [:]
        if parts.count == 2 {
            let queryString = String(parts[1])
            for pair in queryString.split(separator: "&") {
                let kv = pair.split(separator: "=", maxSplits: 1)
                if kv.count == 2 {
                    let key = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                    let value = String(kv[1]).removingPercentEncoding ?? String(kv[1])
                    qp[key] = value
                } else if kv.count == 1 {
                    let key = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                    qp[key] = ""
                }
            }
        }
        self.queryParameters = qp
    }

    /// Returns the value of a route parameter by name.
    public func parameter(_ name: String) -> String? {
        parameters[name]
    }

    /// Returns the value of a query parameter by name.
    public func query(_ name: String) -> String? {
        queryParameters[name]
    }

    /// Returns the Content-Type header value.
    public var contentType: String? {
        headers.value(for: PrismHTTPHeaders.contentType)
    }

    /// Returns the Content-Length parsed as an integer.
    public var contentLength: Int? {
        headers.value(for: PrismHTTPHeaders.contentLength).flatMap(Int.init)
    }
}
