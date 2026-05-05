import Foundation

/// Case-insensitive HTTP header storage preserving original casing.
public struct PrismHTTPHeaders: Sendable, Equatable {
    /// Compares two header collections for equality by name and value.
    public static func == (lhs: PrismHTTPHeaders, rhs: PrismHTTPHeaders) -> Bool {
        guard lhs.storage.count == rhs.storage.count else { return false }
        for (l, r) in zip(lhs.storage, rhs.storage) {
            guard l.name == r.name && l.value == r.value else { return false }
        }
        return true
    }

    private var storage: [(name: String, value: String)]

    /// Creates an HTTP headers collection from an array of name-value tuples.
    public init(_ headers: [(String, String)] = []) {
        self.storage = headers.map { (name: $0.0, value: $0.1) }
    }

    /// Returns the first value for the given header name (case-insensitive).
    public func value(for name: String) -> String? {
        let lowered = name.lowercased()
        return storage.first { $0.name.lowercased() == lowered }?.value
    }

    /// Returns all values for the given header name (case-insensitive).
    public func values(for name: String) -> [String] {
        let lowered = name.lowercased()
        return storage.filter { $0.name.lowercased() == lowered }.map(\.value)
    }

    /// Adds a header without removing existing values for that name.
    public mutating func add(name: String, value: String) {
        storage.append((name: name, value: value))
    }

    /// Sets a header, replacing any existing values for that name.
    public mutating func set(name: String, value: String) {
        remove(name: name)
        storage.append((name: name, value: value))
    }

    /// Removes all headers with the given name (case-insensitive).
    public mutating func remove(name: String) {
        let lowered = name.lowercased()
        storage.removeAll { $0.name.lowercased() == lowered }
    }

    /// All header entries as name-value pairs.
    public var entries: [(name: String, value: String)] { storage }

    /// The total number of header entries.
    public var count: Int { storage.count }

    // MARK: - Common Header Names

    /// The Content-Type header name.
    public static let contentType = "Content-Type"
    /// The Content-Length header name.
    public static let contentLength = "Content-Length"
    /// The Host header name.
    public static let host = "Host"
    /// The Connection header name.
    public static let connection = "Connection"
    /// The Authorization header name.
    public static let authorization = "Authorization"
    /// The Accept header name.
    public static let accept = "Accept"
    /// The User-Agent header name.
    public static let userAgent = "User-Agent"
    /// The Cache-Control header name.
    public static let cacheControl = "Cache-Control"
    /// The ETag header name.
    public static let eTag = "ETag"
    /// The If-None-Match header name.
    public static let ifNoneMatch = "If-None-Match"
    /// The Transfer-Encoding header name.
    public static let transferEncoding = "Transfer-Encoding"
    /// The Upgrade header name.
    public static let upgrade = "Upgrade"
    /// The Location header name.
    public static let location = "Location"
    /// The Server header name.
    public static let server = "Server"
    /// The Date header name.
    public static let date = "Date"
    /// The Set-Cookie header name.
    public static let setCookie = "Set-Cookie"
    /// The Cookie header name.
    public static let cookie = "Cookie"
}
