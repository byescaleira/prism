import Foundation

// MARK: - Circuit State

/// Represents the current state of a circuit breaker.
public enum PrismCircuitState: String, Sendable {
    /// The circuit is closed and requests flow normally.
    case closed
    /// The circuit is open and requests are rejected.
    case open
    /// The circuit is testing whether the downstream service has recovered.
    case halfOpen = "half_open"
}

// MARK: - Circuit Config

/// Configuration options for a circuit breaker.
public struct PrismCircuitBreakerConfig: Sendable {
    /// Number of consecutive failures before the circuit opens.
    public let failureThreshold: Int
    /// Duration to wait before transitioning from open to half-open.
    public let resetTimeout: TimeInterval
    /// Maximum number of trial requests allowed in the half-open state.
    public let halfOpenMaxAttempts: Int
    /// Number of consecutive successes in half-open required to close the circuit.
    public let successThreshold: Int

    /// Creates a circuit breaker configuration with the specified thresholds.
    public init(
        failureThreshold: Int = 5,
        resetTimeout: TimeInterval = 30,
        halfOpenMaxAttempts: Int = 3,
        successThreshold: Int = 2
    ) {
        self.failureThreshold = failureThreshold
        self.resetTimeout = resetTimeout
        self.halfOpenMaxAttempts = halfOpenMaxAttempts
        self.successThreshold = successThreshold
    }
}

// MARK: - Circuit Metrics

/// Snapshot of a circuit breaker's runtime metrics.
public struct PrismCircuitMetrics: Sendable {
    /// Total number of calls made through the breaker.
    public let totalCalls: Int
    /// Number of successful calls.
    public let successCount: Int
    /// Number of failed calls.
    public let failureCount: Int
    /// Current streak of consecutive failures.
    public let consecutiveFailures: Int
    /// Timestamp of the most recent failure.
    public let lastFailure: Date?
    /// Number of state transitions that have occurred.
    public let stateChanges: Int
    /// The current circuit state.
    public let state: PrismCircuitState

    /// Creates a metrics snapshot with the given values.
    public init(
        totalCalls: Int = 0,
        successCount: Int = 0,
        failureCount: Int = 0,
        consecutiveFailures: Int = 0,
        lastFailure: Date? = nil,
        stateChanges: Int = 0,
        state: PrismCircuitState = .closed
    ) {
        self.totalCalls = totalCalls
        self.successCount = successCount
        self.failureCount = failureCount
        self.consecutiveFailures = consecutiveFailures
        self.lastFailure = lastFailure
        self.stateChanges = stateChanges
        self.state = state
    }
}

// MARK: - Circuit Breaker

