import Foundation

/// Represents an API version with major and optional minor component.
public struct PrismAPIVersion: Sendable, Comparable, Hashable, CustomStringConvertible {
    /// The major.
    public let major: Int
    /// The minor.
    public let minor: Int

    /// Creates a new `PrismAPIVersion` with the specified configuration.
    public init(major: Int, minor: Int = 0) {
        self.major = major
        self.minor = minor
    }

    /// The description.
    public var description: String {
        minor == 0 ? "v\(major)" : "v\(major).\(minor)"
    }

    /// Parses a version string like "v1", "v1.2", "1", "1.2".
    public static func parse(_ string: String) -> PrismAPIVersion? {
        let trimmed =
            string.hasPrefix("v") || string.hasPrefix("V")
            ? String(string.dropFirst())
            : string
        let parts = trimmed.split(separator: ".")
        guard let major = parts.first.flatMap({ Int($0) }) else { return nil }
        let minor = parts.count > 1 ? Int(parts[1]) ?? 0 : 0
        return PrismAPIVersion(major: major, minor: minor)
    }

    /// Compares two API versions using semantic versioning order.
    public static func < (lhs: PrismAPIVersion, rhs: PrismAPIVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        return lhs.minor < rhs.minor
    }
}

/// Strategy for extracting the API version from a request.
public enum PrismVersioningStrategy: Sendable {
    case urlPrefix
    case header(String = "Accept-Version")
    case queryParam(String = "version")
}

/// Middleware that extracts API version from the request.
public struct PrismVersioningMiddleware: PrismMiddleware, Sendable {
    private let strategy: PrismVersioningStrategy
    private let supportedVersions: [PrismAPIVersion]
    private let defaultVersion: PrismAPIVersion

    /// Creates a new `PrismVersioningMiddleware` with the specified configuration.
    public init(
        strategy: PrismVersioningStrategy = .urlPrefix,
        supportedVersions: [PrismAPIVersion],
        defaultVersion: PrismAPIVersion
    ) {
        self.strategy = strategy
        self.supportedVersions = supportedVersions
        self.defaultVersion = defaultVersion
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        var req = request
        let extracted: PrismAPIVersion?

        switch strategy {
        case .urlPrefix:
            let (version, strippedPath) = extractFromURL(req.path)
            extracted = version
            if version != nil {
                req.userInfo["versionedPath"] = strippedPath
            }
        case .header(let name):
            extracted = req.headers.value(for: name).flatMap(PrismAPIVersion.parse)
        case .queryParam(let name):
            extracted = req.queryParameters[name].flatMap(PrismAPIVersion.parse)
        }

        let version = extracted ?? defaultVersion

        guard supportedVersions.contains(version) else {
            let data =
                (try? JSONSerialization.data(withJSONObject: [
                    "error": "UNSUPPORTED_VERSION",
                    "message":
                        "API version \(version) is not supported. Supported: \(supportedVersions.map(\.description).joined(separator: ", "))",
                ])) ?? Data()
            var headers = PrismHTTPHeaders()
            headers.set(name: "Content-Type", value: "application/json; charset=utf-8")
            headers.set(name: "Content-Length", value: "\(data.count)")
            return PrismHTTPResponse(status: .badRequest, headers: headers, body: .data(data))
        }

        req.userInfo["apiVersion"] = version.description
        return try await next(req)
    }

    private func extractFromURL(_ path: String) -> (PrismAPIVersion?, String) {
        let segments = path.split(separator: "/", omittingEmptySubsequences: true)
        guard let first = segments.first,
            let version = PrismAPIVersion.parse(String(first))
        else {
            return (nil, path)
        }
        let remaining = "/" + segments.dropFirst().joined(separator: "/")
        return (version, remaining.isEmpty ? "/" : remaining)
    }
}

extension PrismHTTPRequest {
    /// The API version extracted by PrismVersioningMiddleware.
    public var apiVersion: PrismAPIVersion? {
        userInfo["apiVersion"].flatMap(PrismAPIVersion.parse)
    }
}

/// Routes requests to version-specific handlers.
public struct PrismVersionedRouter: Sendable {
    private var routes:
        [(version: PrismAPIVersion, method: PrismHTTPMethod, pattern: String, handler: PrismRouteHandler)]

    /// Creates a new `PrismVersionedRouter`.
    public init() {
        self.routes = []
    }

    /// Registers a handler for a specific API version.
    public mutating func route(
        version: PrismAPIVersion,
        _ method: PrismHTTPMethod,
        _ pattern: String,
        handler: @escaping PrismRouteHandler
    ) {
        routes.append((version, method, pattern, handler))
    }

    /// Finds and invokes the handler matching the request's version, method, and path.
    public func handle(_ request: PrismHTTPRequest) async throws -> PrismHTTPResponse? {
        let version = request.apiVersion
        for route in routes {
            if route.method == request.method && route.pattern == request.path {
                if let v = version, v == route.version {
                    return try await route.handler(request)
                } else if version == nil {
                    return try await route.handler(request)
                }
            }
        }
        return nil
    }
}
