import Foundation

public struct PrismCORSv2Config: Sendable {
    public let allowedOrigins: PrismCORSOriginPolicy
    public let allowedMethods: [PrismHTTPMethod]
    public let allowedHeaders: [String]
    public let exposedHeaders: [String]
    public let allowCredentials: Bool
    public let maxAge: Int
    public let preflightContinue: Bool

    public init(
        allowedOrigins: PrismCORSOriginPolicy = .any,
        allowedMethods: [PrismHTTPMethod] = [.GET, .POST, .PUT, .PATCH, .DELETE, .OPTIONS],
        allowedHeaders: [String] = ["Content-Type", "Authorization", "Accept", "X-Requested-With"],
        exposedHeaders: [String] = [],
        allowCredentials: Bool = false,
        maxAge: Int = 86400,
        preflightContinue: Bool = false
    ) {
        self.allowedOrigins = allowedOrigins
        self.allowedMethods = allowedMethods
        self.allowedHeaders = allowedHeaders
        self.exposedHeaders = exposedHeaders
        self.allowCredentials = allowCredentials
        self.maxAge = maxAge
        self.preflightContinue = preflightContinue
    }
}

public enum PrismCORSOriginPolicy: Sendable {
    case any
    case none
    case exact([String])
    case reflect
    case custom(@Sendable (String) -> Bool)

    public func isAllowed(_ origin: String) -> Bool {
        switch self {
        case .any:
            return true
        case .none:
            return false
        case .exact(let origins):
            return origins.contains(origin)
        case .reflect:
            return true
        case .custom(let check):
            return check(origin)
        }
    }

    public func headerValue(for origin: String) -> String? {
        switch self {
        case .any:
            return "*"
        case .none:
            return nil
        case .exact(let origins):
            return origins.contains(origin) ? origin : nil
        case .reflect:
            return origin
        case .custom(let check):
            return check(origin) ? origin : nil
        }
    }
}

public struct PrismCORSv2Middleware: PrismMiddleware {
    private let config: PrismCORSv2Config
    private let routeOverrides: [String: PrismCORSv2Config]

    public init(config: PrismCORSv2Config = PrismCORSv2Config(), routeOverrides: [String: PrismCORSv2Config] = [:]) {
        self.config = config
        self.routeOverrides = routeOverrides
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        let activeConfig = resolveConfig(for: request.path)

        if request.method == .OPTIONS {
            var response = PrismHTTPResponse(status: .noContent)
            addCORSHeaders(to: &response, request: request, config: activeConfig)
            addPreflightHeaders(to: &response, request: request, config: activeConfig)
            if activeConfig.preflightContinue {
                return try await next(request)
            }
            return response
        }

        var response = try await next(request)
        addCORSHeaders(to: &response, request: request, config: activeConfig)
        return response
    }

    private func resolveConfig(for path: String) -> PrismCORSv2Config {
        for (pattern, override) in routeOverrides {
            if path.hasPrefix(pattern) {
                return override
            }
        }
        return config
    }

    private func addCORSHeaders(to response: inout PrismHTTPResponse, request: PrismHTTPRequest, config: PrismCORSv2Config) {
        let origin = request.headers.value(for: "Origin") ?? ""

        if let allowedOrigin = config.allowedOrigins.headerValue(for: origin) {
            response.headers.set(name: "Access-Control-Allow-Origin", value: allowedOrigin)

            if allowedOrigin != "*" {
                response.headers.add(name: "Vary", value: "Origin")
            }
        }

        if config.allowCredentials {
            response.headers.set(name: "Access-Control-Allow-Credentials", value: "true")
        }

        if !config.exposedHeaders.isEmpty {
            response.headers.set(name: "Access-Control-Expose-Headers", value: config.exposedHeaders.joined(separator: ", "))
        }
    }

    private func addPreflightHeaders(to response: inout PrismHTTPResponse, request: PrismHTTPRequest, config: PrismCORSv2Config) {
        response.headers.set(name: "Access-Control-Allow-Methods", value: config.allowedMethods.map(\.rawValue).joined(separator: ", "))

        if let requestedHeaders = request.headers.value(for: "Access-Control-Request-Headers") {
            let requested = requestedHeaders.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            let allowed = config.allowedHeaders.map { $0.lowercased() }
            let filtered = requested.filter { allowed.contains($0) || config.allowedHeaders.contains("*") }
            if !filtered.isEmpty || config.allowedHeaders.contains("*") {
                response.headers.set(name: "Access-Control-Allow-Headers", value: config.allowedHeaders.contains("*") ? requestedHeaders : filtered.joined(separator: ", "))
            }
        } else {
            response.headers.set(name: "Access-Control-Allow-Headers", value: config.allowedHeaders.joined(separator: ", "))
        }

        response.headers.set(name: "Access-Control-Max-Age", value: "\(config.maxAge)")
    }
}
