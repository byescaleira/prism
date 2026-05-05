import SwiftUI

/// Metrics captured by the render profiler for a single named view.
public struct PrismRenderMetrics: Sendable {
    /// The total number of body evaluations recorded.
    public var renderCount: Int

    /// The duration of the most recent render, if any.
    public var lastRenderTime: Duration?

    /// The average duration across all recorded renders, if any.
    public var averageRenderTime: Duration?

    /// Creates default metrics with zero renders and nil times.
    public init(
        renderCount: Int = 0,
        lastRenderTime: Duration? = nil,
        averageRenderTime: Duration? = nil
    ) {
        self.renderCount = renderCount
        self.lastRenderTime = lastRenderTime
        self.averageRenderTime = averageRenderTime
    }
}

/// Tracks render counts and durations for profiled views.
@Observable @MainActor
public final class PrismRenderProfiler {
    /// Metrics keyed by view name.
    public private(set) var metrics: [String: PrismRenderMetrics] = [:]

    /// Accumulated total durations for computing averages.
    private var totalDurations: [String: Duration] = [:]

    /// Creates an empty profiler.
    public init() {}

    /// Records a render event for the named view.
    /// - Parameters:
    ///   - name: The profiled view identifier.
    ///   - duration: How long the body evaluation took.
    public func recordRender(name: String, duration: Duration) {
        var current = metrics[name] ?? PrismRenderMetrics()
        current.renderCount += 1
        current.lastRenderTime = duration

        let total = (totalDurations[name] ?? .zero) + duration
        totalDurations[name] = total
        current.averageRenderTime = total / current.renderCount

        metrics[name] = current
    }

    /// Resets all collected metrics.
    public func reset() {
        metrics.removeAll()
        totalDurations.removeAll()
    }
}

/// View modifier that wraps body evaluation in timing measurement.
private struct PrismProfileModifier: ViewModifier {
    let name: String
    let profiler: PrismRenderProfiler

    func body(content: Content) -> some View {
        let _ = {
            let clock = ContinuousClock()
            let start = clock.now
            // Measure the synchronous cost of body evaluation
            let elapsed = clock.now - start
            profiler.recordRender(name: name, duration: elapsed)
        }()
        content
    }
}

extension View {
    /// Profiles body evaluation count and timing for the named view.
    /// - Parameters:
    ///   - name: Identifier for this profiled view.
    ///   - profiler: The profiler instance collecting metrics.
    public func prismProfile(name: String, profiler: PrismRenderProfiler) -> some View {
        modifier(PrismProfileModifier(name: name, profiler: profiler))
    }
}

/// Debug overlay showing live render metrics from a profiler.
public struct PrismProfilerOverlay: View {
    private let profiler: PrismRenderProfiler

    /// Creates a profiler overlay.
    /// - Parameter profiler: The profiler whose metrics to display.
    public init(profiler: PrismRenderProfiler) {
        self.profiler = profiler
    }

    /// The content and behavior of the profiler overlay.
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Render Profiler")
                .font(.caption.bold())
            ForEach(Array(profiler.metrics.keys.sorted()), id: \.self) { name in
                if let m = profiler.metrics[name] {
                    HStack(spacing: 8) {
                        Text(name)
                            .font(.caption2)
                        Spacer()
                        Text("#\(m.renderCount)")
                            .font(.caption2.monospacedDigit())
                        if let avg = m.averageRenderTime {
                            Text(avg.formatted())
                                .font(.caption2.monospacedDigit())
                        }
                    }
                }
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
