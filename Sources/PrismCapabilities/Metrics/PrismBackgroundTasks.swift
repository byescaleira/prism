#if canImport(BackgroundTasks)
import BackgroundTasks

// MARK: - Task Type

/// The type of background task to register.
public enum PrismBackgroundTaskType: Sendable {
    case appRefresh
    case processing
}

// MARK: - Task Config

/// Configuration for registering and scheduling a background task.
public struct PrismBackgroundTaskConfig: Sendable {
    /// The task identifier registered in Info.plist under BGTaskSchedulerPermittedIdentifiers.
    public let identifier: String
    /// Whether this is an app-refresh or processing task.
    public let type: PrismBackgroundTaskType
    /// Whether the task requires network connectivity.
    public let requiresNetwork: Bool
    /// Whether the task requires the device to be charging.
    public let requiresCharging: Bool
    /// The earliest date the task should begin, if any.
    public let earliestBeginDate: Date?

    public init(identifier: String, type: PrismBackgroundTaskType, requiresNetwork: Bool = false, requiresCharging: Bool = false, earliestBeginDate: Date? = nil) {
        self.identifier = identifier
        self.type = type
        self.requiresNetwork = requiresNetwork
        self.requiresCharging = requiresCharging
        self.earliestBeginDate = earliestBeginDate
    }
}

// MARK: - Background Task Client

/// Client that wraps BGTaskScheduler for registering and scheduling background tasks.
public final class PrismBackgroundTaskClient: Sendable {

    public init() {}

    /// Registers a background task handler with the system.
    public func register(config: PrismBackgroundTaskConfig, handler: @escaping @Sendable () async -> Bool) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: config.identifier, using: nil) { task in
            let work = Task {
                let success = await handler()
                task.setTaskCompleted(success: success)
            }
            task.expirationHandler = {
                work.cancel()
            }
        }
    }

    /// Schedules the next execution of a background task.
    public func schedule(config: PrismBackgroundTaskConfig) throws {
        let request: BGTaskRequest
        switch config.type {
        case .appRefresh:
            request = BGAppRefreshTaskRequest(identifier: config.identifier)
        case .processing:
            let processingRequest = BGProcessingTaskRequest(identifier: config.identifier)
            processingRequest.requiresNetworkConnectivity = config.requiresNetwork
            processingRequest.requiresExternalPower = config.requiresCharging
            request = processingRequest
        }
        request.earliestBeginDate = config.earliestBeginDate
        try BGTaskScheduler.shared.submit(request)
    }

    /// Cancels a pending background task by identifier.
    public func cancel(identifier: String) {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
    }

    /// Cancels all pending background task requests.
    public func cancelAll() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
}
#endif
