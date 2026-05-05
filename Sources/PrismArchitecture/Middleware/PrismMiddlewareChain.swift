//
//  PrismMiddlewareChain.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// A protocol for middleware that intercepts actions and can forward them to the next handler.
public protocol PrismChainableMiddleware: Sendable {
    /// Handles an action with access to the current state and a callback to forward to the next middleware.
    func handle<State: Sendable, Action: Sendable>(
        state: State,
        action: Action,
        next: @Sendable (Action) -> Void
    ) async
}

// MARK: - Logging Middleware

/// A middleware that logs every action and state type for debugging.
public struct PrismLoggingMiddleware: PrismChainableMiddleware, Sendable {
    private let logger: @Sendable (String) -> Void

    /// Creates a logging middleware with a custom logger closure.
    public init(logger: @escaping @Sendable (String) -> Void = { print($0) }) {
        self.logger = logger
    }

    /// Logs the action and state type, then forwards the action to the next handler.
    public func handle<State: Sendable, Action: Sendable>(
        state: State,
        action: Action,
        next: @Sendable (Action) -> Void
    ) async {
        logger("[PrismMiddleware] Action: \(action) | State: \(type(of: state))")
        next(action)
    }
}

// MARK: - Throttle Middleware

/// A middleware that throttles rapid duplicate actions within a configurable time window.
public final class PrismThrottleMiddleware: PrismChainableMiddleware, @unchecked Sendable {
    private let interval: Duration
    private let lock = NSLock()
    private var lastActionTimestamps: [String: ContinuousClock.Instant] = [:]

    /// Creates a throttle middleware with the given minimum interval between duplicate actions.
    public init(interval: Duration = .milliseconds(300)) {
        self.interval = interval
    }

    /// Forwards the action to the next handler only if the throttle interval has elapsed since the last identical action.
    public func handle<State: Sendable, Action: Sendable>(
        state: State,
        action: Action,
        next: @Sendable (Action) -> Void
    ) async {
        let key = String(describing: action)
        let now = ContinuousClock.now

        let shouldForward: Bool = lock.withLock {
            if let lastTime = lastActionTimestamps[key] {
                let elapsed = now - lastTime
                if elapsed < interval {
                    return false
                }
            }
            lastActionTimestamps[key] = now
            return true
        }

        if shouldForward {
            next(action)
        }
    }
}

// MARK: - Middleware Chain

/// A builder that composes multiple chainable middlewares in order.
public struct PrismMiddlewareChain: Sendable {
    private var middlewares: [any PrismChainableMiddleware] = []

    /// Creates an empty middleware chain.
    public init() {}

    /// Appends a middleware to the chain and returns the updated chain.
    public func add(_ middleware: any PrismChainableMiddleware) -> PrismMiddlewareChain {
        var copy = self
        copy.middlewares.append(middleware)
        return copy
    }

    /// Returns the ordered array of middlewares in this chain.
    public func build() -> [any PrismChainableMiddleware] {
        middlewares
    }
}
