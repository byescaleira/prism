import Testing
import Foundation
@testable import PrismServer

@Suite("PrismCircuitBreaker Tests")
struct PrismCircuitBreakerTests {

    @Test("Starts in closed state")
    func initialState() async {
        let cb = PrismCircuitBreaker(name: "test")
        let state = await cb.currentState()
        #expect(state == .closed)
    }

    @Test("Successful calls keep circuit closed")
    func successKeepsClosed() async throws {
        let cb = PrismCircuitBreaker(name: "test", config: PrismCircuitBreakerConfig(failureThreshold: 3))
        let result = try await cb.execute { "ok" }
        #expect(result == "ok")
        #expect(await cb.currentState() == .closed)
    }

    @Test("Opens after failure threshold")
    func opensAfterThreshold() async {
        let config = PrismCircuitBreakerConfig(failureThreshold: 3, resetTimeout: 60)
        let cb = PrismCircuitBreaker(name: "test", config: config)

        for _ in 0..<3 {
            do {
                _ = try await cb.execute { throw CircuitBreakerTestError.failure }
            } catch is CircuitBreakerTestError {}
            catch {}
        }

        #expect(await cb.currentState() == .open)
    }

    @Test("Open circuit rejects calls")
    func openRejectsCalls() async {
        let config = PrismCircuitBreakerConfig(failureThreshold: 1, resetTimeout: 60)
        let cb = PrismCircuitBreaker(name: "test", config: config)

        do {
            _ = try await cb.execute { throw CircuitBreakerTestError.failure }
        } catch {}

        do {
            _ = try await cb.execute { "should not run" }
            #expect(Bool(false), "Should have thrown")
        } catch {
            #expect(error is PrismCircuitBreakerError)
        }
    }

    @Test("Half-open after reset timeout")
    func halfOpenAfterTimeout() async throws {
        let config = PrismCircuitBreakerConfig(failureThreshold: 1, resetTimeout: 0.1)
        let cb = PrismCircuitBreaker(name: "test", config: config)

        do {
            _ = try await cb.execute { throw CircuitBreakerTestError.failure }
        } catch {}

        #expect(await cb.currentState() == .open)
        try await Task.sleep(for: .milliseconds(150))

        let result = try await cb.execute { "recovered" }
        #expect(result == "recovered")
    }

    @Test("Half-open returns to closed after success threshold")
    func halfOpenToClosed() async throws {
        let config = PrismCircuitBreakerConfig(failureThreshold: 1, resetTimeout: 0.1, successThreshold: 2)
        let cb = PrismCircuitBreaker(name: "test", config: config)

        do {
            _ = try await cb.execute { throw CircuitBreakerTestError.failure }
        } catch {}

        try await Task.sleep(for: .milliseconds(150))

        _ = try await cb.execute { "ok" }
        _ = try await cb.execute { "ok" }
        #expect(await cb.currentState() == .closed)
    }

    @Test("Half-open returns to open on failure")
    func halfOpenToOpen() async throws {
        let config = PrismCircuitBreakerConfig(failureThreshold: 1, resetTimeout: 0.1, halfOpenMaxAttempts: 3)
        let cb = PrismCircuitBreaker(name: "test", config: config)

        do {
            _ = try await cb.execute { throw CircuitBreakerTestError.failure }
        } catch {}

        try await Task.sleep(for: .milliseconds(150))

        do {
            _ = try await cb.execute { throw CircuitBreakerTestError.failure }
        } catch {}

        #expect(await cb.currentState() == .open)
    }

    @Test("Metrics track calls")
    func metricsTracking() async throws {
        let config = PrismCircuitBreakerConfig(failureThreshold: 5)
        let cb = PrismCircuitBreaker(name: "test", config: config)

        _ = try await cb.execute { "ok" }
        _ = try await cb.execute { "ok" }
        do { _ = try await cb.execute { throw CircuitBreakerTestError.failure } } catch {}

        let m = await cb.metrics()
        #expect(m.totalCalls == 3)
        #expect(m.successCount == 2)
        #expect(m.failureCount == 1)
        #expect(m.consecutiveFailures == 1)
        #expect(m.state == .closed)
    }

