import Foundation

/// A handler that processes an HTTP request and returns a response.
public typealias PrismRouteHandler = @Sendable (PrismHTTPRequest) async throws -> PrismHTTPResponse

/// A single route definition binding an HTTP method and path pattern to a handler.
public struct PrismRoute: Sendable {
    /// The HTTP method this route handles.
    public let method: PrismHTTPMethod
    /// The path pattern with optional parameters (e.g. "/users/:id").
    public let pattern: String
    /// The path segments split for matching.
    let segments: [RouteSegment]
    /// The handler function.
    public let handler: PrismRouteHandler

    /// Creates a new `PrismRoute` with the specified configuration.
    public init(method: PrismHTTPMethod, pattern: String, handler: @escaping PrismRouteHandler) {
        self.method = method
        self.pattern = pattern
        self.segments = RouteSegment.parse(pattern)
        self.handler = handler
    }

    /// Attempts to match a request path against this route's pattern.
    /// Returns extracted parameters on success.
    func match(path: String) -> [String: String]? {
        let requestSegments = path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)

        if segments.last?.isWildcard == true {
            guard requestSegments.count >= segments.count - 1 else { return nil }
        } else {
            guard requestSegments.count == segments.count else { return nil }
        }

        var params: [String: String] = [:]

        for (i, segment) in segments.enumerated() {
            switch segment {
            case .literal(let value):
                guard i < requestSegments.count && requestSegments[i] == value else { return nil }
            case .parameter(let name):
                guard i < requestSegments.count else { return nil }
                params[name] = requestSegments[i]
            case .wildcard:
                let remaining = requestSegments[i...].joined(separator: "/")
                params["*"] = remaining
                return params
            }
        }

        return params
    }
}

/// A parsed route path segment.
enum RouteSegment: Sendable {
    case literal(String)
    case parameter(String)
    case wildcard

    var isWildcard: Bool {
        if case .wildcard = self { return true }
        return false
    }

    static func parse(_ pattern: String) -> [RouteSegment] {
        pattern
            .split(separator: "/", omittingEmptySubsequences: true)
            .map { segment in
                let s = String(segment)
                if s == "*" {
                    return .wildcard
                } else if s.hasPrefix(":") {
                    return .parameter(String(s.dropFirst()))
                } else {
                    return .literal(s)
                }
            }
    }
}
