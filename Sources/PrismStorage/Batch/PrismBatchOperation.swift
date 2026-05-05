import Foundation

/// Batch operation types for bulk storage mutations.
public enum PrismBatchAction<T: Codable & Sendable>: Sendable {
    case save(key: String, value: T)
    case delete(key: String)
}

/// Executes bulk operations against a sync store in a single logical batch.
public struct PrismBatchWriter: Sendable {
    private let store: PrismStorageProtocol

    public init(store: PrismStorageProtocol) {
        self.store = store
    }

    @discardableResult
    public func execute<T: Codable & Sendable>(
        _ actions: [PrismBatchAction<T>]
    ) throws -> PrismBatchResult {
        var succeeded = 0
        var failed = 0

        for action in actions {
            do {
                switch action {
                case .save(let key, let value):
                    try store.save(value, forKey: key)
                case .delete(let key):
                    try store.delete(forKey: key)
                }
                succeeded += 1
            } catch {
                failed += 1
            }
        }

        return PrismBatchResult(total: actions.count, succeeded: succeeded, failed: failed)
    }

    public func saveAll<T: Codable & Sendable>(
        _ items: [(key: String, value: T)]
    ) throws -> PrismBatchResult {
        try execute(items.map { .save(key: $0.key, value: $0.value) })
    }

    public func deleteAll(_ keys: [String]) throws -> PrismBatchResult {
        var succeeded = 0
        var failed = 0
        for key in keys {
            do {
                try store.delete(forKey: key)
                succeeded += 1
            } catch {
                failed += 1
            }
        }
        return PrismBatchResult(total: keys.count, succeeded: succeeded, failed: failed)
    }
}

/// Async variant for actor-based stores.
public struct PrismAsyncBatchWriter: Sendable {
    private let store: PrismAsyncStorageProtocol

    public init(store: PrismAsyncStorageProtocol) {
        self.store = store
    }

    @discardableResult
    public func execute<T: Codable & Sendable>(
        _ actions: [PrismBatchAction<T>]
    ) async throws -> PrismBatchResult {
        var succeeded = 0
        var failed = 0

        for action in actions {
            do {
                switch action {
                case .save(let key, let value):
                    try await store.save(value, forKey: key)
                case .delete(let key):
                    try await store.delete(forKey: key)
                }
                succeeded += 1
            } catch {
                failed += 1
            }
        }

        return PrismBatchResult(total: actions.count, succeeded: succeeded, failed: failed)
    }

    public func saveAll<T: Codable & Sendable>(
        _ items: [(key: String, value: T)]
    ) async throws -> PrismBatchResult {
        try await execute(items.map { .save(key: $0.key, value: $0.value) })
    }

    public func deleteAll(_ keys: [String]) async throws -> PrismBatchResult {
        var succeeded = 0
        var failed = 0
        for key in keys {
            do {
                try await store.delete(forKey: key)
                succeeded += 1
            } catch {
                failed += 1
            }
        }
        return PrismBatchResult(total: keys.count, succeeded: succeeded, failed: failed)
    }
}

public struct PrismBatchResult: Sendable, Equatable {
    public let total: Int
    public let succeeded: Int
    public let failed: Int

    public var allSucceeded: Bool { failed == 0 }
}
