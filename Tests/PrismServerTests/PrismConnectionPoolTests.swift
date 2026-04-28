#if canImport(SQLite3)
import Testing
import Foundation
@testable import PrismServer

@Suite("PrismConnectionPool Tests")
struct PrismConnectionPoolTests {

    @Test("Init creates pool with one connection")
    func initPool() async throws {
        let pool = try PrismConnectionPool(path: ":memory:", maxConnections: 3)
        #expect(await pool.totalCount == 1)
        #expect(await pool.idleCount == 1)
        #expect(await pool.activeCount == 0)
    }

    @Test("Acquire returns a connection")
    func acquireConnection() async throws {
        let pool = try PrismConnectionPool(path: ":memory:", maxConnections: 3)
        let conn = try await pool.acquire()
        #expect(await pool.activeCount == 1)
        #expect(await pool.idleCount == 0)
        await pool.release(conn)
    }

    @Test("Release returns connection to pool")
    func releaseConnection() async throws {
        let pool = try PrismConnectionPool(path: ":memory:", maxConnections: 3)
        let conn = try await pool.acquire()
        await pool.release(conn)
        #expect(await pool.activeCount == 0)
        #expect(await pool.idleCount == 1)
    }

    @Test("WithConnection auto-releases")
    func withConnectionAutoRelease() async throws {
        let pool = try PrismConnectionPool(path: ":memory:", maxConnections: 3)
        try await pool.withConnection { db in
            try await db.execute("CREATE TABLE IF NOT EXISTS _pool_test (id INTEGER)")
        }
        #expect(await pool.activeCount == 0)
        #expect(await pool.idleCount == 1)
    }

    @Test("Multiple acquires create new connections up to max")
    func multipleAcquires() async throws {
        let pool = try PrismConnectionPool(path: ":memory:", maxConnections: 3)
        let c1 = try await pool.acquire()
        let c2 = try await pool.acquire()
        #expect(await pool.activeCount == 2)
        #expect(await pool.totalCount == 2)
        await pool.release(c1)
        await pool.release(c2)
    }

    @Test("WithConnection releases on error")
    func withConnectionReleasesOnError() async throws {
        let pool = try PrismConnectionPool(path: ":memory:", maxConnections: 3)

        do {
            try await pool.withConnection { _ in
                throw TestPoolError.simulated
            }
        } catch {
            // expected
        }

        #expect(await pool.activeCount == 0)
    }
}

private enum TestPoolError: Error {
    case simulated
}
#endif
