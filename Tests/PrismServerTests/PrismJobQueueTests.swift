import Testing
import Foundation
@testable import PrismServer

private actor Counter {
    var value = 0
    func increment() { value += 1 }
}

private struct IncrementJob: PrismJob {
    let counter: Counter
    func execute() async throws {
        await counter.increment()
    }
}

private struct FailingJob: PrismJob {
    let counter: Counter
    func execute() async throws {
        await counter.increment()
        throw PrismHTTPError.timeout
    }
}

@Suite("PrismJobQueue Tests")
struct PrismJobQueueTests {

    @Test("Enqueue and execute immediate job")
    func immediateJob() async throws {
        let counter = Counter()
        let queue = PrismJobQueue()
        _ = await queue.enqueue(IncrementJob(counter: counter))
        try await Task.sleep(for: .milliseconds(100))
        #expect(await counter.value == 1)
    }

    @Test("Delayed job executes after delay")
    func delayedJob() async throws {
        let counter = Counter()
        let queue = PrismJobQueue()
        _ = await queue.enqueue(IncrementJob(counter: counter), schedule: .delayed(0.2))
        try await Task.sleep(for: .milliseconds(100))
        #expect(await counter.value == 0)
        try await Task.sleep(for: .milliseconds(200))
        #expect(await counter.value == 1)
    }

    @Test("Repeated job runs multiple times")
    func repeatedJob() async throws {
        let counter = Counter()
        let queue = PrismJobQueue()
        let id = await queue.enqueue(IncrementJob(counter: counter), schedule: .every(0.1))
        try await Task.sleep(for: .milliseconds(350))
        await queue.cancel(id)
        let count = await counter.value
        #expect(count >= 2)
    }

    @Test("Cancel stops job")
    func cancelJob() async throws {
        let counter = Counter()
        let queue = PrismJobQueue()
        let id = await queue.enqueue(IncrementJob(counter: counter), schedule: .every(0.1))
        try await Task.sleep(for: .milliseconds(50))
        await queue.cancel(id)
        let countAtCancel = await counter.value
        try await Task.sleep(for: .milliseconds(200))
        let countAfter = await counter.value
        #expect(countAfter <= countAtCancel + 1)
    }

    @Test("Failing job retries with backoff")
    func retryJob() async throws {
        let counter = Counter()
        let queue = PrismJobQueue()
        _ = await queue.enqueue(
            FailingJob(counter: counter),
            schedule: PrismJobSchedule(maxRetries: 2, retryDelay: 0.05)
        )
        try await Task.sleep(for: .milliseconds(500))
        let count = await counter.value
        #expect(count == 3)
    }

    @Test("Active job count")
    func activeCount() async {
        let queue = PrismJobQueue()
        _ = await queue.enqueue(IncrementJob(counter: Counter()), schedule: .every(1))
        _ = await queue.enqueue(IncrementJob(counter: Counter()), schedule: .every(1))
        #expect(await queue.activeJobCount == 2)
        await queue.cancelAll()
    }

    @Test("CancelAll stops all jobs")
    func cancelAll() async {
        let queue = PrismJobQueue()
        _ = await queue.enqueue(IncrementJob(counter: Counter()), schedule: .every(1))
        _ = await queue.enqueue(IncrementJob(counter: Counter()), schedule: .every(1))
        await queue.cancelAll()
        #expect(await queue.activeJobCount == 0)
    }
}

@Suite("PrismScheduler Tests")
struct PrismSchedulerTests {

    @Test("Schedule every N seconds")
    func scheduleEvery() async throws {
        let counter = Counter()
        let scheduler = PrismScheduler()
        let id = await scheduler.every(0.1, job: IncrementJob(counter: counter))
        try await Task.sleep(for: .milliseconds(350))
        await scheduler.cancel(id)
        #expect(await counter.value >= 2)
    }

    @Test("Schedule after delay")
    func scheduleAfter() async throws {
        let counter = Counter()
        let scheduler = PrismScheduler()
        _ = await scheduler.after(0.1, job: IncrementJob(counter: counter))
        try await Task.sleep(for: .milliseconds(200))
        #expect(await counter.value == 1)
    }
}
