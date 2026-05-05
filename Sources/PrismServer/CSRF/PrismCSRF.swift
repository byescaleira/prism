import Foundation

/// Configuration for CSRF protection middleware.
public struct PrismCSRFConfig: Sendable {
    /// The byte length of generated CSRF tokens.
    public let tokenLength: Int
    /// The name of the cookie storing the CSRF token.
    public let cookieName: String
    /// The header name used to submit the CSRF token.
    public let headerName: String
    /// The form field name used to submit the CSRF token.
    public let formFieldName: String
    /// HTTP methods exempt from CSRF validation.
    public let safeMethods: Set<PrismHTTPMethod>
    /// Whether the CSRF cookie requires a secure connection.
    public let secureCookie: Bool
    /// The path scope for the CSRF cookie.
    public let cookiePath: String

    /// Creates a CSRF configuration with the specified options.
    public init(
        tokenLength: Int = 32,
        cookieName: String = "_csrf",
        headerName: String = "X-CSRF-Token",
        formFieldName: String = "_token",
        safeMethods: Set<PrismHTTPMethod> = [.GET, .HEAD, .OPTIONS],
        secureCookie: Bool = true,
        cookiePath: String = "/"
    ) {
        self.tokenLength = tokenLength
        self.cookieName = cookieName
        self.headerName = headerName
        self.formFieldName = formFieldName
        self.safeMethods = safeMethods
        self.secureCookie = secureCookie
        self.cookiePath = cookiePath
    }
}

/// Errors thrown during CSRF validation.
public enum PrismCSRFError: Error, Sendable {
    /// No CSRF token was provided in the request.
    case missingToken
    /// The submitted CSRF token does not match the expected token.
    case tokenMismatch
}

/// Middleware that validates CSRF tokens on state-changing requests.
public struct PrismCSRFMiddleware: PrismMiddleware {
    private let config: PrismCSRFConfig

    /// Creates a CSRF middleware with the given configuration.
    public init(config: PrismCSRFConfig = PrismCSRFConfig()) {
        self.config = config
    }

    /// Validates CSRF tokens for unsafe methods and sets tokens for safe methods.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        let cookieToken = request.cookies[config.cookieName]

        if config.safeMethods.contains(request.method) {
            let token = cookieToken ?? generateToken(length: config.tokenLength)
            var req = request
            req.userInfo["csrfToken"] = token

            var response = try await next(req)

            if cookieToken == nil {
                let cookie = PrismCookie(
                    name: config.cookieName,
                    value: token,
                    path: config.cookiePath,
                    secure: config.secureCookie,
                    httpOnly: false,
                    sameSite: .strict
                )
                response.setCookie(cookie)
            }

            return response
        }

        guard let expected = cookieToken else {
            return PrismHTTPResponse(
                status: .forbidden,
                body: .text("CSRF token missing")
            )
        }

        let submitted = submittedToken(from: request)

        guard let submitted, submitted == expected else {
            return PrismHTTPResponse(
                status: .forbidden,
                body: .text("CSRF token mismatch")
            )
        }

        var req = request
        req.userInfo["csrfToken"] = expected
        return try await next(req)
    }

    private func submittedToken(from request: PrismHTTPRequest) -> String? {
        if let headerToken = request.headers.value(for: config.headerName) {
            return headerToken
        }

        if let body = request.body, let bodyString = String(data: body, encoding: .utf8) {
            for pair in bodyString.split(separator: "&") {
                let kv = pair.split(separator: "=", maxSplits: 1)
                if kv.count == 2,
                    String(kv[0]).removingPercentEncoding == config.formFieldName
                {
                    return String(kv[1]).removingPercentEncoding
                }
            }
        }

        return nil
    }

    private func generateToken(length: Int) -> String {
        var rng = SystemRandomNumberGenerator()
        var bytes = [UInt8](repeating: 0, count: length)
        for i in 0..<length {
            bytes[i] = UInt8.random(in: 0...255, using: &rng)
        }
        return Data(bytes)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
