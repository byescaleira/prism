import Foundation

/// Status of a health check component.
public enum PrismHealthStatus: String, Sendable, Codable {
    case healthy
    case degraded
    case unhealthy
}

/// Result of a single health check.
public struct PrismHealthCheckResult: Sendable {
    public let name: String
    public let status: PrismHealthStatus
    public let message: String?
    public let duration: Duration?

    public init(name: String, status: PrismHealthStatus, message: String? = nil, duration: Duration? = nil) {
        self.name = name
        self.status = status
        self.message = message
        self.duration = duration
    }
}

/// A named health check that verifies a system component.
public struct PrismHealthCheck: Sendable {
    public let name: String
    private let check: @Sendable () async -> PrismHealthCheckResult

    public init(name: String, check: @escaping @Sendable () async -> PrismHealthCheckResult) {
        self.name = name
        self.check = check
    }

    public func run() async -> PrismHealthCheckResult {
        await check()
    }
}

/// Collects and runs health checks, serves /health endpoint.
public actor PrismHealthMonitor {
    private var checks: [PrismHealthCheck] = []

    public init() {}

    /// Registers a health check.
    public func register(_ check: PrismHealthCheck) {
        checks.append(check)
    }

    /// Registers a simple check with a closure returning status.
    public func register(_ name: String, check: @escaping @Sendable () async -> PrismHealthStatus) {
        checks.append(PrismHealthCheck(name: name) {
            let status = await check()
            return PrismHealthCheckResult(name: name, status: status)
        })
    }

    /// Runs all health checks and returns aggregate result.
    public func checkHealth() async -> PrismHealthReport {
        let clock = ContinuousClock()
        var results: [PrismHealthCheckResult] = []

        for check in checks {
            let start = clock.now
            let result = await check.run()
            let elapsed = clock.now - start
            results.append(PrismHealthCheckResult(
                name: result.name,
                status: result.status,
                message: result.message,
                duration: elapsed
            ))
        }

        let overall: PrismHealthStatus
        if results.contains(where: { $0.status == .unhealthy }) {
            overall = .unhealthy
        } else if results.contains(where: { $0.status == .degraded }) {
            overall = .degraded
        } else {
            overall = .healthy
        }

        return PrismHealthReport(status: overall, checks: results)
    }
}

/// Aggregate health report.
public struct PrismHealthReport: Sendable {
    public let status: PrismHealthStatus
    public let checks: [PrismHealthCheckResult]

    public func toJSONData() -> Data {
        var dict: [String: Any] = ["status": status.rawValue]
        dict["checks"] = checks.map { check -> [String: Any] in
            var c: [String: Any] = ["name": check.name, "status": check.status.rawValue]
            if let msg = check.message { c["message"] = msg }
            return c
        }
        return (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
    }
}

/// Middleware that exposes /health endpoint.
public struct PrismHealthMiddleware: PrismMiddleware, Sendable {
    private let monitor: PrismHealthMonitor
    private let path: String

    public init(monitor: PrismHealthMonitor, path: String = "/health") {
        self.monitor = monitor
        self.path = path
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        guard request.path == path && request.method == .GET else {
            return try await next(request)
        }

        let report = await monitor.checkHealth()
        let status: PrismHTTPStatus = report.status == .healthy ? .ok : .serviceUnavailable
        let data = report.toJSONData()
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/json; charset=utf-8")
        headers.set(name: "Content-Length", value: "\(data.count)")
        return PrismHTTPResponse(status: status, headers: headers, body: .data(data))
    }
}

/// Actor-based metrics collector for request statistics.
public actor PrismMetrics {
    private var requestCount: Int = 0
    private var errorCount: Int = 0
    private var statusCounts: [Int: Int] = [:]
    private var pathCounts: [String: Int] = [:]
    private var totalLatencyNanos: UInt64 = 0
    private var activeRequests: Int = 0

    public init() {}

    /// Records a completed request.
    public func recordRequest(path: String, statusCode: Int, duration: Duration) {
        requestCount += 1
        statusCounts[statusCode, default: 0] += 1
        pathCounts[path, default: 0] += 1
        let nanos = UInt64(duration.components.seconds) * 1_000_000_000 + UInt64(duration.components.attoseconds / 1_000_000_000)
        totalLatencyNanos += nanos

        if statusCode >= 400 {
            errorCount += 1
        }
    }

    /// Increments active request count.
    public func requestStarted() { activeRequests += 1 }

    /// Decrements active request count.
    public func requestEnded() { activeRequests -= 1 }

    /// Returns current metrics snapshot.
    public func snapshot() -> PrismMetricsSnapshot {
        let avgLatency = requestCount > 0 ? totalLatencyNanos / UInt64(requestCount) : 0
        let top = pathCounts.sorted { $0.value > $1.value }.prefix(20)
        var topDict: [String: Int] = [:]
        for entry in top { topDict[entry.key] = entry.value }
        return PrismMetricsSnapshot(
            requestCount: requestCount,
            errorCount: errorCount,
            activeRequests: activeRequests,
            averageLatencyNanos: avgLatency,
            statusCounts: statusCounts,
            topPaths: topDict
        )
    }

    /// Resets all metrics.
    public func reset() {
        requestCount = 0
        errorCount = 0
        statusCounts = [:]
        pathCounts = [:]
        totalLatencyNanos = 0
        activeRequests = 0
    }
}

/// Immutable snapshot of server metrics.
public struct PrismMetricsSnapshot: Sendable {
    public let requestCount: Int
    public let errorCount: Int
    public let activeRequests: Int
    public let averageLatencyNanos: UInt64
    public let statusCounts: [Int: Int]
    public let topPaths: [String: Int]

    public func toJSONData() -> Data {
        var dict: [String: Any] = [
            "requestCount": requestCount,
            "errorCount": errorCount,
            "activeRequests": activeRequests,
            "averageLatencyMs": Double(averageLatencyNanos) / 1_000_000
        ]
        dict["statusCounts"] = statusCounts.reduce(into: [String: Int]()) { $0["\($1.key)"] = $1.value }
        dict["topPaths"] = topPaths
        return (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
    }
}

/// Middleware that collects request metrics.
public struct PrismMetricsMiddleware: PrismMiddleware, Sendable {
    private let metrics: PrismMetrics
    private let metricsPath: String

    public init(metrics: PrismMetrics, path: String = "/metrics") {
        self.metrics = metrics
        self.metricsPath = path
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        if request.path == metricsPath && request.method == .GET {
            let snapshot = await metrics.snapshot()
            let data = snapshot.toJSONData()
            var headers = PrismHTTPHeaders()
            headers.set(name: "Content-Type", value: "application/json; charset=utf-8")
            headers.set(name: "Content-Length", value: "\(data.count)")
            return PrismHTTPResponse(status: .ok, headers: headers, body: .data(data))
        }

        await metrics.requestStarted()
        let clock = ContinuousClock()
        let start = clock.now

        let response = try await next(request)

        let duration = clock.now - start
        await metrics.recordRequest(path: request.path, statusCode: response.status.code, duration: duration)
        await metrics.requestEnded()

        return response
    }
}
