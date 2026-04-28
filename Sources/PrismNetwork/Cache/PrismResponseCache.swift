//
//  PrismResponseCache.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// Determines how a request interacts with the cache layer.
public enum PrismCachePolicy: Sendable, CaseIterable {
    /// Always fetch from the network, ignoring cached data.
    case networkOnly
    /// Return cached data if available; otherwise fetch from network.
    case cacheFirst
    /// Return cached data immediately, then revalidate from network.
    case cacheThenNetwork
    /// Serve stale cache while revalidating in the background.
    case staleWhileRevalidate
}

/// A cached response entry with metadata and time-to-live.
public struct PrismCacheEntry: Sendable {
    /// The cached response data.
    public let data: Data
    /// The HTTP status code of the original response.
    public let statusCode: Int
    /// Response headers from the original response.
    public let headers: [String: String]
    /// The time this entry was cached.
    public let cachedAt: Date
    /// How long this entry remains valid.
    public let ttl: Duration

    /// Creates a new cache entry.
    public init(
        data: Data,
        statusCode: Int = 200,
        headers: [String: String] = [:],
        cachedAt: Date = Date(),
        ttl: Duration = .seconds(300)
    ) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.cachedAt = cachedAt
        self.ttl = ttl
    }

    /// Whether this cache entry has expired.
    public var isExpired: Bool {
        let expirationDate = cachedAt.addingTimeInterval(ttl.timeInterval)
        return Date() > expirationDate
    }
}

/// An actor-based LRU response cache with configurable size and TTL.
public actor PrismResponseCache {
    private var storage: [String: PrismCacheEntry] = [:]
    private var accessOrder: [String] = []
    private let maxSize: Int

    /// Creates a response cache with the given maximum entry count.
    public init(maxSize: Int = 100) {
        self.maxSize = maxSize
    }

    /// Retrieves a cache entry for the given key, returning nil if expired or missing.
    public func get(for key: String) -> PrismCacheEntry? {
        guard let entry = storage[key] else { return nil }
        if entry.isExpired {
            storage.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            return nil
        }
        touchKey(key)
        return entry
    }

    /// Stores a cache entry, evicting the least-recently-used entry if at capacity.
    public func set(_ entry: PrismCacheEntry, for key: String) {
        if storage[key] != nil {
            storage[key] = entry
            touchKey(key)
        } else {
            if storage.count >= maxSize {
                evictLRU()
            }
            storage[key] = entry
            accessOrder.append(key)
        }
    }

    /// Removes the cache entry for the given key.
    public func invalidate(key: String) {
        storage.removeValue(forKey: key)
        accessOrder.removeAll { $0 == key }
    }

    /// Removes all cached entries.
    public func clear() {
        storage.removeAll()
        accessOrder.removeAll()
    }

    /// The number of entries currently in the cache.
    public var count: Int {
        storage.count
    }

    private func touchKey(_ key: String) {
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
    }

    private func evictLRU() {
        guard let oldest = accessOrder.first else { return }
        accessOrder.removeFirst()
        storage.removeValue(forKey: oldest)
    }
}
