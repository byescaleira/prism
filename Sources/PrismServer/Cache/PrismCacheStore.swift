import Foundation

public protocol PrismCacheStore: Sendable {
    func get(_ key: String) async -> Data?
    func set(_ key: String, value: Data, ttl: TimeInterval?) async
    func remove(_ key: String) async
    func clear() async
    func has(_ key: String) async -> Bool
}

public actor PrismMemoryCacheStore: PrismCacheStore {
    private let cache: PrismCache<String, Data>

    public init(maxEntries: Int = 1000, defaultTTL: TimeInterval = 300) {
        self.cache = PrismCache(maxEntries: maxEntries, defaultTTL: defaultTTL)
    }

    public func get(_ key: String) async -> Data? {
        await cache.get(key)
    }

    public func set(_ key: String, value: Data, ttl: TimeInterval?) async {
        await cache.set(key, value: value, ttl: ttl)
    }

    public func remove(_ key: String) async {
        await cache.remove(key)
    }

    public func clear() async {
        await cache.clear()
    }

    public func has(_ key: String) async -> Bool {
        await cache.has(key)
    }
}
