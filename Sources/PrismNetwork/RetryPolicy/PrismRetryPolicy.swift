//
//  PrismRetryPolicy.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// A policy that decides whether a failed request should be retried.
public protocol PrismRetryPolicy: Sendable {
    /// Returns whether the request should be retried for the given error and attempt number.
    func shouldRetry(for error: Error, attempt: Int) -> Bool
    /// Returns the delay before the next retry attempt.
    func delay(for attempt: Int) -> Duration
}

/// Exponential backoff retry policy with optional jitter.
public struct PrismExponentialBackoff: PrismRetryPolicy, Sendable {
    /// The base delay between retries.
    public let baseDelay: Duration
    /// The maximum delay cap.
    public let maxDelay: Duration
    /// The maximum number of retry attempts allowed.
    public let maxAttempts: Int

    /// Creates an exponential backoff policy.
    public init(
        baseDelay: Duration = .seconds(1),
        maxDelay: Duration = .seconds(30),
        maxAttempts: Int = 3
    ) {
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.maxAttempts = maxAttempts
    }

    /// Returns whether the request should be retried based on the current attempt count.
    public func shouldRetry(for error: Error, attempt: Int) -> Bool {
        attempt < maxAttempts
    }

    /// Returns the exponential backoff delay with random jitter for the given attempt.
    public func delay(for attempt: Int) -> Duration {
        let exponentialSeconds = baseDelay.timeInterval * pow(2.0, Double(attempt))
        let jitter = Double.random(in: 0...0.5)
        let totalSeconds = exponentialSeconds + jitter
        let cappedSeconds = min(totalSeconds, maxDelay.timeInterval)
        return .nanoseconds(Int64(cappedSeconds * 1_000_000_000))
    }
}

/// Linear retry policy with a fixed delay between attempts.
public struct PrismLinearRetry: PrismRetryPolicy, Sendable {
    /// The fixed delay between retries.
    public let fixedDelay: Duration
    /// The maximum number of retry attempts allowed.
    public let maxAttempts: Int

    /// Creates a linear retry policy with a constant delay.
    public init(
        fixedDelay: Duration = .seconds(2),
        maxAttempts: Int = 3
    ) {
        self.fixedDelay = fixedDelay
        self.maxAttempts = maxAttempts
    }

    /// Returns whether the request should be retried based on the current attempt count.
    public func shouldRetry(for error: Error, attempt: Int) -> Bool {
        attempt < maxAttempts
    }

    /// Returns the fixed delay duration regardless of attempt number.
    public func delay(for attempt: Int) -> Duration {
        fixedDelay
    }
}

/// Wraps an async throwing closure with retry logic driven by a policy.
public struct PrismRetryableRequest<T: Sendable>: Sendable {
    /// The retry policy governing this request.
    public let policy: any PrismRetryPolicy
    /// The operation to retry on failure.
    public let operation: @Sendable () async throws -> T

    /// Creates a retryable request with the given policy and operation.
    public init(
        policy: any PrismRetryPolicy,
        operation: @escaping @Sendable () async throws -> T
    ) {
        self.policy = policy
        self.operation = operation
    }

    /// Executes the operation, retrying according to the policy on failure.
    public func execute() async throws -> T {
        var attempt = 0
        while true {
            do {
                return try await operation()
            } catch {
                guard policy.shouldRetry(for: error, attempt: attempt) else {
                    throw error
                }
                let waitDuration = policy.delay(for: attempt)
                try await Task.sleep(for: waitDuration)
                attempt += 1
            }
        }
    }
}

// MARK: - Duration helpers

extension Duration {
    /// Converts the Duration to a TimeInterval (seconds).
    var timeInterval: Double {
        let (seconds, attoseconds) = components
        return Double(seconds) + Double(attoseconds) * 1e-18
    }
}
