import Foundation
import PrismFoundation

/// Middleware that logs each request and response with timing.
public struct PrismLoggingMiddleware: PrismMiddleware {
    private let logger: PrismStructuredLogger

    /// Creates a new `PrismLoggingMiddleware` with the specified configuration.
    public init(logger: PrismStructuredLogger = PrismStructuredLogger(destinations: [PrismConsoleLogDestination()])) {
        self.logger = logger
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        let start = ContinuousClock.now

        await logger.info(
            "\(request.method.rawValue) \(request.uri)",
            category: "http.request"
        )

        do {
            let response = try await next(request)
            let duration = ContinuousClock.now - start

            await logger.info(
                "\(request.method.rawValue) \(request.uri) → \(response.status.code) (\(duration))",
                category: "http.response"
            )

            return response
        } catch {
            let duration = ContinuousClock.now - start
            await logger.error(
                "\(request.method.rawValue) \(request.uri) → ERROR (\(duration)): \(error)",
                category: "http.response"
            )
            throw error
        }
    }
}
