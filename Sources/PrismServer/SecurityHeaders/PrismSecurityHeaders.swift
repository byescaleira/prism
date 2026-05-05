import Foundation

/// Configuration options for SecurityHeaders.
public struct PrismSecurityHeadersConfig: Sendable {
    /// The content type options.
    public let contentTypeOptions: String?
    /// The frame options.
    public let frameOptions: String?
    /// The xss protection.
    public let xssProtection: String?
    /// The referrer policy.
    public let referrerPolicy: String?
    /// The content security policy.
    public let contentSecurityPolicy: String?
    /// The permissions policy.
    public let permissionsPolicy: String?
    /// The cross origin embedder policy.
    public let crossOriginEmbedderPolicy: String?
    /// The cross origin opener policy.
    public let crossOriginOpenerPolicy: String?
    /// The cross origin resource policy.
    public let crossOriginResourcePolicy: String?

    /// Creates a new `PrismSecurityHeadersConfig` with the specified configuration.
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

    /// A configuration with sensible security header defaults.
    public static let `default` = PrismSecurityHeadersConfig()

    /// The `strict` constant.
    public static let strict = PrismSecurityHeadersConfig(
        contentSecurityPolicy: "default-src 'self'",
        permissionsPolicy: "camera=(), microphone=(), geolocation=()",
        crossOriginEmbedderPolicy: "require-corp",
        crossOriginOpenerPolicy: "same-origin",
        crossOriginResourcePolicy: "same-origin"
    )
}

/// Middleware that sets security-related HTTP headers on responses.
public struct PrismHelmetMiddleware: PrismMiddleware {
    private let config: PrismSecurityHeadersConfig

    /// Creates a new `PrismHelmetMiddleware` with the specified configuration.
    public init(config: PrismSecurityHeadersConfig = .default) {
        self.config = config
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        var response = try await next(request)

        if let v = config.contentTypeOptions { response.headers.set(name: "X-Content-Type-Options", value: v) }
        if let v = config.frameOptions { response.headers.set(name: "X-Frame-Options", value: v) }
        if let v = config.xssProtection { response.headers.set(name: "X-XSS-Protection", value: v) }
        if let v = config.referrerPolicy { response.headers.set(name: "Referrer-Policy", value: v) }
        if let v = config.contentSecurityPolicy { response.headers.set(name: "Content-Security-Policy", value: v) }
        if let v = config.permissionsPolicy { response.headers.set(name: "Permissions-Policy", value: v) }
        if let v = config.crossOriginEmbedderPolicy {
            response.headers.set(name: "Cross-Origin-Embedder-Policy", value: v)
        }
        if let v = config.crossOriginOpenerPolicy { response.headers.set(name: "Cross-Origin-Opener-Policy", value: v) }
        if let v = config.crossOriginResourcePolicy {
            response.headers.set(name: "Cross-Origin-Resource-Policy", value: v)
        }

        return response
    }
}
