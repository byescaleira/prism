import Foundation
import Testing

@testable import PrismServer

@Suite("PrismClusterConfig Tests")
struct PrismClusterConfigTests {

    @Test("Default values")
    func defaults() {
        let config = PrismClusterConfig()
        #expect(config.workerCount == ProcessInfo.processInfo.activeProcessorCount)
        #expect(config.restartOnCrash == true)
        #expect(config.shutdownTimeout == .seconds(30))
    }

    @Test("Custom values")
    func customValues() {
        let config = PrismClusterConfig(workerCount: 4, restartOnCrash: false, shutdownTimeout: .seconds(10))
        #expect(config.workerCount == 4)
        #expect(config.restartOnCrash == false)
        #expect(config.shutdownTimeout == .seconds(10))
    }
}

@Suite("PrismCluster Tests")
struct PrismClusterStaticTests {

    @Test("isWorker returns false in test environment")
    func isWorker() {
        #expect(PrismCluster.isWorker == false)
    }

    @Test("isPrimary returns true in test environment")
    func isPrimary() {
        #expect(PrismCluster.isPrimary == true)
    }

    @Test("workerID returns nil in test environment")
    func workerID() {
        #expect(PrismCluster.workerID == nil)
    }

    @Test("PrismClusterMode current is primary in test")
    func clusterMode() {
        #expect(PrismClusterMode.current == .primary)
    }
}

@Suite("PrismWorkerStatus Tests")
struct PrismWorkerStatusTests {

    @Test("Status cases exist")
    func cases() {
        let running = PrismWorkerStatus.running
        let stopped = PrismWorkerStatus.stopped
        let crashed = PrismWorkerStatus.crashed
        #expect(running.rawValue == "running")
        #expect(stopped.rawValue == "stopped")
        #expect(crashed.rawValue == "crashed")
    }
}

@Suite("PrismWorkerInfo Tests")
struct PrismWorkerInfoTests {

    @Test("Stores properties")
    func properties() {
        let info = PrismWorkerInfo(pid: 1234, workerID: 0)
        #expect(info.pid == 1234)
        #expect(info.workerID == 0)
        #expect(info.status == .running)
    }
}

@Suite("PrismClusterManager Tests")
struct PrismClusterManagerTests {

    @Test("Active worker count starts at 0")
    func initialActiveCount() async {
        let manager = PrismClusterManager()
        #expect(await manager.activeWorkerCount == 0)
    }

    @Test("Workers starts empty")
    func initialWorkers() async {
        let manager = PrismClusterManager()
        #expect(await manager.workers.isEmpty)
    }

    @Test("Custom config")
    func customConfig() async {
        let config = PrismClusterConfig(workerCount: 2, restartOnCrash: false)
        let manager = PrismClusterManager(config: config)
        #expect(await manager.activeWorkerCount == 0)
    }
}
