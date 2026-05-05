import Foundation

/// Protocol for rate limit storage backends.
public protocol PrismRateLimitStore: Sendable {
    func getWindowHits(key: String, windowStart: Date) async -> Int
    func recordHit(key: String, at date: Date) async
    func reset(key: String) async
}

/// In-memory sliding window rate limit store.
public actor PrismMemoryRateLimitStore: PrismRateLimitStore {
    private var hits: [String: [Date]] = [:]

    /// Creates a new `PrismMemoryRateLimitStore` with the specified configuration.
    public init() {}

    /// Returns the number of hits for the key within the given time window.
    public func getWindowHits(key: String, windowStart: Date) -> Int {
        guard let timestamps = hits[key] else { return 0 }
        return timestamps.filter { $0 >= windowStart }.count
    }

    /// Records a rate limit hit for the key at the specified time.
    public func recordHit(key: String, at date: Date) {
        hits[key, default: []].append(date)
        prune(key: key, before: date.addingTimeInterval(-3600))
    }

    /// Resets to the initial state.
    public func reset(key: String) {
        hits.removeValue(forKey: key)
    }

    private func prune(key: String, before cutoff: Date) {
        hits[key]?.removeAll { $0 < cutoff }
    }
}

/// Configuration for sliding window rate limiting.
public struct PrismRateLimitConfig: Sendable {
    /// The window seconds.
    public let windowSeconds: Double
    /// The max requests.
    public let maxRequests: Int
    /// The key extractor.
    public let keyExtractor: @Sendable (PrismHTTPRequest) -> String

    /// Creates a new `PrismRateLimitConfig` with the specified configuration.
    public init(windowSeconds: Double, maxRequests: Int, keyExtractor: @escaping @Sendable (PrismHTTPRequest) -> String) {
        self.windowSeconds = windowSeconds
        self.maxRequests = maxRequests
        self.keyExtractor = keyExtractor
    }

    /// Creates a rate limit config keyed by client IP address.
    public static func perIP(max: Int, windowSeconds: Double = 60) -> PrismRateLimitConfig {
        PrismRateLimitConfig(windowSeconds: windowSeconds, maxRequests: max) { request in
            request.headers.value(for: "X-Forwarded-For")?.split(separator: ",").first.map(String.init) ?? "unknown"
        }
    }

    /// Creates a rate limit config keyed by the specified header value.
    public static func perHeader(_ header: String, max: Int, windowSeconds: Double = 60) -> PrismRateLimitConfig {
        PrismRateLimitConfig(windowSeconds: windowSeconds, maxRequests: max) { request in
            request.headers.value(for: header) ?? "anonymous"
        }
    }

    /// Creates a global rate limit config shared across all clients.
    public static func global(max: Int, windowSeconds: Double = 60) -> PrismRateLimitConfig {
        PrismRateLimitConfig(windowSeconds: windowSeconds, maxRequests: max) { _ in "global" }
    }
}

/// Sliding window rate limiting middleware with standard rate limit headers.
public struct PrismSlidingWindowMiddleware: PrismMiddleware, Sendable {
    private let store: any PrismRateLimitStore
    private let config: PrismRateLimitConfig

    /// Creates a new `PrismSlidingWindowMiddleware` with the specified configuration.
    public init(store: any PrismRateLimitStore, config: PrismRateLimitConfig) {
        self.store = store
        self.config = config
    }

    /// Creates a new `PrismSlidingWindowMiddleware` with the specified configuration.
    public init(config: PrismRateLimitConfig) {
        self.store = PrismMemoryRateLimitStore()
        self.config = config
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        let key = config.keyExtractor(request)
        let now = Date()
        let windowStart = now.addingTimeInterval(-config.windowSeconds)

        let hits = await store.getWindowHits(key: key, windowStart: windowStart)

        let resetTime = Int(now.timeIntervalSince1970 + config.windowSeconds)
        let remaining = max(0, config.maxRequests - hits - 1)

        if hits >= config.maxRequests {
            var headers = PrismHTTPHeaders()
            headers.set(name: "Content-Type", value: "application/json; charset=utf-8")
            headers.set(name: "X-RateLimit-Limit", value: "\(config.maxRequests)")
            headers.set(name: "X-RateLimit-Remaining", value: "0")
            headers.set(name: "X-RateLimit-Reset", value: "\(resetTime)")
            headers.set(name: "Retry-After", value: "\(Int(config.windowSeconds))")
            let body = Data("{\"error\":\"RATE_LIMITED\",\"message\":\"Too many requests\"}".utf8)
            headers.set(name: "Content-Length", value: "\(body.count)")
            return PrismHTTPResponse(status: .tooManyRequests, headers: headers, body: .data(body))
        }

        await store.recordHit(key: key, at: now)
        var response = try await next(request)

        response.headers.set(name: "X-RateLimit-Limit", value: "\(config.maxRequests)")
        response.headers.set(name: "X-RateLimit-Remaining", value: "\(remaining)")
        response.headers.set(name: "X-RateLimit-Reset", value: "\(resetTime)")

        return response
    }
}
