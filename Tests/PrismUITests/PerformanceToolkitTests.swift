import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Performance Toolkit")
struct PerformanceToolkitTests {

    // MARK: - Lazy View

    @Suite("PrismLazyView")
    struct LazyViewTests {

        @Test("PrismLazyView conforms to View")
        @MainActor func lazyViewIsView() {
            let view = PrismLazyView { Text("Loaded") }
            #expect(type(of: view) is any View.Type)
        }

        @Test("PrismLazyView with custom placeholder conforms to View")
        @MainActor func lazyViewWithPlaceholder() {
            let view = PrismLazyView(
                placeholder: { Text("Loading...") },
                content: { Text("Loaded") }
            )
            #expect(type(of: view) is any View.Type)
        }

        @Test("PrismLazyNavigationDestination conforms to View")
        @MainActor func lazyNavDestinationIsView() {
            let view = PrismLazyNavigationDestination { Text("Detail") }
            #expect(type(of: view) is any View.Type)
        }
    }

    // MARK: - Render Metrics

    @Suite("PrismRenderMetrics")
    struct RenderMetricsTests {

        @Test("default metrics have zero count and nil times")
        @MainActor func defaults() {
            let metrics = PrismRenderMetrics()
            #expect(metrics.renderCount == 0)
            #expect(metrics.lastRenderTime == nil)
            #expect(metrics.averageRenderTime == nil)
        }

        @Test("metrics can be initialized with custom values")
        @MainActor func customInit() {
            let metrics = PrismRenderMetrics(
                renderCount: 5,
                lastRenderTime: .milliseconds(10),
                averageRenderTime: .milliseconds(8)
            )
            #expect(metrics.renderCount == 5)
            #expect(metrics.lastRenderTime == .milliseconds(10))
            #expect(metrics.averageRenderTime == .milliseconds(8))
        }
    }

    // MARK: - Render Profiler

    @Suite("PrismRenderProfiler")
    struct RenderProfilerTests {

        @Test("profiler starts with empty metrics")
        @MainActor func emptyInitial() {
            let profiler = PrismRenderProfiler()
            #expect(profiler.metrics.isEmpty)
        }

        @Test("profiler tracks render count")
        @MainActor func tracksRenderCount() {
            let profiler = PrismRenderProfiler()
            profiler.recordRender(name: "TestView", duration: .milliseconds(1))
            profiler.recordRender(name: "TestView", duration: .milliseconds(2))
            #expect(profiler.metrics["TestView"]?.renderCount == 2)
        }

        @Test("profiler records last render time")
        @MainActor func recordsLastTime() {
            let profiler = PrismRenderProfiler()
            profiler.recordRender(name: "V", duration: .milliseconds(5))
            profiler.recordRender(name: "V", duration: .milliseconds(10))
            #expect(profiler.metrics["V"]?.lastRenderTime == .milliseconds(10))
        }

        @Test("profiler computes average render time")
        @MainActor func computesAverage() {
            let profiler = PrismRenderProfiler()
            profiler.recordRender(name: "A", duration: .milliseconds(4))
            profiler.recordRender(name: "A", duration: .milliseconds(6))
            #expect(profiler.metrics["A"]?.averageRenderTime == .milliseconds(5))
        }

        @Test("profiler reset clears all data")
        @MainActor func resetClears() {
            let profiler = PrismRenderProfiler()
            profiler.recordRender(name: "X", duration: .milliseconds(1))
            profiler.reset()
            #expect(profiler.metrics.isEmpty)
        }

        @Test("prismProfile modifier attaches to view")
        @MainActor func profileModifier() {
            let profiler = PrismRenderProfiler()
            let view = Text("Hello")
                .prismProfile(name: "Test", profiler: profiler)
            #expect(type(of: view) is any View.Type)
        }
    }

    // MARK: - Profiler Overlay

    @Suite("PrismProfilerOverlay")
    struct ProfilerOverlayTests {

        @Test("PrismProfilerOverlay conforms to View")
        @MainActor func overlayIsView() {
            let profiler = PrismRenderProfiler()
            let overlay = PrismProfilerOverlay(profiler: profiler)
            #expect(type(of: overlay) is any View.Type)
        }

        @Test("overlay renders with populated metrics")
        @MainActor func overlayWithMetrics() {
            let profiler = PrismRenderProfiler()
            profiler.recordRender(name: "Card", duration: .milliseconds(3))
            let overlay = PrismProfilerOverlay(profiler: profiler)
            #expect(type(of: overlay) is any View.Type)
        }
    }

    // MARK: - Memory Snapshot

    @Suite("PrismMemorySnapshot")
    struct MemorySnapshotTests {

        @Test("snapshot stores provided values")
        @MainActor func storesValues() {
            let date = Date()
            let snapshot = PrismMemorySnapshot(
                timestamp: date,
                usedBytes: 1024,
                peakBytes: 2048
            )
            #expect(snapshot.timestamp == date)
            #expect(snapshot.usedBytes == 1024)
            #expect(snapshot.peakBytes == 2048)
        }
    }

    // MARK: - Memory Tracker

    @Suite("PrismMemoryTrackerV2")
    struct MemoryTrackerTests {

        @Test("takeSnapshot returns non-zero bytes")
        @MainActor func snapshotNonZero() {
            let tracker = PrismMemoryTrackerV2()
            let snapshot = tracker.takeSnapshot()
            #expect(snapshot.usedBytes > 0)
        }

