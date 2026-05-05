import Foundation
import Testing

@testable import PrismServer

@Suite("PrismBackgroundTaskManager Tests")
struct PrismBackgroundTaskManagerTests {

    @Test("Run executes task")
    func runExecutesTask() async throws {
        let manager = PrismBackgroundTaskManager()
        let flag = FlagBox()

        await manager.run("test") {
            await flag.set()
        }

        try await Task.sleep(for: .milliseconds(50))
        #expect(await flag.value == true)
    }

    @Test("ActiveCount tracks running tasks")
    func activeCountTracks() async throws {
        let manager = PrismBackgroundTaskManager()

        await manager.run("slow") {
            try? await Task.sleep(for: .seconds(5))
        }

        try await Task.sleep(for: .milliseconds(10))
        #expect(await manager.activeCount >= 1)

        await manager.cancelAll()
    }

    @Test("CancelAll cancels tasks")
    func cancelAllCancels() async throws {
        let manager = PrismBackgroundTaskManager()

        await manager.run("a") {
            try? await Task.sleep(for: .seconds(10))
        }
        await manager.run("b") {
            try? await Task.sleep(for: .seconds(10))
        }

        await manager.cancelAll()
        #expect(await manager.activeCount == 0)
    }

    @Test("ActiveTasks returns metadata")
    func activeTasksMetadata() async throws {
        let manager = PrismBackgroundTaskManager()

        await manager.run("myTask") {
            try? await Task.sleep(for: .seconds(5))
        }

        try await Task.sleep(for: .milliseconds(10))
        let tasks = await manager.activeTasks
        #expect(tasks.contains { $0.name == "myTask" })

        await manager.cancelAll()
    }

    @Test("RunWithResult returns task handle")
    func runWithResult() async throws {
        let manager = PrismBackgroundTaskManager()

        let handle = await manager.runWithResult("compute") {
            return 42
        }

        let result = try await handle.value
        #expect(result == 42)
    }
}

@Suite("PrismTaskGroup Tests")
struct PrismTaskGroupTests {

    @Test("Add and awaitAll completes all tasks")
    func addAndAwaitAll() async {
        let group = PrismTaskGroup()
        let counter = CounterBox()

        await group.add("a") { await counter.increment() }
        await group.add("b") { await counter.increment() }
        await group.add("c") { await counter.increment() }

        await group.awaitAll()
        #expect(await counter.value == 3)
    }

    @Test("CancelAll cancels group tasks")
    func cancelAll() async throws {
        let group = PrismTaskGroup()
        let flag = FlagBox()

        await group.add("long") {
            try await Task.sleep(for: .seconds(10))
            await flag.set()
        }

        await group.cancelAll()
        try await Task.sleep(for: .milliseconds(50))
        #expect(await flag.value == false)
    }
}

private actor FlagBox {
    var value = false
    func set() { value = true }
}

private actor CounterBox {
    var value = 0
    func increment() { value += 1 }
}
