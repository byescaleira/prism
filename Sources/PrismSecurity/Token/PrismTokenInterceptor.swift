import Foundation

/// Intercepts URL requests to attach Bearer authorization headers.
///
/// ```swift
/// let interceptor = PrismTokenInterceptor(tokenManager: manager)
/// let authorizedRequest = try await interceptor.intercept(request)
/// ```
public struct PrismTokenInterceptor: Sendable {
    private let tokenManager: PrismTokenManager
    private let headerName: String

    /// Creates a token interceptor.
    /// - Parameters:
    ///   - tokenManager: Token manager providing valid tokens.
    ///   - headerName: Authorization header name. Defaults to "Authorization".
    public init(
        tokenManager: PrismTokenManager,
        headerName: String = "Authorization"
    ) {
        self.tokenManager = tokenManager
        self.headerName = headerName
    }

    /// Adds Bearer authorization to a request.
    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        let token = try await tokenManager.validAccessToken()
        var authorizedRequest = request
        authorizedRequest.setValue("Bearer \(token)", forHTTPHeaderField: headerName)
        return authorizedRequest
    }

    /// Whether the manager currently has stored tokens.
    public var hasTokens: Bool {
        get async { await tokenManager.hasTokens }
    }
}
