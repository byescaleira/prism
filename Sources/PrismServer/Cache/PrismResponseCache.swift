import Foundation

/// Cached HTTP response data.
struct CachedResponse: Sendable {
    let status: PrismHTTPStatus
    let headers: PrismHTTPHeaders
    let body: Data
    let etag: String
}

/// Middleware that caches GET responses with ETag and Cache-Control support.
public struct PrismResponseCacheMiddleware: PrismMiddleware {
    private let cache: PrismCache<String, CachedResponse>
    private let ttl: TimeInterval
    private let cachePredicate: @Sendable (PrismHTTPRequest) -> Bool

    /// Creates a response cache middleware with configurable size, TTL, and predicate.
    public init(
        maxEntries: Int = 500,
        ttl: TimeInterval = 60,
        cachePredicate: @escaping @Sendable (PrismHTTPRequest) -> Bool = { $0.method == .GET }
    ) {
        self.cache = PrismCache(maxEntries: maxEntries, defaultTTL: ttl)
        self.ttl = ttl
        self.cachePredicate = cachePredicate
    }

    /// Serves cached responses for matching requests or caches new ones.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        guard cachePredicate(request) else {
            return try await next(request)
        }

        let cacheKey = request.method.rawValue + ":" + request.uri

        if let cached = await cache.get(cacheKey) {
            if let ifNoneMatch = request.headers.value(for: PrismHTTPHeaders.ifNoneMatch),
               ifNoneMatch == cached.etag {
                return PrismHTTPResponse(status: .notModified)
            }

            var response = PrismHTTPResponse(status: cached.status, headers: cached.headers, body: .data(cached.body))
            response.headers.set(name: "X-Cache", value: "HIT")
            return response
        }

        var response = try await next(request)

        if response.status.code >= 200 && response.status.code < 300 {
            let bodyData = response.body.data
            let etag = "\"\(bodyData.hashValue)\""

            let cached = CachedResponse(
                status: response.status,
                headers: response.headers,
                body: bodyData,
                etag: etag
            )
            await cache.set(cacheKey, value: cached, ttl: ttl)

            response.headers.set(name: PrismHTTPHeaders.eTag, value: etag)
            response.headers.set(name: PrismHTTPHeaders.cacheControl, value: "public, max-age=\(Int(ttl))")
            response.headers.set(name: "X-Cache", value: "MISS")
        }

        return response
    }
}
