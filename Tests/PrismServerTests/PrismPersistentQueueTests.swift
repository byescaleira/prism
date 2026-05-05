#if canImport(SQLite3)
    import Testing
    import Foundation
    @testable import PrismServer

    @Suite("PrismJobStatus Tests")
    struct PrismJobStatusTests {

        @Test("Raw values match expected strings")
        func rawValues() {
            #expect(PrismJobStatus.pending.rawValue == "pending")
            #expect(PrismJobStatus.processing.rawValue == "processing")
            #expect(PrismJobStatus.completed.rawValue == "completed")
            #expect(PrismJobStatus.failed.rawValue == "failed")
            #expect(PrismJobStatus.deadLetter.rawValue == "dead_letter")
        }

        @Test("Init from raw value")
        func initFromRaw() {
            #expect(PrismJobStatus(rawValue: "pending") == .pending)
            #expect(PrismJobStatus(rawValue: "dead_letter") == .deadLetter)
            #expect(PrismJobStatus(rawValue: "invalid") == nil)
        }
    }

    @Suite("PrismJobPriority Tests")
    struct PrismJobPriorityTests {

        @Test("Priority ordering")
        func ordering() {
            #expect(PrismJobPriority.low < .normal)
            #expect(PrismJobPriority.normal < .high)
            #expect(PrismJobPriority.high < .critical)
        }

        @Test("Raw values")
        func rawValues() {
            #expect(PrismJobPriority.low.rawValue == 0)
            #expect(PrismJobPriority.normal.rawValue == 5)
            #expect(PrismJobPriority.high.rawValue == 10)
            #expect(PrismJobPriority.critical.rawValue == 20)
        }
    }

    @Suite("PrismPersistentJob Tests")
    struct PrismPersistentJobTests {

        @Test("Default values")
        func defaults() {
            let job = PrismPersistentJob(payload: "{\"task\":\"test\"}")
            #expect(job.queue == "default")
            #expect(job.status == .pending)
            #expect(job.priority == .normal)
            #expect(job.attempts == 0)
            #expect(job.maxAttempts == 3)
            #expect(job.lastError == nil)
            #expect(job.scheduledAt == nil)
        }

        @Test("Custom values")
        func custom() {
            let job = PrismPersistentJob(
                id: "custom-id",
                queue: "emails",
                payload: "{\"to\":\"user@test.com\"}",
                status: .processing,
                priority: .high,
                attempts: 2,
                maxAttempts: 5,
                lastError: "timeout",
                scheduledAt: "2025-01-01T00:00:00Z"
            )
            #expect(job.id == "custom-id")
            #expect(job.queue == "emails")
            #expect(job.status == .processing)
            #expect(job.priority == .high)
            #expect(job.attempts == 2)
            #expect(job.maxAttempts == 5)
            #expect(job.lastError == "timeout")
            #expect(job.scheduledAt == "2025-01-01T00:00:00Z")
        }
    }

    @Suite("PrismQueueConfig Tests")
    struct PrismQueueConfigTests {

        @Test("Default config values")
        func defaults() {
            let config = PrismQueueConfig()
            #expect(config.maxAttempts == 3)
            #expect(config.retryBaseDelay == 5)
            #expect(config.retryMaxDelay == 300)
            #expect(config.pollInterval == 1)
            #expect(config.batchSize == 10)
        }

        @Test("Custom config values")
        func custom() {
            let config = PrismQueueConfig(
                maxAttempts: 5,
                retryBaseDelay: 10,
                retryMaxDelay: 600,
                pollInterval: 2,
                batchSize: 20
            )
            #expect(config.maxAttempts == 5)
            #expect(config.retryBaseDelay == 10)
            #expect(config.retryMaxDelay == 600)
            #expect(config.pollInterval == 2)
            #expect(config.batchSize == 20)
        }
    }

    @Suite("PrismPersistentQueueStore Integration Tests")
    struct PrismPersistentQueueStoreTests {

        private func makeStore() async throws -> PrismPersistentQueueStore {
            let db = try PrismDatabase(path: ":memory:")
            return PrismPersistentQueueStore(database: db)
        }

        @Test("Enqueue and dequeue job")
        func enqueueDequeue() async throws {
            let store = try await makeStore()
            let id = try await store.enqueue(payload: "{\"action\":\"send_email\"}")
            let jobs = try await store.dequeue(limit: 1)
            #expect(jobs.count == 1)
            #expect(jobs[0].id == id)
            #expect(jobs[0].status == .processing)
            #expect(jobs[0].payload == "{\"action\":\"send_email\"}")
        }

        @Test("Dequeue returns empty when no pending jobs")
        func dequeueEmpty() async throws {
            let store = try await makeStore()
            let jobs = try await store.dequeue()
            #expect(jobs.isEmpty)
        }

        @Test("Complete job")
        func completeJob() async throws {
            let store = try await makeStore()
            let id = try await store.enqueue(payload: "test")
            _ = try await store.dequeue(limit: 1)
            try await store.complete(id)
            let job = try await store.getJob(id)
            #expect(job?.status == .completed)
        }

        @Test("Fail job retries until dead letter")
        func failAndDeadLetter() async throws {
            let store = try await makeStore()
            let id = try await store.enqueue(payload: "test", maxAttempts: 1)
            _ = try await store.dequeue(limit: 1)
            try await store.fail(id, error: "boom")
            let job = try await store.getJob(id)
            #expect(job?.status == .deadLetter)
            #expect(job?.lastError == "boom")
        }

        @Test("Fail job reschedules when attempts remain")
        func failReschedule() async throws {
            let store = try await makeStore()
            let id = try await store.enqueue(payload: "test", maxAttempts: 3)
            _ = try await store.dequeue(limit: 1)
            try await store.fail(id, error: "transient")
            let job = try await store.getJob(id)
            #expect(job?.status == .pending)
            #expect(job?.scheduledAt != nil)
        }

        @Test("Retry resets job to pending")
        func retryJob() async throws {
            let store = try await makeStore()
            let id = try await store.enqueue(payload: "test", maxAttempts: 1)
            _ = try await store.dequeue(limit: 1)
            try await store.fail(id, error: "err")
            try await store.retry(id)
            let job = try await store.getJob(id)
            #expect(job?.status == .pending)
            #expect(job?.scheduledAt == nil)
        }

        @Test("Priority ordering in dequeue")
        func priorityOrdering() async throws {
            let store = try await makeStore()
            _ = try await store.enqueue(payload: "low", priority: .low)
            let highId = try await store.enqueue(payload: "high", priority: .high)
            let jobs = try await store.dequeue(limit: 1)
            #expect(jobs[0].id == highId)
        }

        @Test("Dead letter jobs retrieval")
        func deadLetterJobs() async throws {
            let store = try await makeStore()
            let id = try await store.enqueue(payload: "doomed", maxAttempts: 1)
            _ = try await store.dequeue(limit: 1)
            try await store.fail(id, error: "fatal")
            let deadJobs = try await store.deadLetterJobs()
            #expect(deadJobs.count == 1)
            #expect(deadJobs[0].id == id)
        }

        @Test("Stats returns job counts by status")
        func stats() async throws {
            let store = try await makeStore()
            _ = try await store.enqueue(payload: "a")
            _ = try await store.enqueue(payload: "b")
            let id = try await store.enqueue(payload: "c")
            _ = try await store.dequeue(limit: 1)
            try await store.complete(id)

            let stats = try await store.stats()
            #expect(stats["pending"] != nil || stats["completed"] != nil || stats["processing"] != nil)
        }

        @Test("Pending count")
        func pendingCount() async throws {
            let store = try await makeStore()
            _ = try await store.enqueue(payload: "1")
            _ = try await store.enqueue(payload: "2")
            #expect(try await store.pendingCount() == 2)
        }

        @Test("GetJob returns nil for nonexistent")
        func getJobNonexistent() async throws {
            let store = try await makeStore()
            let job = try await store.getJob("nonexistent")
            #expect(job == nil)
        }

        @Test("Custom queue name")
        func customQueue() async throws {
            let store = try await makeStore()
            _ = try await store.enqueue(queue: "emails", payload: "send")
            _ = try await store.enqueue(queue: "reports", payload: "gen")
            let emailJobs = try await store.dequeue(queue: "emails")
            #expect(emailJobs.count == 1)
            #expect(emailJobs[0].queue == "emails")
        }
    }

#endif