/// Actor that implements the circuit breaker pattern for fault-tolerant service calls.
public actor PrismCircuitBreaker {
    private let name: String
    private let config: PrismCircuitBreakerConfig
    private var state: PrismCircuitState = .closed
    private var failureCount: Int = 0
    private var successCount: Int = 0
    private var consecutiveFailures: Int = 0
    private var consecutiveSuccesses: Int = 0
    private var halfOpenAttempts: Int = 0
    private var lastFailureTime: Date?
    private var lastStateChange: Date = Date()
    private var totalCalls: Int = 0
    private var stateChangeCount: Int = 0

    private var onStateChange: (@Sendable (String, PrismCircuitState, PrismCircuitState) async -> Void)?

    /// Creates a circuit breaker with the given name and configuration.
    public init(name: String, config: PrismCircuitBreakerConfig = PrismCircuitBreakerConfig()) {
        self.name = name
        self.config = config
    }

    /// Registers a callback invoked whenever the circuit state changes.
    public func onStateChange(_ callback: @escaping @Sendable (String, PrismCircuitState, PrismCircuitState) async -> Void) {
        self.onStateChange = callback
    }

    /// Executes an operation through the circuit breaker, throwing if the circuit is open.
    public func execute<T: Sendable>(_ operation: @Sendable () async throws -> T) async throws -> T {
        try checkState()
        totalCalls += 1

        do {
            let result = try await operation()
            recordSuccess()
            return result
        } catch {
            recordFailure()
            throw error
        }
    }

    /// Returns the current state of the circuit.
    public func currentState() -> PrismCircuitState { state }

    /// Returns a snapshot of the circuit breaker's metrics.
    public func metrics() -> PrismCircuitMetrics {
        PrismCircuitMetrics(
            totalCalls: totalCalls,
            successCount: successCount,
            failureCount: failureCount,
            consecutiveFailures: consecutiveFailures,
            lastFailure: lastFailureTime,
            stateChanges: stateChangeCount,
            state: state
        )
    }

    /// Resets the circuit breaker to the closed state and clears all counters.
    public func reset() {
        let oldState = state
        state = .closed
        failureCount = 0
        consecutiveFailures = 0
        consecutiveSuccesses = 0
        halfOpenAttempts = 0
        lastFailureTime = nil
        if oldState != .closed {
            stateChangeCount += 1
        }
    }

    // MARK: - Private

    private func checkState() throws {
        switch state {
        case .closed:
            break
        case .open:
            guard let lastFailure = lastFailureTime else {
                transition(to: .halfOpen)
                return
            }
            let elapsed = Date().timeIntervalSince(lastFailure)
            if elapsed >= config.resetTimeout {
                transition(to: .halfOpen)
            } else {
                throw PrismCircuitBreakerError.circuitOpen(name: name, retryAfter: config.resetTimeout - elapsed)
            }
        case .halfOpen:
            if halfOpenAttempts >= config.halfOpenMaxAttempts {
                transition(to: .open)
                throw PrismCircuitBreakerError.circuitOpen(name: name, retryAfter: config.resetTimeout)
            }
            halfOpenAttempts += 1
        }
    }

    private func recordSuccess() {
        successCount += 1
        consecutiveSuccesses += 1
        consecutiveFailures = 0

        switch state {
        case .halfOpen:
            if consecutiveSuccesses >= config.successThreshold {
                transition(to: .closed)
            }
        case .closed, .open:
            break
        }
    }

    private func recordFailure() {
        failureCount += 1
        consecutiveFailures += 1
        consecutiveSuccesses = 0
        lastFailureTime = Date()

        switch state {
        case .closed:
            if consecutiveFailures >= config.failureThreshold {
                transition(to: .open)
            }
        case .halfOpen:
            transition(to: .open)
        case .open:
            break
        }
    }

    private func transition(to newState: PrismCircuitState) {
        let oldState = state
        guard oldState != newState else { return }
        state = newState
        stateChangeCount += 1
        lastStateChange = Date()
        halfOpenAttempts = 0
        consecutiveSuccesses = 0

        if let callback = onStateChange {
            let n = name
            Task { await callback(n, oldState, newState) }
        }
    }
}

// MARK: - Circuit Breaker Registry

/// Registry that manages named circuit breakers with shared default configuration.
public actor PrismCircuitBreakerRegistry {
    private var breakers: [String: PrismCircuitBreaker] = [:]
    private let defaultConfig: PrismCircuitBreakerConfig

    /// Creates a registry with the given default circuit breaker configuration.
    public init(defaultConfig: PrismCircuitBreakerConfig = PrismCircuitBreakerConfig()) {
        self.defaultConfig = defaultConfig
    }

    /// Returns the circuit breaker for the given name, creating one if needed.
    public func breaker(for name: String, config: PrismCircuitBreakerConfig? = nil) -> PrismCircuitBreaker {
        if let existing = breakers[name] { return existing }
        let cb = PrismCircuitBreaker(name: name, config: config ?? defaultConfig)
        breakers[name] = cb
        return cb
    }

    /// Returns an existing circuit breaker by name, or nil if not registered.
    public func getBreaker(_ name: String) -> PrismCircuitBreaker? {
        breakers[name]
    }

    /// Collects metrics from all registered circuit breakers.
    public func allMetrics() async -> [String: PrismCircuitMetrics] {
        var result: [String: PrismCircuitMetrics] = [:]
        for (name, cb) in breakers {
            result[name] = await cb.metrics()
        }
        return result
    }

    /// Resets all registered circuit breakers to the closed state.
    public func resetAll() async {
        for (_, cb) in breakers {
            await cb.reset()
        }
    }

    /// Removes a circuit breaker from the registry by name.
    public func remove(_ name: String) {
        breakers.removeValue(forKey: name)
    }
}

// MARK: - Errors

/// Errors thrown by the circuit breaker.
public enum PrismCircuitBreakerError: Error, Sendable {
    /// The circuit is open and the operation was rejected.
    case circuitOpen(name: String, retryAfter: TimeInterval)
}
