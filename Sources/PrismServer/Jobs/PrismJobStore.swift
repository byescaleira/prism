import Foundation

/// Lifecycle states for a job record.
public enum PrismJobRecordStatus: String, Sendable {
    case pending
    case running
    case completed
    case failed
}

/// A stored job record with status, retry count, and error tracking.
public struct PrismJobRecord: Sendable {
    /// The id.
    public let id: String
    /// The job type.
    public let jobType: String
    /// The payload.
    public let payload: Data
    /// The status.
    public let status: PrismJobRecordStatus
    /// The created at.
    public let createdAt: Date
    /// The retry count.
    public let retryCount: Int
    /// The max retries.
    public let maxRetries: Int
    /// The last error.
    public let lastError: String?

    /// Creates a new `PrismJobRecord` with the specified configuration.
    public init(
        id: String = UUID().uuidString,
        jobType: String,
        payload: Data = Data(),
        status: PrismJobRecordStatus = .pending,
        createdAt: Date = .now,
        retryCount: Int = 0,
        maxRetries: Int = 3,
        lastError: String? = nil
    ) {
        self.id = id
        self.jobType = jobType
        self.payload = payload
        self.status = status
        self.createdAt = createdAt
        self.retryCount = retryCount
        self.maxRetries = maxRetries
        self.lastError = lastError
    }
}

/// Storage backend for Job data.
public protocol PrismJobStore: Sendable {
    func enqueue(_ record: PrismJobRecord) async throws
    func dequeue(jobType: String) async throws -> PrismJobRecord?
    func complete(jobId: String) async throws
    func fail(jobId: String, error: String) async throws
    func pending() async throws -> [PrismJobRecord]
    func count() async throws -> Int
}

/// Storage backend for MemoryJob data.
public actor PrismMemoryJobStore: PrismJobStore {
    private var records: [String: PrismJobRecord] = [:]

    /// Creates a new `PrismMemoryJobStore` with the specified configuration.
    public init() {}

    /// Stores a job record in memory for later processing.
    public func enqueue(_ record: PrismJobRecord) async throws {
        records[record.id] = record
    }

    /// Returns the next pending job of the specified type, marking it as running.
    public func dequeue(jobType: String) async throws -> PrismJobRecord? {
        guard
            let record = records.values
                .filter({ $0.jobType == jobType && $0.status == .pending })
                .sorted(by: { $0.createdAt < $1.createdAt })
                .first
        else { return nil }

        records[record.id] = PrismJobRecord(
            id: record.id,
            jobType: record.jobType,
            payload: record.payload,
            status: .running,
            createdAt: record.createdAt,
            retryCount: record.retryCount,
            maxRetries: record.maxRetries,
            lastError: record.lastError
        )
        return record
    }

    /// Marks a job as completed and clears its last error.
    public func complete(jobId: String) async throws {
        guard let record = records[jobId] else { return }
        records[jobId] = PrismJobRecord(
            id: record.id,
            jobType: record.jobType,
            payload: record.payload,
            status: .completed,
            createdAt: record.createdAt,
            retryCount: record.retryCount,
            maxRetries: record.maxRetries,
            lastError: nil
        )
    }

    /// Records a job failure, incrementing the retry count.
    public func fail(jobId: String, error: String) async throws {
        guard let record = records[jobId] else { return }
        let newRetry = record.retryCount + 1
        let newStatus: PrismJobRecordStatus = newRetry >= record.maxRetries ? .failed : .pending
        records[jobId] = PrismJobRecord(
            id: record.id,
            jobType: record.jobType,
            payload: record.payload,
            status: newStatus,
            createdAt: record.createdAt,
            retryCount: newRetry,
            maxRetries: record.maxRetries,
            lastError: error
        )
    }

    /// Returns all pending job records sorted by creation date.
    public func pending() async throws -> [PrismJobRecord] {
        records.values.filter { $0.status == .pending }.sorted { $0.createdAt < $1.createdAt }
    }

    /// Returns the total number of stored job records.
    public func count() async throws -> Int {
        records.count
    }
}
