import Foundation

/// A server-side session with key-value storage and expiry.
public struct PrismSession: Sendable {
    /// Unique session identifier.
    public let id: String
    /// Session data.
    public var data: [String: String]
    /// When the session was created.
    public let createdAt: Date
    /// When the session expires.
    public var expiresAt: Date

    public init(id: String = UUID().uuidString, data: [String: String] = [:], ttl: TimeInterval = 3600) {
        self.id = id
        self.data = data
        self.createdAt = .now
        self.expiresAt = Date.now.addingTimeInterval(ttl)
    }

    public var isExpired: Bool { Date.now >= expiresAt }

    public subscript(_ key: String) -> String? {
        get { data[key] }
        set { data[key] = newValue }
    }
}

/// Protocol for session storage backends.
public protocol PrismSessionStore: Sendable {
    func load(id: String) async -> PrismSession?
    func save(_ session: PrismSession) async
    func destroy(id: String) async
}

/// In-memory session store backed by a PrismCache.
public actor PrismMemorySessionStore: PrismSessionStore {
    private let cache: PrismCache<String, PrismSession>

    public init(maxSessions: Int = 10000, ttl: TimeInterval = 3600) {
        self.cache = PrismCache(maxEntries: maxSessions, defaultTTL: ttl)
    }

    public func load(id: String) async -> PrismSession? {
        await cache.get(id)
    }

    public func save(_ session: PrismSession) async {
        let ttl = session.expiresAt.timeIntervalSince(.now)
        await cache.set(session.id, value: session, ttl: max(ttl, 1))
    }

    public func destroy(id: String) async {
        await cache.remove(id)
    }
}
