import Foundation

/// A unit of background work.
public protocol PrismJob: Sendable {
    /// Unique job type identifier.
    static var name: String { get }
    /// Executes the job. Throw to trigger retry.
    func execute() async throws
}

extension PrismJob {
    /// The default `name` value.
    public static var name: String { String(describing: Self.self) }
}

/// Job scheduling configuration.
public struct PrismJobSchedule: Sendable {
    /// Delay before first execution.
    public let initialDelay: TimeInterval
    /// Interval between repeated executions. Nil = run once.
    public let repeatInterval: TimeInterval?
    /// Maximum retry attempts on failure.
    public let maxRetries: Int
    /// Delay between retries (exponential backoff applied).
    public let retryDelay: TimeInterval

    /// Creates a new `PrismJobSchedule` with the specified configuration.
    public init(
        initialDelay: TimeInterval = 0,
        repeatInterval: TimeInterval? = nil,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 1
    ) {
        self.initialDelay = initialDelay
        self.repeatInterval = repeatInterval
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }

    /// Run once immediately.
    public static let immediate = PrismJobSchedule()

    /// Run once after a delay.
    public static func delayed(_ seconds: TimeInterval) -> PrismJobSchedule {
        PrismJobSchedule(initialDelay: seconds)
    }

    /// Run repeatedly at a fixed interval.
    public static func every(_ seconds: TimeInterval) -> PrismJobSchedule {
        PrismJobSchedule(repeatInterval: seconds)
    }
}

/// Actor-based job queue with scheduling, retry, and cancellation.
public actor PrismJobQueue {
    private var runningTasks: [String: Task<Void, Never>] = [:]
    private var isRunning = false

    /// Creates a new `PrismJobQueue` with the specified configuration.
    public init() {}

    /// Enqueues a job with the given schedule.
    @discardableResult
    public func enqueue(_ job: any PrismJob, schedule: PrismJobSchedule = .immediate, id: String? = nil) -> String {
        let jobID = id ?? UUID().uuidString

        let task = Task { [schedule] in
            if schedule.initialDelay > 0 {
                try? await Task.sleep(for: .seconds(schedule.initialDelay))
            }

            var attempt = 0
            var shouldContinue = true

            while shouldContinue && !Task.isCancelled {
                do {
                    try await job.execute()
                    attempt = 0
                } catch {
                    attempt += 1
                    if attempt > schedule.maxRetries {
                        break
                    }
                    let backoff = schedule.retryDelay * pow(2.0, Double(attempt - 1))
                    try? await Task.sleep(for: .seconds(backoff))
                    continue
                }

                if let interval = schedule.repeatInterval {
                    try? await Task.sleep(for: .seconds(interval))
                } else {
                    shouldContinue = false
                }
            }
        }

        runningTasks[jobID] = task
        return jobID
    }

    /// Cancels a specific job.
    public func cancel(_ jobID: String) {
        runningTasks[jobID]?.cancel()
        runningTasks.removeValue(forKey: jobID)
    }

    /// Cancels all running jobs.
    public func cancelAll() {
        for task in runningTasks.values {
            task.cancel()
        }
        runningTasks.removeAll()
    }

    /// Number of active jobs.
    public var activeJobCount: Int {
        runningTasks.count
    }
}

/// A cron-like scheduler that runs jobs at fixed intervals.
public actor PrismScheduler {
    private let queue: PrismJobQueue

    /// Creates a new `PrismScheduler` with the specified configuration.
    public init(queue: PrismJobQueue = PrismJobQueue()) {
        self.queue = queue
    }

    /// Schedules a job to run every N seconds.
    @discardableResult
    public func every(_ seconds: TimeInterval, job: any PrismJob) async -> String {
        await queue.enqueue(job, schedule: .every(seconds))
    }

    /// Schedules a job to run once after a delay.
    @discardableResult
    public func after(_ seconds: TimeInterval, job: any PrismJob) async -> String {
        await queue.enqueue(job, schedule: .delayed(seconds))
    }

    /// Cancels a scheduled job.
    public func cancel(_ jobID: String) async {
        await queue.cancel(jobID)
    }

    /// Cancels all scheduled jobs.
    public func cancelAll() async {
        await queue.cancelAll()
    }
}
