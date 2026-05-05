import SwiftUI

/// A point-in-time snapshot of the process memory usage.
public struct PrismMemorySnapshot: Sendable {
    /// When the snapshot was taken.
    public let timestamp: Date

    /// Resident memory in bytes at snapshot time.
    public let usedBytes: UInt64

    /// Peak resident memory in bytes (lifetime high-water mark).
    public let peakBytes: UInt64

    /// Creates a memory snapshot.
    public init(timestamp: Date, usedBytes: UInt64, peakBytes: UInt64) {
        self.timestamp = timestamp
        self.usedBytes = usedBytes
        self.peakBytes = peakBytes
    }
}

/// Tracks process memory usage over time using mach_task_basic_info.
@Observable @MainActor
public final class PrismMemoryTrackerV2 {
    /// All recorded snapshots in chronological order.
    public private(set) var snapshots: [PrismMemorySnapshot] = []

    /// The most recent snapshot's used bytes, or zero if none recorded.
    public var currentUsage: UInt64 {
        snapshots.last?.usedBytes ?? 0
    }

    /// Creates a new memory tracker.
    public init() {}

    /// Takes a snapshot of current memory usage and appends it to the history.
    @discardableResult
    public func takeSnapshot() -> PrismMemorySnapshot {
        let snapshot = Self.readMemory()
        snapshots.append(snapshot)
        return snapshot
    }

    /// Clears all recorded snapshots.
    public func reset() {
        snapshots.removeAll()
    }

    /// Reads the current process memory via mach_task_basic_info.
    private static func readMemory() -> PrismMemorySnapshot {
        #if canImport(Darwin)
            var info = mach_task_basic_info()
            var count =
                mach_msg_type_number_t(
                    MemoryLayout<mach_task_basic_info>.size
                ) / 4
            let result = withUnsafeMutablePointer(to: &info) { infoPtr in
                infoPtr.withMemoryRebound(
                    to: integer_t.self, capacity: Int(count)
                ) { ptr in
                    task_info(
                        mach_task_self_,
                        task_flavor_t(MACH_TASK_BASIC_INFO),
                        ptr,
                        &count
                    )
                }
            }
            if result == KERN_SUCCESS {
                return PrismMemorySnapshot(
                    timestamp: Date(),
                    usedBytes: UInt64(info.resident_size),
                    peakBytes: UInt64(info.resident_size_max)
                )
            }
        #endif
        return PrismMemorySnapshot(timestamp: Date(), usedBytes: 0, peakBytes: 0)
    }
}

/// View modifier that takes a memory snapshot on each body evaluation.
private struct PrismTrackMemoryModifier: ViewModifier {
    let tracker: PrismMemoryTrackerV2

    func body(content: Content) -> some View {
        let _ = tracker.takeSnapshot()
        content
    }
}

extension View {
    /// Takes a memory snapshot on each body evaluation.
    /// - Parameter tracker: The memory tracker collecting snapshots.
    public func prismTrackMemory(tracker: PrismMemoryTrackerV2) -> some View {
        modifier(PrismTrackMemoryModifier(tracker: tracker))
    }
}
