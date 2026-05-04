// MARK: - PrismServer Middleware Template
// Usage: Copy, rename, customize.

import PrismFoundation

public struct PrismCustomMiddleware: PrismMiddleware, Sendable {
    private let config: Config

    public init(config: Config = .default) {
        self.config = config
    }

    public func handle(
        _ request: PrismHTTPRequest,
        next: @Sendable (PrismHTTPRequest) async throws -> PrismHTTPResponse
    ) async throws -> PrismHTTPResponse {
        // --- Pre-processing ---
        // e.g., validate headers, log request, check auth

        let response = try await next(request)

        // --- Post-processing ---
        // e.g., add headers, log response, transform body

        return response
    }
}

// MARK: - Config

extension PrismCustomMiddleware {
    public struct Config: Sendable {
        public let enabled: Bool

        public static let `default` = Config(enabled: true)

        public init(enabled: Bool) {
            self.enabled = enabled
        }
    }
}
