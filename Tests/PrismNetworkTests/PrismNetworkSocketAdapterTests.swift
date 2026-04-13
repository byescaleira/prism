import Foundation
import Network
import Testing

@testable import PrismNetwork

@Suite(.serialized)
@MainActor
struct PrismNetworkSocketAdapterTests {
    @Test
    func connectWithRequestRequiresAnEndpoint() async {
        let adapter = PrismNetworkSocketAdapter()

        do {
            _ = try await adapter.connect(
                with: NetworkFixtureSocketRequest(endpoint: nil)
            )
            #expect(Bool(false))
        } catch {
            #expect(error as? PrismNetworkError == .invalidURL)
        }
    }

    @Test
    func connectReceivesDelimitedFramesAndTrimsCarriageReturn() async throws {
        let mockConnection = MockSocketConnection()
        mockConnection.receiveScripts = [
            (Data("one\r\n".utf8), false, nil),
            (Data("two\n".utf8), true, nil),
        ]

        let adapter = PrismNetworkSocketAdapter(
            connectionFactory: { _, _, _ in
                mockConnection
            },
            queueFactory: {
                DispatchQueue(label: "socket-test")
            }
        )
        let stream = try await adapter.connect(
            with: NetworkFixtureSocketRequest(
                endpoint: NetworkFixtureSocketEndpoint()
            )
        )

        mockConnection.emit(.other("setup"))
        mockConnection.emit(.ready)

        let frames = await collect(from: stream)

        #expect(
            frames == [
                Data("one".utf8),
                Data("two".utf8),
            ])
        #expect(mockConnection.startCount == 1)
        #expect(mockConnection.cancelCount == 1)
    }

    @Test
    func sendAddsANewLineAndRethrowsSendFailures() async throws {
        let mockConnection = MockSocketConnection()
        let adapter = PrismNetworkSocketAdapter(
            connectionFactory: { _, _, _ in
                mockConnection
            },
            queueFactory: {
                DispatchQueue(label: "socket-send")
            }
        )
        let stream = try await adapter.connect(
            to: NetworkFixtureSocketEndpoint()
        )

        try await adapter.send(
            command: NetworkFixtureSocketCommand(message: "PING")
        )

        #expect(
            mockConnection.sentPayloads == [
                Data("PING\n".utf8)
            ])

        try await adapter.send(
            command: NetworkFixtureSocketCommand(message: "PONG\n")
        )

        #expect(
            mockConnection.sentPayloads == [
                Data("PING\n".utf8),
                Data("PONG\n".utf8),
            ])

        mockConnection.sendError = URLError(.cannotConnectToHost)

        do {
            try await adapter.send(
                command: NetworkFixtureSocketCommand(message: "FAIL")
            )
            #expect(Bool(false))
        } catch {
            let nsError = error as NSError
            #expect(nsError.domain == NSURLErrorDomain)
            #expect(nsError.code == URLError.cannotConnectToHost.rawValue)
        }

        _ = stream
    }

    @Test
    func socketAdapterReportsDisconnectedAndReceiveErrors() async throws {
        let receiveError = URLError(.networkConnectionLost)
        let mockConnection = MockSocketConnection()
        mockConnection.receiveScripts = [
            (nil, false, receiveError)
        ]

        let adapter = PrismNetworkSocketAdapter(
            connectionFactory: { _, _, _ in
                mockConnection
            },
            queueFactory: {
                DispatchQueue(label: "socket-error")
            }
        )
        let stream = try await adapter.connect(
            to: NetworkFixtureSocketEndpoint()
        )

        mockConnection.emit(.ready)

        let frames = await collect(from: stream)

        #expect(frames.isEmpty)
        #expect(mockConnection.cancelCount == 1)

        do {
            try await PrismNetworkSocketAdapter().send(
                command: NetworkFixtureSocketCommand(message: "PING")
            )
            #expect(Bool(false))
        } catch {
            #expect(error as? PrismNetworkError == .noConnectivity)
        }
    }

    @Test
    func socketAdapterDropsIncompleteTrailingBuffer() async throws {
        let mockConnection = MockSocketConnection()
        mockConnection.receiveScripts = [
            (Data("partial".utf8), true, nil)
        ]

        let adapter = PrismNetworkSocketAdapter(
            connectionFactory: { _, _, _ in
                mockConnection
            },
            queueFactory: {
                DispatchQueue(label: "socket-trailing")
            }
        )
        let stream = try await adapter.connect(
            to: NetworkFixtureSocketEndpoint()
        )

        mockConnection.emit(.ready)

        let frames = await collect(from: stream)

        #expect(frames.isEmpty)
        #expect(mockConnection.cancelCount == 1)
    }

    @Test
    func publicSocketAdapterCanTalkToALocalTCPServer() async throws {
        let listener = try NWListener(
            using: .tcp,
            on: .any
        )
        let listenerQueue = DispatchQueue(label: "socket-listener")
        let serverBox = SocketServerBox()

        listener.newConnectionHandler = { connection in
            connection.start(queue: listenerQueue)
            connection.receive(
                minimumIncompleteLength: 1,
                maximumLength: 1_024
            ) { content, _, _, _ in
                if let content {
                    Task {
                        await serverBox.append(content)
                    }
                }

                connection.send(
                    content: Data("PONG\n".utf8),
                    completion: .contentProcessed { _ in
                        connection.cancel()
                    }
                )
            }
        }
        listener.start(queue: listenerQueue)

        try? await Task.sleep(for: .milliseconds(50))
        let port = try #require(listener.port?.rawValue)
        let endpoint = NetworkFixtureSocketEndpoint(
            host: "127.0.0.1",
            portValue: port
        )
        let adapter = PrismNetworkSocketAdapter()
        let stream = try await adapter.connect(to: endpoint)

        try await adapter.send(
            command: NetworkFixtureSocketCommand(message: "PING")
        )
        let frames = await collect(from: stream)
        let receivedData = await serverBox.receivedData

        listener.cancel()

        #expect(receivedData == [Data("PING\n".utf8)])
        #expect(frames == [Data("PONG".utf8)])
    }

    @Test
    func publicSocketAdapterHandlesConnectionFailures() async throws {
        let listener = try NWListener(
            using: .tcp,
            on: .any
        )
        let listenerQueue = DispatchQueue(label: "socket-failure-listener")

        listener.start(queue: listenerQueue)
        try? await Task.sleep(for: .milliseconds(50))

        let port = try #require(listener.port?.rawValue)
        listener.cancel()
        try? await Task.sleep(for: .milliseconds(50))

        let adapter = PrismNetworkSocketAdapter()
        let endpoint = NetworkFixtureSocketEndpoint(
            host: "127.0.0.1",
            portValue: port
        )
        let stream = try await adapter.connect(to: endpoint)
        let frames = await collect(from: stream)

        #expect(frames.isEmpty)
    }
}