        @Test("snapshots array grows on each take")
        @MainActor func snapshotsGrow() {
            let tracker = PrismMemoryTrackerV2()
            tracker.takeSnapshot()
            tracker.takeSnapshot()
            #expect(tracker.snapshots.count == 2)
        }

        @Test("currentUsage reflects latest snapshot")
        @MainActor func currentUsage() {
            let tracker = PrismMemoryTrackerV2()
            #expect(tracker.currentUsage == 0)
            tracker.takeSnapshot()
            #expect(tracker.currentUsage > 0)
        }

        @Test("reset clears all snapshots")
        @MainActor func resetClears() {
            let tracker = PrismMemoryTrackerV2()
            tracker.takeSnapshot()
            tracker.reset()
            #expect(tracker.snapshots.isEmpty)
            #expect(tracker.currentUsage == 0)
        }

        @Test("prismTrackMemory modifier attaches to view")
        @MainActor func trackMemoryModifier() {
            let tracker = PrismMemoryTrackerV2()
            let view = Text("Hello")
                .prismTrackMemory(tracker: tracker)
            #expect(type(of: view) is any View.Type)
        }
    }

    // MARK: - Image Downsampler

    @Suite("PrismImageDownsampler")
    struct ImageDownsamplerTests {

        @Test("downsample with invalid data returns nil")
        @MainActor func invalidDataReturnsNil() {
            let result = PrismImageDownsampler.downsample(
                data: Data([0x00, 0x01, 0x02]),
                to: CGSize(width: 100, height: 100),
                scale: 2.0
            )
            #expect(result == nil)
        }

        @Test("downsample with empty data returns nil")
        @MainActor func emptyDataReturnsNil() {
            let result = PrismImageDownsampler.downsample(
                data: Data(),
                to: CGSize(width: 50, height: 50),
                scale: 1.0
            )
            #expect(result == nil)
        }

        @Test("downsample with nonexistent URL returns nil")
        @MainActor func nonexistentURLReturnsNil() {
            let url = URL(fileURLWithPath: "/nonexistent/image.png")
            let result = PrismImageDownsampler.downsample(
                imageAt: url,
                to: CGSize(width: 100, height: 100),
                scale: 2.0
            )
            #expect(result == nil)
        }

        @Test("PrismDownsampledImage conforms to View")
        @MainActor func downsampledImageIsView() {
            let view = PrismDownsampledImage(
                url: nil,
                pointSize: CGSize(width: 100, height: 100)
            )
            #expect(type(of: view) is any View.Type)
        }
    }

    // MARK: - Prefetch Coordinator

    @Suite("PrismPrefetchCoordinator")
    struct PrefetchCoordinatorTests {

        struct MockPrefetchable: PrismPrefetchable {
            let onPrefetch: @Sendable (String) -> Void
            let onCancel: @Sendable (String) -> Void

            func prefetch(id: String) async {
                onPrefetch(id)
            }

            func cancelPrefetch(id: String) {
                onCancel(id)
            }
        }

        @Test("coordinator starts empty")
        @MainActor func startsEmpty() {
            let coordinator = PrismPrefetchCoordinator()
            #expect(coordinator.prefetchables.isEmpty)
            #expect(coordinator.activeIDs.isEmpty)
        }

        @Test("register adds prefetchable")
        @MainActor func registerAdds() {
            let coordinator = PrismPrefetchCoordinator()
            let mock = MockPrefetchable(
                onPrefetch: { _ in },
                onCancel: { _ in }
            )
            coordinator.register(mock)
            #expect(coordinator.prefetchables.count == 1)
        }

        @Test("prefetch creates active tasks")
        @MainActor func prefetchCreates() {
            let coordinator = PrismPrefetchCoordinator()
            let mock = MockPrefetchable(
                onPrefetch: { _ in },
                onCancel: { _ in }
            )
            coordinator.register(mock)
            coordinator.prefetch(ids: ["a", "b"])
            #expect(coordinator.activeIDs.contains("a"))
            #expect(coordinator.activeIDs.contains("b"))
        }

        @Test("cancelPrefetch removes active tasks")
        @MainActor func cancelRemoves() {
            let coordinator = PrismPrefetchCoordinator()
            let mock = MockPrefetchable(
                onPrefetch: { _ in },
                onCancel: { _ in }
            )
            coordinator.register(mock)
            coordinator.prefetch(ids: ["x"])
            coordinator.cancelPrefetch(ids: ["x"])
            #expect(!coordinator.activeIDs.contains("x"))
        }

        @Test("reset clears everything")
        @MainActor func resetClears() {
            let coordinator = PrismPrefetchCoordinator()
            let mock = MockPrefetchable(
                onPrefetch: { _ in },
                onCancel: { _ in }
            )
            coordinator.register(mock)
            coordinator.prefetch(ids: ["1"])
            coordinator.reset()
            #expect(coordinator.prefetchables.isEmpty)
            #expect(coordinator.activeIDs.isEmpty)
        }

        @Test("prismPrefetch modifier attaches to view")
        @MainActor func prefetchModifier() {
            let coordinator = PrismPrefetchCoordinator()
            let view = Text("Item")
                .prismPrefetch(coordinator: coordinator, id: "item-1")
            #expect(type(of: view) is any View.Type)
        }
    }
}
