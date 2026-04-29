import Foundation

public struct PrismRequestTimeoutConfig: Sendable {
    public let defaultTimeout: Duration
    public let timeoutByPath: [String: Duration]
    public let timeoutByMethod: [PrismHTTPMethod: Duration]

    public init(
        defaultTimeout: Duration = .seconds(30),
        timeoutByPath: [String: Duration] = [:],
        timeoutByMethod: [PrismHTTPMethod: Duration] = [:]
    ) {
        self.defaultTimeout = defaultTimeout
        self.timeoutByPath = timeoutByPath
        self.timeoutByMethod = timeoutByMethod
    }
}

public struct PrismRequestTimeoutMiddleware: PrismMiddleware {
    private let config: PrismRequestTimeoutConfig

    public init(config: PrismRequestTimeoutConfig = PrismRequestTimeoutConfig()) {
        self.config = config
    }

    public init(timeout: Duration) {
        self.config = PrismRequestTimeoutConfig(defaultTimeout: timeout)
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        let timeout = resolveTimeout(for: request)

        do {
            return try await withThrowingTaskGroup(of: PrismHTTPResponse.self) { group in
                group.addTask {
                    try await next(request)
                }

                group.addTask {
                    try await Task.sleep(for: timeout)
                    throw PrismTimeoutError.requestTimedOut(timeout: timeout)
                }

                guard let result = try await group.next() else {
                    throw PrismTimeoutError.requestTimedOut(timeout: timeout)
                }

                group.cancelAll()
                return result
            }
        } catch is PrismTimeoutError {
            return PrismHTTPResponse(
                status: .requestTimeout,
                body: .text("Request timed out")
            )
        } catch is CancellationError {
            return PrismHTTPResponse(
                status: .requestTimeout,
                body: .text("Request timed out")
            )
        }
    }

    private func resolveTimeout(for request: PrismHTTPRequest) -> Duration {
        if let override = request.userInfo["timeout"],
           let seconds = Double(override) {
            return .milliseconds(Int(seconds * 1000))
        }

        for (pathPrefix, timeout) in config.timeoutByPath {
            if request.path.hasPrefix(pathPrefix) {
                return timeout
            }
        }

        if let methodTimeout = config.timeoutByMethod[request.method] {
            return methodTimeout
        }

        return config.defaultTimeout
    }
}

public enum PrismTimeoutError: Error, Sendable {
    case requestTimedOut(timeout: Duration)
}
