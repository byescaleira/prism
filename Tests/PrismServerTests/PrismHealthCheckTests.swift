import Foundation
import Testing

@testable import PrismServer

@Suite("PrismHealthMonitor Tests")
struct PrismHealthMonitorTests {

    @Test("No checks returns healthy")
    func noChecks() async {
        let monitor = PrismHealthMonitor()
        let report = await monitor.checkHealth()
        #expect(report.status == .healthy)
        #expect(report.checks.isEmpty)
    }

    @Test("Single healthy check")
    func singleHealthy() async {
        let monitor = PrismHealthMonitor()
        await monitor.register("db") { .healthy }
        let report = await monitor.checkHealth()
        #expect(report.status == .healthy)
        #expect(report.checks.count == 1)
        #expect(report.checks[0].name == "db")
    }

    @Test("Degraded if any check degraded")
    func degradedCheck() async {
        let monitor = PrismHealthMonitor()
        await monitor.register("db") { .healthy }
        await monitor.register("cache") { .degraded }
        let report = await monitor.checkHealth()
        #expect(report.status == .degraded)
    }

    @Test("Unhealthy if any check unhealthy")
    func unhealthyCheck() async {
        let monitor = PrismHealthMonitor()
        await monitor.register("db") { .unhealthy }
        await monitor.register("cache") { .healthy }
        let report = await monitor.checkHealth()
        #expect(report.status == .unhealthy)
    }

    @Test("Unhealthy takes precedence over degraded")
    func unhealthyPrecedence() async {
        let monitor = PrismHealthMonitor()
        await monitor.register("a") { .degraded }
        await monitor.register("b") { .unhealthy }
        let report = await monitor.checkHealth()
        #expect(report.status == .unhealthy)
    }

    @Test("Register full PrismHealthCheck")
    func registerFullCheck() async {
        let monitor = PrismHealthMonitor()
        let check = PrismHealthCheck(name: "custom") {
            PrismHealthCheckResult(name: "custom", status: .healthy, message: "all good")
        }
        await monitor.register(check)
        let report = await monitor.checkHealth()
        #expect(report.status == .healthy)
        #expect(report.checks[0].message == "all good")
    }

    @Test("Health report toJSONData")
    func reportToJSONData() async {
        let monitor = PrismHealthMonitor()
        await monitor.register("db") { .healthy }
        let report = await monitor.checkHealth()
        let data = report.toJSONData()
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["status"] as? String == "healthy")
        let checks = json?["checks"] as? [[String: Any]]
        #expect(checks?.count == 1)
        #expect(checks?[0]["name"] as? String == "db")
    }
}

@Suite("PrismHealthMiddleware Tests")
struct PrismHealthMiddlewareTests {

    @Test("Serves /health endpoint")
    func servesHealth() async throws {
        let monitor = PrismHealthMonitor()
        await monitor.register("db") { .healthy }
        let middleware = PrismHealthMiddleware(monitor: monitor)
        let request = PrismHTTPRequest(method: .GET, uri: "/health")
        let response = try await middleware.handle(request) { _ in .text("fallthrough") }
        #expect(response.status == .ok)
    }

    @Test("Returns 503 when unhealthy")
    func unhealthyStatus() async throws {
        let monitor = PrismHealthMonitor()
        await monitor.register("db") { .unhealthy }
        let middleware = PrismHealthMiddleware(monitor: monitor)
        let request = PrismHTTPRequest(method: .GET, uri: "/health")
        let response = try await middleware.handle(request) { _ in .text("fallthrough") }
        #expect(response.status == .serviceUnavailable)
    }

    @Test("Passes through non-health requests")
    func passThrough() async throws {
        let monitor = PrismHealthMonitor()
        let middleware = PrismHealthMiddleware(monitor: monitor)
        let request = PrismHTTPRequest(method: .GET, uri: "/api/users")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("Custom health path")
    func customPath() async throws {
        let monitor = PrismHealthMonitor()
        let middleware = PrismHealthMiddleware(monitor: monitor, path: "/status")
        let request = PrismHTTPRequest(method: .GET, uri: "/status")
        let response = try await middleware.handle(request) { _ in .text("fallthrough") }
        #expect(response.status == .ok)
    }

    @Test("Only responds to GET")
    func onlyGET() async throws {
        let monitor = PrismHealthMonitor()
        let middleware = PrismHealthMiddleware(monitor: monitor)
        let request = PrismHTTPRequest(method: .POST, uri: "/health")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }
}

@Suite("PrismMetrics Tests")
struct PrismMetricsTests {

