import Foundation

public enum PrismJobRecordStatus: String, Sendable {
    case pending
    case running
    case completed
    case failed
}

public struct PrismJobRecord: Sendable {
    public let id: String
    public let jobType: String
    public let payload: Data
    public let status: PrismJobRecordStatus
    public let createdAt: Date
    public let retryCount: Int
    public let maxRetries: Int
    public let lastError: String?

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

public protocol PrismJobStore: Sendable {
    func enqueue(_ record: PrismJobRecord) async throws
    func dequeue(jobType: String) async throws -> PrismJobRecord?
    func complete(jobId: String) async throws
    func fail(jobId: String, error: String) async throws
    func pending() async throws -> [PrismJobRecord]
    func count() async throws -> Int
}

public actor PrismMemoryJobStore: PrismJobStore {
    private var records: [String: PrismJobRecord] = [:]

    public init() {}

    public func enqueue(_ record: PrismJobRecord) async throws {
        records[record.id] = record
    }

    public func dequeue(jobType: String) async throws -> PrismJobRecord? {
        guard let record = records.values
            .filter({ $0.jobType == jobType && $0.status == .pending })
            .sorted(by: { $0.createdAt < $1.createdAt })
            .first else { return nil }

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

    public func pending() async throws -> [PrismJobRecord] {
        records.values.filter { $0.status == .pending }.sorted { $0.createdAt < $1.createdAt }
    }

    public func count() async throws -> Int {
        records.count
    }
}
