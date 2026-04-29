#if canImport(SQLite3)
import Foundation
import SQLite3

// MARK: - Job Status

public enum PrismJobStatus: String, Sendable {
    case pending
    case processing
    case completed
    case failed
    case deadLetter = "dead_letter"
}

// MARK: - Job Priority

public enum PrismJobPriority: Int, Sendable, Comparable {
    case low = 0
    case normal = 5
    case high = 10
    case critical = 20

    public static func < (lhs: PrismJobPriority, rhs: PrismJobPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Persistent Job

public struct PrismPersistentJob: Sendable {
    public let id: String
    public let queue: String
    public let payload: String
    public let status: PrismJobStatus
    public let priority: PrismJobPriority
    public let attempts: Int
    public let maxAttempts: Int
    public let lastError: String?
    public let createdAt: String
    public let updatedAt: String
    public let scheduledAt: String?

    public init(
        id: String = UUID().uuidString,
        queue: String = "default",
        payload: String,
        status: PrismJobStatus = .pending,
        priority: PrismJobPriority = .normal,
        attempts: Int = 0,
        maxAttempts: Int = 3,
        lastError: String? = nil,
        createdAt: String = "",
        updatedAt: String = "",
        scheduledAt: String? = nil
    ) {
        self.id = id
        self.queue = queue
        self.payload = payload
        self.status = status
        self.priority = priority
        self.attempts = attempts
        self.maxAttempts = maxAttempts
        self.lastError = lastError
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.scheduledAt = scheduledAt
    }
}

// MARK: - Job Handler

public typealias PrismJobHandler = @Sendable (PrismPersistentJob) async throws -> Void

// MARK: - Queue Configuration

public struct PrismQueueConfig: Sendable {
    public let maxAttempts: Int
    public let retryBaseDelay: TimeInterval
    public let retryMaxDelay: TimeInterval
    public let pollInterval: TimeInterval
    public let batchSize: Int

    public init(
        maxAttempts: Int = 3,
        retryBaseDelay: TimeInterval = 5,
        retryMaxDelay: TimeInterval = 300,
        pollInterval: TimeInterval = 1,
        batchSize: Int = 10
    ) {
        self.maxAttempts = maxAttempts
        self.retryBaseDelay = retryBaseDelay
        self.retryMaxDelay = retryMaxDelay
        self.pollInterval = pollInterval
        self.batchSize = batchSize
    }
}

// MARK: - Persistent Queue

public actor PrismPersistentQueueStore {
    private let db: PrismDatabase
    private let config: PrismQueueConfig
    private var initialized = false

    public init(database: PrismDatabase, config: PrismQueueConfig = PrismQueueConfig()) {
        self.db = database
        self.config = config
    }

    private func ensureTable() async throws {
        guard !initialized else { return }
        try await db.execute("""
            CREATE TABLE IF NOT EXISTS _prism_jobs (
                id TEXT PRIMARY KEY,
                queue TEXT NOT NULL DEFAULT 'default',
                payload TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'pending',
                priority INTEGER NOT NULL DEFAULT 5,
                attempts INTEGER NOT NULL DEFAULT 0,
                max_attempts INTEGER NOT NULL DEFAULT 3,
                last_error TEXT,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                updated_at TEXT NOT NULL DEFAULT (datetime('now')),
                scheduled_at TEXT
            )
        """)
        try await db.execute("""
            CREATE INDEX IF NOT EXISTS idx_prism_jobs_status_priority
            ON _prism_jobs(status, priority DESC, created_at ASC)
        """)
        try await db.execute("""
            CREATE INDEX IF NOT EXISTS idx_prism_jobs_queue
            ON _prism_jobs(queue, status)
        """)
        initialized = true
    }

    public func enqueue(
        queue: String = "default",
        payload: String,
        priority: PrismJobPriority = .normal,
        maxAttempts: Int? = nil,
        scheduledAt: String? = nil
    ) async throws -> String {
        try await ensureTable()
        let id = UUID().uuidString
        let maxAtt = maxAttempts ?? config.maxAttempts
        try await db.execute("""
            INSERT INTO _prism_jobs (id, queue, payload, status, priority, max_attempts, scheduled_at)
            VALUES (?, ?, ?, 'pending', ?, ?, ?)
        """, parameters: [
            .text(id), .text(queue), .text(payload),
            .int(priority.rawValue), .int(maxAtt),
            scheduledAt.map { PrismDatabaseValue.text($0) } ?? .null
        ])
        return id
    }

    public func dequeue(queue: String = "default", limit: Int? = nil) async throws -> [PrismPersistentJob] {
        try await ensureTable()
        let batchSize = limit ?? config.batchSize
        let rows = try await db.query("""
            SELECT * FROM _prism_jobs
            WHERE queue = ? AND status = 'pending'
            AND (scheduled_at IS NULL OR scheduled_at <= datetime('now'))
            ORDER BY priority DESC, created_at ASC
            LIMIT ?
        """, parameters: [.text(queue), .int(batchSize)])

        var jobs: [PrismPersistentJob] = []
        for row in rows {
            guard let job = jobFromRow(row) else { continue }
            try await db.execute("""
                UPDATE _prism_jobs SET status = 'processing', attempts = attempts + 1,
                updated_at = datetime('now') WHERE id = ?
            """, parameters: [.text(job.id)])
            jobs.append(PrismPersistentJob(
                id: job.id, queue: job.queue, payload: job.payload,
                status: .processing, priority: job.priority,
                attempts: job.attempts + 1, maxAttempts: job.maxAttempts,
                lastError: job.lastError, createdAt: job.createdAt,
                updatedAt: job.updatedAt, scheduledAt: job.scheduledAt
            ))
        }
        return jobs
    }

    public func complete(_ jobId: String) async throws {
        try await ensureTable()
        try await db.execute("""
            UPDATE _prism_jobs SET status = 'completed', updated_at = datetime('now') WHERE id = ?
        """, parameters: [.text(jobId)])
    }

    public func fail(_ jobId: String, error: String) async throws {
        try await ensureTable()
        let rows = try await db.query(
            "SELECT attempts, max_attempts FROM _prism_jobs WHERE id = ?",
            parameters: [.text(jobId)]
        )
        guard let row = rows.first else { return }
        let attempts = row.int("attempts") ?? 0
        let maxAttempts = row.int("max_attempts") ?? config.maxAttempts

        if attempts >= maxAttempts {
            try await db.execute("""
                UPDATE _prism_jobs SET status = 'dead_letter', last_error = ?,
                updated_at = datetime('now') WHERE id = ?
            """, parameters: [.text(error), .text(jobId)])
        } else {
            let delay = retryDelay(attempt: attempts)
            let scheduledAt = ISO8601DateFormatter().string(from: Date().addingTimeInterval(delay))
            try await db.execute("""
                UPDATE _prism_jobs SET status = 'pending', last_error = ?,
                scheduled_at = ?, updated_at = datetime('now') WHERE id = ?
            """, parameters: [.text(error), .text(scheduledAt), .text(jobId)])
        }
    }

    public func retry(_ jobId: String) async throws {
        try await ensureTable()
        try await db.execute("""
            UPDATE _prism_jobs SET status = 'pending', scheduled_at = NULL,
            updated_at = datetime('now') WHERE id = ?
        """, parameters: [.text(jobId)])
    }

    public func getJob(_ jobId: String) async throws -> PrismPersistentJob? {
        try await ensureTable()
        let rows = try await db.query(
            "SELECT * FROM _prism_jobs WHERE id = ?",
            parameters: [.text(jobId)]
        )
        return rows.first.flatMap(jobFromRow)
    }

    public func deadLetterJobs(queue: String = "default") async throws -> [PrismPersistentJob] {
        try await ensureTable()
        let rows = try await db.query(
            "SELECT * FROM _prism_jobs WHERE queue = ? AND status = 'dead_letter' ORDER BY updated_at DESC",
            parameters: [.text(queue)]
        )
        return rows.compactMap(jobFromRow)
    }

    public func purgeCompleted(olderThanDays: Int = 7) async throws -> Int {
        try await ensureTable()
        return try await db.execute("""
            DELETE FROM _prism_jobs WHERE status = 'completed'
            AND updated_at < datetime('now', '-\(olderThanDays) days')
        """)
    }

    public func stats(queue: String = "default") async throws -> [String: Int] {
        try await ensureTable()
        let rows = try await db.query("""
            SELECT status, COUNT(*) as count FROM _prism_jobs
            WHERE queue = ? GROUP BY status
        """, parameters: [.text(queue)])

        var result: [String: Int] = [:]
        for row in rows {
            if let status = row.text("status"), let count = row.int("count") {
                result[status] = count
            }
        }
        return result
    }

    public func pendingCount(queue: String = "default") async throws -> Int {
        try await ensureTable()
        let rows = try await db.query(
            "SELECT COUNT(*) as count FROM _prism_jobs WHERE queue = ? AND status = 'pending'",
            parameters: [.text(queue)]
        )
        return rows.first?.int("count") ?? 0
    }

    // MARK: - Private

    private func retryDelay(attempt: Int) -> TimeInterval {
        let delay = config.retryBaseDelay * pow(2.0, Double(attempt - 1))
        return min(delay, config.retryMaxDelay)
    }

    private func jobFromRow(_ row: PrismRow) -> PrismPersistentJob? {
        guard let id = row.text("id"),
              let queue = row.text("queue"),
              let payload = row.text("payload"),
              let statusStr = row.text("status") else { return nil }

        let status = PrismJobStatus(rawValue: statusStr) ?? .pending
        let priorityVal = row.int("priority") ?? 5
        let priority: PrismJobPriority
        switch priorityVal {
        case 0: priority = .low
        case 10: priority = .high
        case 20: priority = .critical
        default: priority = .normal
        }

        return PrismPersistentJob(
            id: id,
            queue: queue,
            payload: payload,
            status: status,
            priority: priority,
            attempts: row.int("attempts") ?? 0,
            maxAttempts: row.int("max_attempts") ?? 3,
            lastError: row.text("last_error"),
            createdAt: row.text("created_at") ?? "",
            updatedAt: row.text("updated_at") ?? "",
            scheduledAt: row.text("scheduled_at")
        )
    }
}

// MARK: - Queue Worker

public actor PrismQueueWorker {
    private let store: PrismPersistentQueueStore
    private let queue: String
    private var handlers: [String: PrismJobHandler] = [:]
    private var defaultHandler: PrismJobHandler?
    private var running = false

    public init(store: PrismPersistentQueueStore, queue: String = "default") {
        self.store = store
        self.queue = queue
    }

    public func registerHandler(for type: String, handler: @escaping PrismJobHandler) {
        handlers[type] = handler
    }

    public func setDefaultHandler(_ handler: @escaping PrismJobHandler) {
        defaultHandler = handler
    }

    public func processNext() async throws -> Int {
        let jobs = try await store.dequeue(queue: queue, limit: 1)
        for job in jobs {
            do {
                if let handler = handlers[job.queue] ?? defaultHandler {
                    try await handler(job)
                }
                try await store.complete(job.id)
            } catch {
                try await store.fail(job.id, error: "\(error)")
            }
        }
        return jobs.count
    }
}

#endif
