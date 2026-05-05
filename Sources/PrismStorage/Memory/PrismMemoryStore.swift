import Foundation

/// In-memory LRU cache with TTL, eviction, and statistics.
public actor PrismMemoryStore: PrismAsyncStorageProtocol {
    private var entries: [String: MemoryEntry] = [:]
    private var accessOrder: [String] = []
    private let maxEntries: Int
    private let defaultTTL: TimeInterval?
    private var stats: PrismMemoryStats = .init()

    public init(maxEntries: Int = 1000, defaultTTL: TimeInterval? = nil) {
        self.maxEntries = maxEntries
        self.defaultTTL = defaultTTL
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) async throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            throw PrismStorageError.encodingFailed(key)
        }
        await save(data: data, forKey: key, ttl: defaultTTL)
    }

    public func save<T: Codable & Sendable>(
        _ value: T, forKey key: String, ttl: TimeInterval
    ) async throws {
        let data = try JSONEncoder().encode(value)
        await save(data: data, forKey: key, ttl: ttl)
    }

    private func save(data: Data, forKey key: String, ttl: TimeInterval?) async {
        let expiresAt = ttl.map { Date.now.addingTimeInterval($0) }
        entries[key] = MemoryEntry(data: data, createdAt: .now, expiresAt: expiresAt)
        touchKey(key)
        evictIfNeeded()
        stats.writes += 1
    }

    public func load<T: Codable & Sendable>(
        _ type: T.Type, forKey key: String
    ) async throws -> T? {
        guard let entry = entries[key] else {
            stats.misses += 1
            return nil
        }

        if entry.isExpired {
            entries.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            stats.expirations += 1
            stats.misses += 1
            return nil
        }

        touchKey(key)
        stats.hits += 1

        do {
            return try JSONDecoder().decode(type, from: entry.data)
        } catch {
            throw PrismStorageError.decodingFailed(key)
        }
    }

    public func delete(forKey key: String) async throws {
        entries.removeValue(forKey: key)
        accessOrder.removeAll { $0 == key }
    }

    public func exists(forKey key: String) async throws -> Bool {
        guard let entry = entries[key] else { return false }
        if entry.isExpired {
            entries.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            return false
        }
        return true
    }

    public func clear() async throws {
        entries.removeAll()
        accessOrder.removeAll()
    }

    public func keys() async throws -> [String] {
        pruneExpired()
        return Array(entries.keys)
    }

    // MARK: - Stats

    public func statistics() -> PrismMemoryStats {
        stats
    }

    public func count() -> Int {
        entries.count
    }

    // MARK: - Private

    private func touchKey(_ key: String) {
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
    }

    private func evictIfNeeded() {
        while entries.count > maxEntries, let oldest = accessOrder.first {
            entries.removeValue(forKey: oldest)
            accessOrder.removeFirst()
            stats.evictions += 1
        }
    }

    private func pruneExpired() {
        let expired = entries.filter { $0.value.isExpired }.map(\.key)
        for key in expired {
            entries.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            stats.expirations += 1
        }
    }
}

private struct MemoryEntry: Sendable {
    let data: Data
    let createdAt: Date
    let expiresAt: Date?

    var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date.now >= expiresAt
    }
}

public struct PrismMemoryStats: Sendable, Equatable {
    public var hits: Int = 0
    public var misses: Int = 0
    public var writes: Int = 0
    public var evictions: Int = 0
    public var expirations: Int = 0

    public var hitRate: Double {
        let total = hits + misses
        guard total > 0 else { return 0 }
        return Double(hits) / Double(total)
    }
}
