#if canImport(MetricKit)
import MetricKit

// MARK: - App Metrics

/// Aggregated performance metrics from a MetricKit payload.
public struct PrismAppMetrics: Sendable {
    /// Average app launch duration in seconds.
    public let launchDuration: Double?
    /// Cumulative hang duration in seconds.
    public let hangDuration: Double?
    /// Peak memory usage in megabytes.
    public let peakMemory: Double?
    /// Cumulative CPU time in seconds.
    public let cpuTime: Double?
    /// Total disk writes in megabytes.
    public let diskWrites: Double?

    /// Creates a new app metrics snapshot with the given performance data.
    public init(launchDuration: Double? = nil, hangDuration: Double? = nil, peakMemory: Double? = nil, cpuTime: Double? = nil, diskWrites: Double? = nil) {
        self.launchDuration = launchDuration
        self.hangDuration = hangDuration
        self.peakMemory = peakMemory
        self.cpuTime = cpuTime
        self.diskWrites = diskWrites
    }
}

// MARK: - Crash Diagnostic

/// Represents a single crash diagnostic report from MetricKit.
public struct PrismCrashDiagnostic: Sendable {
    /// Unique identifier for this diagnostic.
    public let id: UUID
    /// When the crash occurred.
    public let timestamp: Date
    /// The Mach exception type name.
    public let exceptionType: String?
    /// The POSIX signal name.
    public let signal: String?
    /// The termination reason string.
    public let terminationReason: String?
    /// JSON-encoded call stack tree.
    public let callStackTree: String?

    /// Creates a new crash diagnostic with the given timestamp and crash details.
    public init(id: UUID = UUID(), timestamp: Date, exceptionType: String? = nil, signal: String? = nil, terminationReason: String? = nil, callStackTree: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.exceptionType = exceptionType
        self.signal = signal
        self.terminationReason = terminationReason
        self.callStackTree = callStackTree
    }
}

// MARK: - MetricKit Client

/// Observable client that receives app metrics and crash diagnostics via MXMetricManager.
@MainActor @Observable
public final class PrismMetricKitClient: NSObject, MXMetricManagerSubscriber {
    /// The most recently received app performance metrics.
    public private(set) var latestMetrics: PrismAppMetrics?
    /// All crash diagnostics received since the client started.
    public private(set) var crashDiagnostics: [PrismCrashDiagnostic] = []

    /// Creates a new MetricKit client.
    public override init() {
        super.init()
    }

    /// Subscribes to MXMetricManager to begin receiving payloads.
    public func startReceiving() {
        MXMetricManager.shared.add(self)
    }

    /// Unsubscribes from MXMetricManager.
    public func stopReceiving() {
        MXMetricManager.shared.remove(self)
    }

    // MARK: - MXMetricManagerSubscriber

    nonisolated public func didReceive(_ payloads: [MXMetricPayload]) {
        let metrics = payloads.last.map { payload in
            PrismAppMetrics(
                launchDuration: payload.applicationLaunchMetrics?.histogrammedTimeToFirstDraw.bucketEnumerator.allObjects.isEmpty == false ? 1.0 : nil,
                hangDuration: nil,
                peakMemory: nil,
                cpuTime: nil,
                diskWrites: nil
            )
        }
        Task { @MainActor in
            self.latestMetrics = metrics
        }
    }

    nonisolated public func didReceive(_ payloads: [MXDiagnosticPayload]) {
        let diagnostics = payloads.flatMap { payload in
            (payload.crashDiagnostics ?? []).map { crash in
                PrismCrashDiagnostic(
                    timestamp: payload.timeStampEnd,
                    exceptionType: crash.exceptionType?.description,
                    signal: crash.signal?.description,
                    terminationReason: crash.terminationReason,
                    callStackTree: String(data: (try? crash.callStackTree.jsonRepresentation()) ?? Data(), encoding: .utf8)
                )
            }
        }
        Task { @MainActor in
            self.crashDiagnostics.append(contentsOf: diagnostics)
        }
    }
}
#endif
