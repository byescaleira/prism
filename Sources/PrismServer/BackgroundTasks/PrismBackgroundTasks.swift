import Foundation

/// Metadata for a running background task.
public struct PrismBackgroundTask: Sendable {
    /// The unique identifier for this task.
    public let id: String
    /// The human-readable name of this task.
    public let name: String
    /// The time when this task was started.
    public let startedAt: Date
}

/// Actor-based manager for fire-and-forget background tasks.
public actor PrismBackgroundTaskManager {
    private var tasks: [String: Task<Void, Never>] = [:]
    private var metadata: [String: PrismBackgroundTask] = [:]

    /// Creates a new background task manager.
    public init() {}

    /// Runs a fire-and-forget task, tracked by the manager.
    public func run(_ name: String, task: @escaping @Sendable () async throws -> Void) {
        let id = UUID().uuidString
        let info = PrismBackgroundTask(id: id, name: name, startedAt: Date())
        metadata[id] = info

        let managerRef = self
        let handle = Task<Void, Never> {
            do {
                try await task()
            } catch {
                // Task failed silently — fire-and-forget
            }
            await managerRef.removeTask(id: id)
        }
        tasks[id] = handle
    }

    /// Runs a task and returns the Task handle for awaiting its result.
    public func runWithResult<T: Sendable>(_ name: String, task: @escaping @Sendable () async throws -> T) -> Task<
        T, Error
    > {
        let id = UUID().uuidString
        let info = PrismBackgroundTask(id: id, name: name, startedAt: Date())
        metadata[id] = info

        let managerRef = self
        let handle = Task<Void, Never> {
            // Tracking wrapper — actual result is in the returned Task
            await managerRef.removeTask(id: id)
        }
        tasks[id] = handle

        return Task<T, Error> {
            defer { handle.cancel() }
            let result = try await task()
            await managerRef.removeTask(id: id)
            return result
        }
    }

    /// Cancels all running tasks.
    public func cancelAll() {
        for (_, task) in tasks {
            task.cancel()
        }
        tasks.removeAll()
        metadata.removeAll()
    }

    /// Cancels a specific task by ID.
    public func cancel(id: String) {
        tasks[id]?.cancel()
        tasks.removeValue(forKey: id)
        metadata.removeValue(forKey: id)
    }

    /// Currently active tasks.
    public var activeTasks: [PrismBackgroundTask] {
        Array(metadata.values)
    }

    /// Number of active tasks.
    public var activeCount: Int {
        tasks.count
    }

    private func removeTask(id: String) {
        tasks.removeValue(forKey: id)
        metadata.removeValue(forKey: id)
    }
}

/// Actor that manages a group of related background tasks.
public actor PrismTaskGroup {
    private var tasks: [Task<Void, Never>] = []

    /// Creates a new task group.
    public init() {}

    /// Adds a task to the group.
    public func add(_ name: String, task: @escaping @Sendable () async throws -> Void) {
        let handle = Task<Void, Never> {
            do {
                try await task()
            } catch {
                // Silently handle errors in group tasks
            }
        }
        tasks.append(handle)
    }

    /// Waits for all tasks in the group to complete.
    public func awaitAll() async {
        for task in tasks {
            _ = await task.result
        }
        tasks.removeAll()
    }

    /// Cancels all tasks in the group.
    public func cancelAll() {
        for task in tasks {
            task.cancel()
        }
        tasks.removeAll()
    }
}
