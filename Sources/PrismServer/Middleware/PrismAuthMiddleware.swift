import Foundation

/// Token validation closure type.
public typealias PrismTokenValidator = @Sendable (String) async throws -> Bool

/// Bearer token authentication middleware.
public struct PrismAuthMiddleware: PrismMiddleware {
    private let validator: PrismTokenValidator
    private let headerName: String
    private let scheme: String

    /// Creates a new `PrismAuthMiddleware` with the specified configuration.
    public init(
        headerName: String = "Authorization",
        scheme: String = "Bearer",
        validator: @escaping PrismTokenValidator
    ) {
        self.headerName = headerName
        self.scheme = scheme
        self.validator = validator
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        guard let authHeader = request.headers.value(for: headerName) else {
            return PrismHTTPResponse(status: .unauthorized, body: .text("Missing authorization header"))
        }

        let prefix = scheme + " "
        guard authHeader.hasPrefix(prefix) else {
            return PrismHTTPResponse(status: .unauthorized, body: .text("Invalid authorization scheme"))
        }

        let token = String(authHeader.dropFirst(prefix.count))

        do {
            let isValid = try await validator(token)
            guard isValid else {
                return PrismHTTPResponse(status: .unauthorized, body: .text("Invalid token"))
            }
        } catch {
            return PrismHTTPResponse(status: .unauthorized, body: .text("Token validation failed"))
        }

        var req = request
        req.userInfo["authToken"] = token
        return try await next(req)
    }
}
