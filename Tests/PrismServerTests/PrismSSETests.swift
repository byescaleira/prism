import Foundation
import Testing

@testable import PrismServer

@Suite("PrismSSEvent Tests")
struct PrismSSEventTests {

    @Test("Serialize with just data")
    func serializeDataOnly() {
        let event = PrismSSEvent(data: "hello")
        let result = event.serialize()
        #expect(result == "data: hello\n\n")
    }

    @Test("Serialize with id, event, and data")
    func serializeWithIdAndEvent() {
        let event = PrismSSEvent(data: "payload", id: "123", event: "message")
        let result = event.serialize()
        #expect(result.contains("id: 123\n"))
        #expect(result.contains("event: message\n"))
        #expect(result.contains("data: payload\n"))
        #expect(result.hasSuffix("\n\n"))
    }

    @Test("Serialize with retry")
    func serializeWithRetry() {
        let event = PrismSSEvent(data: "data", retry: 5000)
        let result = event.serialize()
        #expect(result.contains("retry: 5000\n"))
        #expect(result.contains("data: data\n"))
    }

    @Test("Multi-line data splits into multiple data fields")
    func multiLineData() {
        let event = PrismSSEvent(data: "line1\nline2\nline3")
        let result = event.serialize()
        #expect(result.contains("data: line1\n"))
        #expect(result.contains("data: line2\n"))
        #expect(result.contains("data: line3\n"))
    }
}

@Suite("PrismSSEConnection Tests")
struct PrismSSEConnectionTests {

    @Test("Connection has ID")
    func connectionID() async {
        let conn = PrismSSEConnection(id: "test-conn")
        #expect(await conn.id == "test-conn")
    }

    @Test("Connection starts connected")
    func startsConnected() async {
        let conn = PrismSSEConnection()
        #expect(await conn.isConnected == true)
    }

    @Test("Close sets disconnected")
    func closeDisconnects() async {
        let conn = PrismSSEConnection()
        await conn.close()
        #expect(await conn.isConnected == false)
    }
}

@Suite("PrismSSEManager Tests")
struct PrismSSEManagerTests {

    @Test("addConnection increases count")
    func addConnection() async {
        let manager = PrismSSEManager()
        _ = await manager.addConnection()
        #expect(await manager.connectionCount == 1)
    }

    @Test("Multiple addConnection increases count")
    func multipleAdd() async {
        let manager = PrismSSEManager()
        _ = await manager.addConnection()
        _ = await manager.addConnection()
        _ = await manager.addConnection()
        #expect(await manager.connectionCount == 3)
    }

    @Test("removeConnection decreases count")
    func removeConnection() async {
        let manager = PrismSSEManager()
        let conn = await manager.addConnection()
        let connId = await conn.id
        await manager.removeConnection(id: connId)
        #expect(await manager.connectionCount == 0)
    }

    @Test("Broadcast doesn't crash with no connections")
    func broadcastEmpty() async {
        let manager = PrismSSEManager()
        await manager.broadcast(PrismSSEvent(data: "test"))
        #expect(await manager.connectionCount == 0)
    }

    @Test("Broadcast doesn't crash with connections")
    func broadcastWithConnections() async {
        let manager = PrismSSEManager()
        _ = await manager.addConnection()
        await manager.broadcast(PrismSSEvent(data: "hello"))
        #expect(await manager.connectionCount == 1)
    }
}

@Suite("PrismSSEMiddleware Tests")
struct PrismSSEMiddlewareTests {

    @Test("Passes through non-SSE requests")
    func passThrough() async throws {
        let manager = PrismSSEManager()
        let middleware = PrismSSEMiddleware(manager: manager, path: "/events")
        let request = PrismHTTPRequest(method: .GET, uri: "/api/users")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("Passes through POST to SSE path")
    func postPassThrough() async throws {
        let manager = PrismSSEManager()
        let middleware = PrismSSEMiddleware(manager: manager, path: "/events")
        let request = PrismHTTPRequest(method: .POST, uri: "/events")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }
}
