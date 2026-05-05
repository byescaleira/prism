import SwiftUI
import os

/// Measures and reports body evaluation counts and rendering time.
///
/// ```swift
/// MyView()
///     .prismBenchmark("MyView")
/// ```
public struct PrismPerformanceBenchmark: ViewModifier {
    private static let logger = Logger(
        subsystem: "com.prism.ui",
        category: "performance"
    )
    private static let signposter = OSSignposter(
        subsystem: "com.prism.ui",
        category: "performance"
    )

    private let label: String
    @State private var renderCount = 0

    /// Creates a benchmark modifier with the given label for log output.
    public init(_ label: String) {
        self.label = label
    }

    /// Wraps the content with performance measurement.
    public func body(content: Content) -> some View {
        #if DEBUG
        let _ = Self.signposter.emitEvent("body", "\(label)")
        let _ = {
            renderCount += 1
            if renderCount > 1 {
                Self.logger.debug("⚡ \(label) body #\(renderCount)")
            }
        }()
        content
        #else
        content
        #endif
    }
}

/// Tracks memory footprint for DEBUG profiling.
public enum PrismMemoryTracker: Sendable {
    #if DEBUG
    /// Logs the current resident memory footprint for the given label.
    public static func logFootprint(_ label: String) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if result == KERN_SUCCESS {
            let mb = Double(info.resident_size) / 1_048_576
            Logger(subsystem: "com.prism.ui", category: "memory")
                .debug("📊 \(label): \(String(format: "%.1f", mb)) MB")
        }
    }
    #endif
}

extension View {

    /// Logs body evaluation count in DEBUG builds.
    public func prismBenchmark(_ label: String) -> some View {
        modifier(PrismPerformanceBenchmark(label))
    }
}
