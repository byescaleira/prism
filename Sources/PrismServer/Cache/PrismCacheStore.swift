import Foundation

/// Protocol for pluggable cache storage backends.
public protocol PrismCacheStore: Sendable {
    /// Retrieves cached data for the given key, or nil if missing or expired.
    func get(_ key: String) async -> Data?
    /// Stores data under the given key with an optional time-to-live.
    func set(_ key: String, value: Data, ttl: TimeInterval?) async
    /// Removes the cached entry for the given key.
    func remove(_ key: String) async
    /// Removes all cached entries.
    func clear() async
    /// Returns whether a non-expired entry exists for the given key.
    func has(_ key: String) async -> Bool
}

/// In-memory implementation of `PrismCacheStore` backed by `PrismCache`.
public actor PrismMemoryCacheStore: PrismCacheStore {
    private let cache: PrismCache<String, Data>

    /// Creates an in-memory cache store with configurable capacity and TTL.
    public init(maxEntries: Int = 1000, defaultTTL: TimeInterval = 300) {
        self.cache = PrismCache(maxEntries: maxEntries, defaultTTL: defaultTTL)
    }

    /// Retrieves cached data for the given key.
    public func get(_ key: String) async -> Data? {
        await cache.get(key)
    }

    /// Stores data under the given key with an optional TTL.
    public func set(_ key: String, value: Data, ttl: TimeInterval?) async {
        await cache.set(key, value: value, ttl: ttl)
    }

    /// Removes the entry for the given key.
    public func remove(_ key: String) async {
        await cache.remove(key)
    }

    /// Removes all entries from the store.
    public func clear() async {
        await cache.clear()
    }

    /// Returns whether a non-expired entry exists for the given key.
    public func has(_ key: String) async -> Bool {
        await cache.has(key)
    }
}