    @Test("Initial snapshot is empty")
    func initialSnapshot() async {
        let metrics = PrismMetrics()
        let snap = await metrics.snapshot()
        #expect(snap.requestCount == 0)
        #expect(snap.errorCount == 0)
        #expect(snap.activeRequests == 0)
    }

    @Test("Records request counts")
    func recordRequests() async {
        let metrics = PrismMetrics()
        await metrics.recordRequest(path: "/api", statusCode: 200, duration: .milliseconds(10))
        await metrics.recordRequest(path: "/api", statusCode: 200, duration: .milliseconds(20))
        let snap = await metrics.snapshot()
        #expect(snap.requestCount == 2)
        #expect(snap.errorCount == 0)
    }

    @Test("Counts errors for 4xx and 5xx")
    func errorCounting() async {
        let metrics = PrismMetrics()
        await metrics.recordRequest(path: "/a", statusCode: 200, duration: .milliseconds(1))
        await metrics.recordRequest(path: "/b", statusCode: 404, duration: .milliseconds(1))
        await metrics.recordRequest(path: "/c", statusCode: 500, duration: .milliseconds(1))
        let snap = await metrics.snapshot()
        #expect(snap.requestCount == 3)
        #expect(snap.errorCount == 2)
    }

    @Test("Tracks status code distribution")
    func statusCodes() async {
        let metrics = PrismMetrics()
        await metrics.recordRequest(path: "/", statusCode: 200, duration: .milliseconds(1))
        await metrics.recordRequest(path: "/", statusCode: 200, duration: .milliseconds(1))
        await metrics.recordRequest(path: "/", statusCode: 404, duration: .milliseconds(1))
        let snap = await metrics.snapshot()
        #expect(snap.statusCounts[200] == 2)
        #expect(snap.statusCounts[404] == 1)
    }

    @Test("Tracks top paths")
    func topPaths() async {
        let metrics = PrismMetrics()
        await metrics.recordRequest(path: "/a", statusCode: 200, duration: .milliseconds(1))
        await metrics.recordRequest(path: "/b", statusCode: 200, duration: .milliseconds(1))
        await metrics.recordRequest(path: "/a", statusCode: 200, duration: .milliseconds(1))
        let snap = await metrics.snapshot()
        #expect(snap.topPaths["/a"] == 2)
        #expect(snap.topPaths["/b"] == 1)
    }

    @Test("Active requests tracking")
    func activeRequests() async {
        let metrics = PrismMetrics()
        await metrics.requestStarted()
        await metrics.requestStarted()
        #expect(await metrics.snapshot().activeRequests == 2)
        await metrics.requestEnded()
        #expect(await metrics.snapshot().activeRequests == 1)
    }

    @Test("Reset clears all metrics")
    func reset() async {
        let metrics = PrismMetrics()
        await metrics.recordRequest(path: "/", statusCode: 200, duration: .milliseconds(10))
        await metrics.requestStarted()
        await metrics.reset()
        let snap = await metrics.snapshot()
        #expect(snap.requestCount == 0)
        #expect(snap.activeRequests == 0)
    }

    @Test("Snapshot toJSONData")
    func snapshotToJSONData() async {
        let metrics = PrismMetrics()
        await metrics.recordRequest(path: "/", statusCode: 200, duration: .milliseconds(10))
        let snap = await metrics.snapshot()
        let data = snap.toJSONData()
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["requestCount"] as? Int == 1)
        #expect(json?["errorCount"] as? Int == 0)
    }
}

@Suite("PrismMetricsMiddleware Tests")
struct PrismMetricsMiddlewareTests {

    @Test("Serves /metrics endpoint")
    func servesMetrics() async throws {
        let metrics = PrismMetrics()
        let middleware = PrismMetricsMiddleware(metrics: metrics)
        let request = PrismHTTPRequest(method: .GET, uri: "/metrics")
        let response = try await middleware.handle(request) { _ in .text("fallthrough") }
        #expect(response.status == .ok)
    }

    @Test("Records request metrics for non-metrics paths")
    func recordsMetrics() async throws {
        let metrics = PrismMetrics()
        let middleware = PrismMetricsMiddleware(metrics: metrics)
        let request = PrismHTTPRequest(method: .GET, uri: "/api/users")
        _ = try await middleware.handle(request) { _ in .text("ok") }
        let snap = await metrics.snapshot()
        #expect(snap.requestCount == 1)
    }

    @Test("Custom metrics path")
    func customPath() async throws {
        let metrics = PrismMetrics()
        let middleware = PrismMetricsMiddleware(metrics: metrics, path: "/stats")
        let request = PrismHTTPRequest(method: .GET, uri: "/stats")
        let response = try await middleware.handle(request) { _ in .text("fallthrough") }
        #expect(response.status == .ok)
    }
}
