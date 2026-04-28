//
//  PrismOfflineQueue.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import Network

/// A queued network request stored for later execution when connectivity returns.
public struct PrismQueuedRequest: Sendable, Identifiable {
    /// Unique identifier for this queued request.
    public let id: UUID
    /// The URL request to execute when online.
    public let urlRequest: URLRequest
    /// The time this request was enqueued.
    public let createdAt: Date
    /// The number of times this request has been retried.
    public var retryCount: Int
    /// Priority for ordering (higher values execute first).
    public let priority: Int

    /// Creates a new queued request.
    public init(
        id: UUID = UUID(),
        urlRequest: URLRequest,
        createdAt: Date = Date(),
        retryCount: Int = 0,
        priority: Int = 0
    ) {
        self.id = id
        self.urlRequest = urlRequest
        self.createdAt = createdAt
        self.retryCount = retryCount
        self.priority = priority
    }
}

/// Manages pending network requests when the device is offline.
public actor PrismOfflineQueue {
    private var queue: [PrismQueuedRequest] = []
    private var monitor: PrismConnectivityMonitor?
    private var flushHandler: (([PrismQueuedRequest]) async -> Void)?

    /// The number of requests currently in the queue.
    public var count: Int {
        queue.count
    }

    /// Creates an offline queue with optional automatic flush on connectivity restore.
    public init(
        autoFlush: Bool = false,
        flushHandler: (([PrismQueuedRequest]) async -> Void)? = nil
    ) {
        self.flushHandler = flushHandler
        if autoFlush {
            let connectivityMonitor = PrismConnectivityMonitor()
            self.monitor = connectivityMonitor
            Task { [weak self] in
                for await isConnected in connectivityMonitor.connectionStream() {
                    if isConnected {
                        await self?.flush()
                    }
                }
            }
        }
    }

    /// Adds a request to the offline queue.
    public func enqueue(_ request: PrismQueuedRequest) {
        queue.append(request)
    }

    /// Removes and returns all queued requests sorted by priority (descending).
    public func dequeueAll() -> [PrismQueuedRequest] {
        let sorted = queue.sorted { $0.priority > $1.priority }
        queue.removeAll()
        return sorted
    }

    private func flush() async {
        guard !queue.isEmpty else { return }
        let requests = dequeueAll()
        await flushHandler?(requests)
    }
}

/// Monitors network connectivity using NWPathMonitor.
public final class PrismConnectivityMonitor: Sendable {
    private let monitor: NWPathMonitor
    private let monitorQueue: DispatchQueue

    /// Whether the device currently has network connectivity.
    public var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }

    /// Creates a connectivity monitor.
    public init() {
        self.monitor = NWPathMonitor()
        self.monitorQueue = DispatchQueue(label: "com.prism.connectivity")
        self.monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }

    /// Returns an async stream that emits `true` when connectivity is restored.
    public func connectionStream() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status == .satisfied)
            }
            continuation.onTermination = { [weak monitor] _ in
                monitor?.cancel()
            }
        }
    }
}
