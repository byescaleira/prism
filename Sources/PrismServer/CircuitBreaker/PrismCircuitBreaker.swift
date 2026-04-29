import Foundation

// MARK: - Circuit State

public enum PrismCircuitState: String, Sendable {
    case closed
    case open
    case halfOpen = "half_open"
}

// MARK: - Circuit Config

public struct PrismCircuitBreakerConfig: Sendable {
    public let failureThreshold: Int
    public let resetTimeout: TimeInterval
    public let halfOpenMaxAttempts: Int
    public let successThreshold: Int

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

public struct PrismCircuitMetrics: Sendable {
    public let totalCalls: Int
    public let successCount: Int
    public let failureCount: Int
    public let consecutiveFailures: Int
    public let lastFailure: Date?
    public let stateChanges: Int
    public let state: PrismCircuitState

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

    public init(name: String, config: PrismCircuitBreakerConfig = PrismCircuitBreakerConfig()) {
        self.name = name
        self.config = config
    }

    public func onStateChange(_ callback: @escaping @Sendable (String, PrismCircuitState, PrismCircuitState) async -> Void) {
        self.onStateChange = callback
    }

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

    public func currentState() -> PrismCircuitState { state }

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

public actor PrismCircuitBreakerRegistry {
    private var breakers: [String: PrismCircuitBreaker] = [:]
    private let defaultConfig: PrismCircuitBreakerConfig

    public init(defaultConfig: PrismCircuitBreakerConfig = PrismCircuitBreakerConfig()) {
        self.defaultConfig = defaultConfig
    }

    public func breaker(for name: String, config: PrismCircuitBreakerConfig? = nil) -> PrismCircuitBreaker {
        if let existing = breakers[name] { return existing }
        let cb = PrismCircuitBreaker(name: name, config: config ?? defaultConfig)
        breakers[name] = cb
        return cb
    }

    public func getBreaker(_ name: String) -> PrismCircuitBreaker? {
        breakers[name]
    }

    public func allMetrics() async -> [String: PrismCircuitMetrics] {
        var result: [String: PrismCircuitMetrics] = [:]
        for (name, cb) in breakers {
            result[name] = await cb.metrics()
        }
        return result
    }

    public func resetAll() async {
        for (_, cb) in breakers {
            await cb.reset()
        }
    }

    public func remove(_ name: String) {
        breakers.removeValue(forKey: name)
    }
}

// MARK: - Errors

public enum PrismCircuitBreakerError: Error, Sendable {
    case circuitOpen(name: String, retryAfter: TimeInterval)
}
