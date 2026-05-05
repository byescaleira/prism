import Foundation

/// Configuration for cluster/worker mode.
public struct PrismClusterConfig: Sendable {
    /// The number of worker processes to spawn.
    public let workerCount: Int
    /// Whether crashed workers should be automatically restarted.
    public let restartOnCrash: Bool
    /// Maximum time to wait for workers to shut down gracefully.
    public let shutdownTimeout: Duration

    /// Creates a cluster configuration with the specified parameters.
    public init(
        workerCount: Int = ProcessInfo.processInfo.activeProcessorCount,
        restartOnCrash: Bool = true,
        shutdownTimeout: Duration = .seconds(30)
    ) {
        self.workerCount = workerCount
        self.restartOnCrash = restartOnCrash
        self.shutdownTimeout = shutdownTimeout
    }
}

/// Status of a worker process.
public enum PrismWorkerStatus: String, Sendable {
    /// The worker is running normally.
    case running
    /// The worker has been stopped gracefully.
    case stopped
    /// The worker exited with a non-zero status.
    case crashed
}

/// Information about a worker process.
public struct PrismWorkerInfo: Sendable {
    /// The system process identifier.
    public let pid: Int32
    /// The logical worker index.
    public let workerID: Int
    /// The time when the worker was spawned.
    public let startedAt: Date
    /// The current status of the worker.
    public var status: PrismWorkerStatus

    /// Creates worker info with the given PID, index, start time, and status.
    public init(pid: Int32, workerID: Int, startedAt: Date = Date(), status: PrismWorkerStatus = .running) {
        self.pid = pid
        self.workerID = workerID
        self.startedAt = startedAt
        self.status = status
    }
}

/// Manages multiple worker processes.
public actor PrismClusterManager {
    private let config: PrismClusterConfig
    private var workerInfos: [Int32: PrismWorkerInfo] = [:]
    private var processes: [Int32: Process] = [:]
    private var isRunning = false
    private var executable: String = ""
    private var arguments: [String] = []

    /// Creates a cluster manager with the given configuration.
    public init(config: PrismClusterConfig = PrismClusterConfig()) {
        self.config = config
    }

    /// Spawns worker processes.
    public func start(executable: String, arguments: [String] = []) async throws {
        guard !isRunning else { return }
        isRunning = true
        self.executable = executable
        self.arguments = arguments

        for i in 0..<config.workerCount {
            try spawnWorker(id: i)
        }

        if config.restartOnCrash {
            monitorWorkers()
        }
    }

    /// Stops all worker processes.
    public func stop() async {
        isRunning = false
        for (_, process) in processes {
            if process.isRunning {
                process.terminate()
            }
        }
        processes.removeAll()
        for key in workerInfos.keys {
            workerInfos[key]?.status = .stopped
        }
    }

    /// Restarts a specific worker by PID.
    public func restart(pid: Int32) throws {
        guard let info = workerInfos[pid] else { return }
        if let process = processes[pid], process.isRunning {
            process.terminate()
        }
        processes.removeValue(forKey: pid)
        workerInfos.removeValue(forKey: pid)
        try spawnWorker(id: info.workerID)
    }

    /// All worker information.
    public var workers: [PrismWorkerInfo] {
        Array(workerInfos.values)
    }

    /// Number of actively running workers.
    public var activeWorkerCount: Int {
        workerInfos.values.filter { $0.status == .running }.count
    }

    private func spawnWorker(id: Int) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)

        var env = ProcessInfo.processInfo.environment
        env["PRISM_WORKER"] = "true"
        env["PRISM_WORKER_ID"] = "\(id)"
        process.environment = env
        process.arguments = arguments

        try process.run()
        let pid = process.processIdentifier
        processes[pid] = process
        workerInfos[pid] = PrismWorkerInfo(pid: pid, workerID: id)
    }

    private nonisolated func monitorWorkers() {
        Task {
            while await isRunning {
                try? await Task.sleep(for: .seconds(1))
                await checkWorkers()
            }
        }
    }

    private func checkWorkers() {
        for (pid, process) in processes where !process.isRunning {
            let exitStatus = process.terminationStatus
            if exitStatus != 0 && isRunning {
                workerInfos[pid]?.status = .crashed
                if let info = workerInfos[pid] {
                    processes.removeValue(forKey: pid)
                    workerInfos.removeValue(forKey: pid)
                    try? spawnWorker(id: info.workerID)
                }
            } else {
                workerInfos[pid]?.status = .stopped
            }
        }
    }
}

/// Cluster mode detection utilities.
public enum PrismCluster {
    /// Whether this process is a worker (has PRISM_WORKER env var).
    public static var isWorker: Bool {
        ProcessInfo.processInfo.environment["PRISM_WORKER"] == "true"
    }

    /// Whether this process is the primary/manager.
    public static var isPrimary: Bool { !isWorker }

    /// The worker ID from PRISM_WORKER_ID env var.
    public static var workerID: Int? {
        ProcessInfo.processInfo.environment["PRISM_WORKER_ID"].flatMap(Int.init)
    }
}

/// Cluster mode enum for explicit branching.
public enum PrismClusterMode: Sendable, Equatable {
    /// This process is the primary/manager process.
    case primary
    /// This process is a worker with the given ID.
    case worker(id: Int)

    /// Detects the current cluster mode from environment variables.
    public static var current: PrismClusterMode {
        if let id = PrismCluster.workerID {
            return .worker(id: id)
        }
        return .primary
    }
}
