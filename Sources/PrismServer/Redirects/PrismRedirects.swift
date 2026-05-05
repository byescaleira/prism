import Foundation

/// A URL redirect rule mapping a source path to a destination.
public struct PrismRedirectRule: Sendable {
    /// The source.
    public let source: String
    /// The destination.
    public let destination: String
    /// The status code.
    public let statusCode: Int
    /// The preserve query string.
    public let preserveQueryString: Bool
    /// The is regex.
    public let isRegex: Bool

    /// Creates a new `PrismRedirectRule` with the specified configuration.
    public init(
        source: String,
        destination: String,
        statusCode: Int = 301,
        preserveQueryString: Bool = true,
        isRegex: Bool = false
    ) {
        self.source = source
        self.destination = destination
        self.statusCode = statusCode
        self.preserveQueryString = preserveQueryString
        self.isRegex = isRegex
    }

    /// Creates a 301 permanent redirect rule.
    public static func permanent(from source: String, to destination: String, preserveQuery: Bool = true) -> PrismRedirectRule {
        PrismRedirectRule(source: source, destination: destination, statusCode: 301, preserveQueryString: preserveQuery)
    }

    /// Creates a 302 temporary redirect rule.
    public static func temporary(from source: String, to destination: String, preserveQuery: Bool = true) -> PrismRedirectRule {
        PrismRedirectRule(source: source, destination: destination, statusCode: 302, preserveQueryString: preserveQuery)
    }

    /// Creates a 307 temporary redirect rule that preserves the query string.
    public static func seeOther(from source: String, to destination: String) -> PrismRedirectRule {
        PrismRedirectRule(source: source, destination: destination, statusCode: 307, preserveQueryString: true)
    }

    /// Creates a regex-based redirect rule.
    public static func pattern(from regex: String, to destination: String, statusCode: Int = 301) -> PrismRedirectRule {
        PrismRedirectRule(source: regex, destination: destination, statusCode: statusCode, preserveQueryString: true, isRegex: true)
    }

    func match(path: String) -> String? {
        if isRegex {
            return matchRegex(path: path)
        }
        return matchExact(path: path)
    }

    private func matchExact(path: String) -> String? {
        if source.contains(":") {
            return matchParameterized(path: path)
        }
        guard path == source else { return nil }
        return destination
    }

    private func matchParameterized(path: String) -> String? {
        let sourceComponents = source.split(separator: "/", omittingEmptySubsequences: true)
        let pathComponents = path.split(separator: "/", omittingEmptySubsequences: true)

        guard sourceComponents.count == pathComponents.count else { return nil }

        var params: [String: String] = [:]

        for (s, p) in zip(sourceComponents, pathComponents) {
            if s.hasPrefix(":") {
                let paramName = String(s.dropFirst())
                params[paramName] = String(p)
            } else if s != p {
                return nil
            }
        }

        var result = destination
        for (key, value) in params {
            result = result.replacingOccurrences(of: ":\(key)", with: value)
        }
        return result
    }

    private func matchRegex(path: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: source) else { return nil }
        let range = NSRange(path.startIndex..., in: path)
        guard let match = regex.firstMatch(in: path, range: range) else { return nil }

        var result = destination
        for i in 0..<match.numberOfRanges {
            if let captureRange = Range(match.range(at: i), in: path) {
                let capture = String(path[captureRange])
                result = result.replacingOccurrences(of: "$\(i)", with: capture)
            }
        }
        return result
    }
}

/// Middleware that applies URL redirect rules to incoming requests.
public struct PrismRedirectMiddleware: PrismMiddleware {
    private let rules: [PrismRedirectRule]
    private let trailingSlashAction: PrismTrailingSlashAction

    /// Creates a new `PrismRedirectMiddleware` with the specified configuration.
    public init(rules: [PrismRedirectRule], trailingSlashAction: PrismTrailingSlashAction = .none) {
        self.rules = rules
        self.trailingSlashAction = trailingSlashAction
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        let path = request.path

        if let redirect = applyTrailingSlash(path: path, uri: request.uri) {
            return redirect
        }

        for rule in rules {
            if let destination = rule.match(path: path) {
                var finalDest = destination
                if rule.preserveQueryString {
                    if let qIdx = request.uri.firstIndex(of: "?") {
                        let qs = String(request.uri[qIdx...])
                        if finalDest.contains("?") {
                            finalDest += "&" + qs.dropFirst()
                        } else {
                            finalDest += qs
                        }
                    }
                }

                let reason: String
                switch rule.statusCode {
                case 301: reason = "Moved Permanently"
                case 302: reason = "Found"
                case 307: reason = "Temporary Redirect"
                case 308: reason = "Permanent Redirect"
                default: reason = "Redirect"
                }

                var headers = PrismHTTPHeaders()
                headers.set(name: PrismHTTPHeaders.location, value: finalDest)
                return PrismHTTPResponse(
                    status: PrismHTTPStatus(code: rule.statusCode, reason: reason),
                    headers: headers,
                    body: .empty
                )
            }
        }

        return try await next(request)
    }

    private func applyTrailingSlash(path: String, uri: String) -> PrismHTTPResponse? {
        guard path != "/" else { return nil }
        switch trailingSlashAction {
        case .none:
            return nil
        case .add:
            guard !path.hasSuffix("/") else { return nil }
            var newPath = path + "/"
            if let qIdx = uri.firstIndex(of: "?") {
                newPath += String(uri[qIdx...])
            }
            var headers = PrismHTTPHeaders()
            headers.set(name: PrismHTTPHeaders.location, value: newPath)
            return PrismHTTPResponse(status: .movedPermanently, headers: headers, body: .empty)
        case .remove:
            guard path.hasSuffix("/") else { return nil }
            var newPath = String(path.dropLast())
            if newPath.isEmpty { return nil }
            if let qIdx = uri.firstIndex(of: "?") {
                newPath += String(uri[qIdx...])
            }
            var headers = PrismHTTPHeaders()
            headers.set(name: PrismHTTPHeaders.location, value: newPath)
            return PrismHTTPResponse(status: .movedPermanently, headers: headers, body: .empty)
        }
    }
}

/// Actions for normalizing trailing slashes in request paths.
public enum PrismTrailingSlashAction: Sendable {
    case none
    case add
    case remove
}
