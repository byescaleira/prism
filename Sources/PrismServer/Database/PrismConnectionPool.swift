#if canImport(SQLite3)
import Foundation

/// Actor-based SQLite connection pool for concurrent request handling.
public actor PrismConnectionPool {
    private var available: [PrismDatabase] = []
    private var inUse: Int = 0
    private let maxConnections: Int
    private let path: String
    private var waiters: [CheckedContinuation<PrismDatabase, any Error>] = []

    /// Creates a connection pool backed by the SQLite database at the given path.
    public init(path: String, maxConnections: Int = 5) throws {
        self.path = path
        self.maxConnections = maxConnections

        let initial = try PrismDatabase(path: path)
        available.append(initial)
    }

    /// Acquires a connection from the pool. Blocks if none available and pool is at capacity.
    public func acquire() async throws -> PrismDatabase {
        if let conn = available.popLast() {
            inUse += 1
            return conn
        }

        if inUse < maxConnections {
            let conn = try PrismDatabase(path: path)
            inUse += 1
            return conn
        }

        return try await withCheckedThrowingContinuation { continuation in
            waiters.append(continuation)
        }
    }

    /// Returns a connection to the pool.
    public func release(_ connection: PrismDatabase) {
        inUse -= 1

        if let waiter = waiters.first {
            waiters.removeFirst()
            inUse += 1
            waiter.resume(returning: connection)
        } else {
            available.append(connection)
        }
    }

    /// Executes a closure with a pooled connection, automatically releasing afterward.
    public func withConnection<T: Sendable>(_ block: (PrismDatabase) async throws -> T) async throws -> T {
        let conn = try await acquire()
        do {
            let result = try await block(conn)
            release(conn)
            return result
        } catch {
            release(conn)
            throw error
        }
    }

    /// Current number of connections in use.
    public var activeCount: Int { inUse }

    /// Current number of idle connections.
    public var idleCount: Int { available.count }

    /// Total pool size (active + idle).
    public var totalCount: Int { inUse + available.count }
}
#endif
