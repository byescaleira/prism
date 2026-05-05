import Foundation
import Testing

@testable import PrismServer

@Suite("PrismJobStore Protocol Tests")
struct PrismJobStoreProtocolTests {

    @Test("PrismMemoryJobStore conforms to protocol")
    func conformance() async throws {
        let store: any PrismJobStore = PrismMemoryJobStore()
        _ = store
    }

    @Test("Enqueue and count")
    func enqueueAndCount() async throws {
        let store = PrismMemoryJobStore()
        let record = PrismJobRecord(jobType: "email")
        try await store.enqueue(record)
        let count = try await store.count()
        #expect(count == 1)
    }

    @Test("Dequeue returns pending record")
    func dequeue() async throws {
        let store = PrismMemoryJobStore()
        let record = PrismJobRecord(jobType: "email", payload: Data("test".utf8))
        try await store.enqueue(record)
        let dequeued = try await store.dequeue(jobType: "email")
        #expect(dequeued != nil)
        #expect(dequeued?.id == record.id)
        #expect(dequeued?.payload == Data("test".utf8))
    }

    @Test("Dequeue returns nil for wrong job type")
    func dequeueWrongType() async throws {
        let store = PrismMemoryJobStore()
        try await store.enqueue(PrismJobRecord(jobType: "email"))
        let result = try await store.dequeue(jobType: "sms")
        #expect(result == nil)
    }

    @Test("Dequeue returns nil when empty")
    func dequeueEmpty() async throws {
        let store = PrismMemoryJobStore()
        let result = try await store.dequeue(jobType: "email")
        #expect(result == nil)
    }

    @Test("Complete marks job as completed")
    func complete() async throws {
        let store = PrismMemoryJobStore()
        let record = PrismJobRecord(jobType: "email")
        try await store.enqueue(record)
        _ = try await store.dequeue(jobType: "email")
        try await store.complete(jobId: record.id)
        let pending = try await store.pending()
        #expect(pending.isEmpty)
    }

    @Test("Fail increments retry count")
    func failRetry() async throws {
        let store = PrismMemoryJobStore()
        let record = PrismJobRecord(jobType: "email", maxRetries: 3)
        try await store.enqueue(record)
        _ = try await store.dequeue(jobType: "email")
        try await store.fail(jobId: record.id, error: "timeout")
        let pending = try await store.pending()
        #expect(pending.count == 1)
        #expect(pending.first?.retryCount == 1)
        #expect(pending.first?.lastError == "timeout")
    }

    @Test("Fail marks as failed after max retries")
    func failMaxRetries() async throws {
        let store = PrismMemoryJobStore()
        let record = PrismJobRecord(jobType: "email", maxRetries: 1)
        try await store.enqueue(record)
        _ = try await store.dequeue(jobType: "email")
        try await store.fail(jobId: record.id, error: "timeout")
        let pending = try await store.pending()
        #expect(pending.isEmpty)
    }

    @Test("Pending returns only pending records")
    func pendingFilter() async throws {
        let store = PrismMemoryJobStore()
        try await store.enqueue(PrismJobRecord(id: "a", jobType: "email"))
        try await store.enqueue(PrismJobRecord(id: "b", jobType: "email"))
        _ = try await store.dequeue(jobType: "email")
        try await store.complete(jobId: "a")
        let pending = try await store.pending()
        #expect(pending.count == 1)
        #expect(pending.first?.id == "b")
    }

    @Test("FIFO ordering on dequeue")
    func fifoOrdering() async throws {
        let store = PrismMemoryJobStore()
        try await store.enqueue(PrismJobRecord(id: "first", jobType: "email", createdAt: Date.now))
        try await store.enqueue(
            PrismJobRecord(id: "second", jobType: "email", createdAt: Date.now.addingTimeInterval(1)))
        let dequeued = try await store.dequeue(jobType: "email")
        #expect(dequeued?.id == "first")
    }
}

@Suite("PrismJobRecord Tests")
struct PrismJobRecordTests {

    @Test("Default values")
    func defaults() {
        let record = PrismJobRecord(jobType: "email")
        #expect(record.status == .pending)
        #expect(record.retryCount == 0)
        #expect(record.maxRetries == 3)
        #expect(record.lastError == nil)
        #expect(!record.id.isEmpty)
    }

    @Test("Custom values")
    func custom() {
        let data = Data("payload".utf8)
        let record = PrismJobRecord(
            id: "custom-id",
            jobType: "sms",
            payload: data,
            status: .running,
            retryCount: 2,
            maxRetries: 5,
            lastError: "err"
        )
        #expect(record.id == "custom-id")
        #expect(record.jobType == "sms")
        #expect(record.payload == data)
        #expect(record.status == .running)
        #expect(record.retryCount == 2)
        #expect(record.maxRetries == 5)
        #expect(record.lastError == "err")
    }

    @Test("Status enum raw values")
    func statusRawValues() {
        #expect(PrismJobRecordStatus.pending.rawValue == "pending")
        #expect(PrismJobRecordStatus.running.rawValue == "running")
        #expect(PrismJobRecordStatus.completed.rawValue == "completed")
        #expect(PrismJobRecordStatus.failed.rawValue == "failed")
    }
}
