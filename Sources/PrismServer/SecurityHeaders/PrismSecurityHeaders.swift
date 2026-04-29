import Foundation

public struct PrismSecurityHeadersConfig: Sendable {
    public let contentTypeOptions: String?
    public let frameOptions: String?
    public let xssProtection: String?
    public let referrerPolicy: String?
    public let contentSecurityPolicy: String?
    public let permissionsPolicy: String?
    public let crossOriginEmbedderPolicy: String?
    public let crossOriginOpenerPolicy: String?
    public let crossOriginResourcePolicy: String?

    public init(
        contentTypeOptions: String? = "nosniff",
        frameOptions: String? = "DENY",
        xssProtection: String? = "1; mode=block",
        referrerPolicy: String? = "strict-origin-when-cross-origin",
        contentSecurityPolicy: String? = nil,
        permissionsPolicy: String? = nil,
        crossOriginEmbedderPolicy: String? = nil,
        crossOriginOpenerPolicy: String? = nil,
        crossOriginResourcePolicy: String? = nil
    ) {
        self.contentTypeOptions = contentTypeOptions
        self.frameOptions = frameOptions
        self.xssProtection = xssProtection
        self.referrerPolicy = referrerPolicy
        self.contentSecurityPolicy = contentSecurityPolicy
        self.permissionsPolicy = permissionsPolicy
        self.crossOriginEmbedderPolicy = crossOriginEmbedderPolicy
        self.crossOriginOpenerPolicy = crossOriginOpenerPolicy
        self.crossOriginResourcePolicy = crossOriginResourcePolicy
    }

    public static let `default` = PrismSecurityHeadersConfig()

    public static let strict = PrismSecurityHeadersConfig(
        contentSecurityPolicy: "default-src 'self'",
        permissionsPolicy: "camera=(), microphone=(), geolocation=()",
        crossOriginEmbedderPolicy: "require-corp",
        crossOriginOpenerPolicy: "same-origin",
        crossOriginResourcePolicy: "same-origin"
    )
}

public struct PrismHelmetMiddleware: PrismMiddleware {
    private let config: PrismSecurityHeadersConfig

    public init(config: PrismSecurityHeadersConfig = .default) {
        self.config = config
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        var response = try await next(request)

        if let v = config.contentTypeOptions { response.headers.set(name: "X-Content-Type-Options", value: v) }
        if let v = config.frameOptions { response.headers.set(name: "X-Frame-Options", value: v) }
        if let v = config.xssProtection { response.headers.set(name: "X-XSS-Protection", value: v) }
        if let v = config.referrerPolicy { response.headers.set(name: "Referrer-Policy", value: v) }
        if let v = config.contentSecurityPolicy { response.headers.set(name: "Content-Security-Policy", value: v) }
        if let v = config.permissionsPolicy { response.headers.set(name: "Permissions-Policy", value: v) }
        if let v = config.crossOriginEmbedderPolicy { response.headers.set(name: "Cross-Origin-Embedder-Policy", value: v) }
        if let v = config.crossOriginOpenerPolicy { response.headers.set(name: "Cross-Origin-Opener-Policy", value: v) }
        if let v = config.crossOriginResourcePolicy { response.headers.set(name: "Cross-Origin-Resource-Policy", value: v) }

        return response
    }
}