    @Test("Reset restores closed state")
    func resetRestoresClosed() async {
        let config = PrismCircuitBreakerConfig(failureThreshold: 1, resetTimeout: 60)
        let cb = PrismCircuitBreaker(name: "test", config: config)

        do { _ = try await cb.execute { throw CircuitBreakerTestError.failure } } catch {}
        #expect(await cb.currentState() == .open)

        await cb.reset()
        #expect(await cb.currentState() == .closed)
    }

    @Test("State change count increments")
    func stateChangeCount() async throws {
        let config = PrismCircuitBreakerConfig(failureThreshold: 1, resetTimeout: 0.1, successThreshold: 1)
        let cb = PrismCircuitBreaker(name: "test", config: config)

        do { _ = try await cb.execute { throw CircuitBreakerTestError.failure } } catch {}
        try await Task.sleep(for: .milliseconds(150))
        _ = try await cb.execute { "ok" }

        let m = await cb.metrics()
        #expect(m.stateChanges >= 2)
    }
}

@Suite("PrismCircuitBreakerRegistry Tests")
struct PrismCircuitBreakerRegistryTests {

    @Test("Creates and retrieves breakers")
    func createAndRetrieve() async {
        let registry = PrismCircuitBreakerRegistry()
        let cb = await registry.breaker(for: "api")
        let same = await registry.breaker(for: "api")
        #expect(await cb.currentState() == .closed)
        #expect(await same.currentState() == .closed)
    }

    @Test("Get returns nil for unknown breaker")
    func getNil() async {
        let registry = PrismCircuitBreakerRegistry()
        let cb = await registry.getBreaker("unknown")
        #expect(cb == nil)
    }

    @Test("Remove deletes breaker")
    func removeBreaker() async {
        let registry = PrismCircuitBreakerRegistry()
        _ = await registry.breaker(for: "api")
        await registry.remove("api")
        #expect(await registry.getBreaker("api") == nil)
    }

    @Test("Reset all breakers")
    func resetAll() async {
        let config = PrismCircuitBreakerConfig(failureThreshold: 1, resetTimeout: 60)
        let registry = PrismCircuitBreakerRegistry(defaultConfig: config)
        let cb = await registry.breaker(for: "api")
        do { _ = try await cb.execute { throw CircuitBreakerTestError.failure } } catch {}
        #expect(await cb.currentState() == .open)

        await registry.resetAll()
        #expect(await cb.currentState() == .closed)
    }

    @Test("All metrics returns metrics map")
    func allMetrics() async throws {
        let registry = PrismCircuitBreakerRegistry()
        let cb1 = await registry.breaker(for: "api")
        let cb2 = await registry.breaker(for: "db")
        _ = try await cb1.execute { "ok" }
        _ = try await cb2.execute { "ok" }

        let metrics = await registry.allMetrics()
        #expect(metrics.count == 2)
        #expect(metrics["api"]?.totalCalls == 1)
        #expect(metrics["db"]?.totalCalls == 1)
    }
}

@Suite("PrismCircuitBreakerConfig Tests")
struct PrismCircuitBreakerConfigTests {

    @Test("Default config values")
    func defaults() {
        let config = PrismCircuitBreakerConfig()
        #expect(config.failureThreshold == 5)
        #expect(config.resetTimeout == 30)
        #expect(config.halfOpenMaxAttempts == 3)
        #expect(config.successThreshold == 2)
    }

    @Test("Custom config values")
    func custom() {
        let config = PrismCircuitBreakerConfig(
            failureThreshold: 10, resetTimeout: 60,
            halfOpenMaxAttempts: 5, successThreshold: 3
        )
        #expect(config.failureThreshold == 10)
        #expect(config.resetTimeout == 60)
        #expect(config.halfOpenMaxAttempts == 5)
        #expect(config.successThreshold == 3)
    }
}

@Suite("PrismCircuitState Tests")
struct PrismCircuitStateTests {

    @Test("Raw values")
    func rawValues() {
        #expect(PrismCircuitState.closed.rawValue == "closed")
        #expect(PrismCircuitState.open.rawValue == "open")
        #expect(PrismCircuitState.halfOpen.rawValue == "half_open")
    }
}

enum CircuitBreakerTestError: Error {
    case failure
}
