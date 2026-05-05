import Foundation

/// Observable storage wrapper that emits events on mutations.
public final class PrismStorageObserver: PrismStorageProtocol, @unchecked Sendable {
    private let inner: PrismStorageProtocol
    private let lock = NSLock()
    private var continuations: [UUID: AsyncStream<PrismStorageEvent>.Continuation] = [:]

    public init(wrapping store: PrismStorageProtocol) {
        self.inner = store
    }

    public func events() -> AsyncStream<PrismStorageEvent> {
        let id = UUID()
        return AsyncStream { continuation in
            lock.lock()
            continuations[id] = continuation
            lock.unlock()
            continuation.onTermination = { [weak self] _ in
                self?.lock.lock()
                self?.continuations.removeValue(forKey: id)
                self?.lock.unlock()
            }
        }
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) throws {
        lock.lock()
        try inner.save(value, forKey: key)
        let conts = Array(continuations.values)
        lock.unlock()
        for c in conts { c.yield(.saved(key: key)) }
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) throws -> T? {
        lock.lock()
        let value = try inner.load(type, forKey: key)
        let conts = Array(continuations.values)
        lock.unlock()
        if value != nil {
            for c in conts { c.yield(.loaded(key: key)) }
        }
        return value
    }

    public func delete(forKey key: String) throws {
        lock.lock()
        try inner.delete(forKey: key)
        let conts = Array(continuations.values)
        lock.unlock()
        for c in conts { c.yield(.deleted(key: key)) }
    }

    public func exists(forKey key: String) throws -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return try inner.exists(forKey: key)
    }

    public func clear() throws {
        lock.lock()
        try inner.clear()
        let conts = Array(continuations.values)
        lock.unlock()
        for c in conts { c.yield(.cleared) }
    }

    public func keys() throws -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return try inner.keys()
    }
}

/// Async variant for actor-based stores.
public actor PrismAsyncStorageObserver: PrismAsyncStorageProtocol {
    private let inner: PrismAsyncStorageProtocol
    private var continuations: [UUID: AsyncStream<PrismStorageEvent>.Continuation] = [:]

    public init(wrapping store: PrismAsyncStorageProtocol) {
        self.inner = store
    }

    public func events() -> AsyncStream<PrismStorageEvent> {
        let id = UUID()
        return AsyncStream { continuation in
            self.continuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id) }
            }
        }
    }

    private func removeContinuation(_ id: UUID) {
        continuations.removeValue(forKey: id)
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) async throws {
        try await inner.save(value, forKey: key)
        for c in continuations.values { c.yield(.saved(key: key)) }
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
        let value = try await inner.load(type, forKey: key)
        if value != nil {
            for c in continuations.values { c.yield(.loaded(key: key)) }
        }
        return value
    }

    public func delete(forKey key: String) async throws {
        try await inner.delete(forKey: key)
        for c in continuations.values { c.yield(.deleted(key: key)) }
    }

    public func exists(forKey key: String) async throws -> Bool {
        try await inner.exists(forKey: key)
    }

    public func clear() async throws {
        try await inner.clear()
        for c in continuations.values { c.yield(.cleared) }
    }

    public func keys() async throws -> [String] {
        try await inner.keys()
    }
}
