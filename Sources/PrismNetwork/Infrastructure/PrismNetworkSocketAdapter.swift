//
//  PrismNetworkSocketAdapter.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import Network
import PrismFoundation

protocol PrismNetworkSocketConnection: AnyObject, Sendable {
    var stateUpdateHandler: (@Sendable (PrismNetworkSocketConnectionState) -> Void)? { get set }

    func start(queue: DispatchQueue)
    func cancel()
    func receive(
        minimumIncompleteLength: Int,
        maximumLength: Int,
        completion: @escaping @Sendable (Data?, Bool, Error?) -> Void
    )
    func send(
        content: Data?,
        completion: @escaping @Sendable (Error?) -> Void
    )
}

enum PrismNetworkSocketConnectionState: Sendable {
    case ready
    case cancelled
    case failed(String)
    case other(String)
}

/// Thread-safe: wraps `NWConnection` which serializes operations on its internal queue.
final class PrismNetworkNWConnection: @unchecked Sendable, PrismNetworkSocketConnection {
    private let connection: NWConnection

    var stateUpdateHandler: (@Sendable (PrismNetworkSocketConnectionState) -> Void)? {
        didSet {
            connection.stateUpdateHandler = { [weak self] state in
                self?.stateUpdateHandler?(Self.map(state))
            }
        }
    }

    init(
        host: NWEndpoint.Host,
        port: NWEndpoint.Port,
        parameters: NWParameters
    ) {
        self.connection = NWConnection(
            host: host,
            port: port,
            using: parameters
        )
    }

    func start(queue: DispatchQueue) {
        connection.start(queue: queue)
    }

    func cancel() {
        connection.cancel()
    }

    func receive(
        minimumIncompleteLength: Int,
        maximumLength: Int,
        completion: @escaping @Sendable (Data?, Bool, Error?) -> Void
    ) {
        connection.receive(
            minimumIncompleteLength: minimumIncompleteLength,
            maximumLength: maximumLength
        ) { content, _, isComplete, error in
            completion(
                content,
                isComplete,
                error
            )
        }
    }

    func send(
        content: Data?,
        completion: @escaping @Sendable (Error?) -> Void
    ) {
        connection.send(
            content: content,
            completion: .contentProcessed { error in
                completion(error)
            }
        )
    }

    private static func map(
        _ state: NWConnection.State
    ) -> PrismNetworkSocketConnectionState {
        switch state {
        case .ready:
            .ready
        case .waiting(let error):
            .failed(error.localizedDescription)
        case .cancelled:
            .cancelled
        case .failed(let error):
            .failed(error.localizedDescription)
        default:
            .other(String(describing: state))
        }
    }
}

/// A thread-safe WebSocket adapter with command and stream support.
public actor PrismNetworkSocketAdapter: PrismNetworkSocketClient {
    private let connectionFactory:
        @Sendable (
            NWEndpoint.Host,
            NWEndpoint.Port,
            NWParameters
        ) -> any PrismNetworkSocketConnection
    private let queueFactory: @Sendable () -> DispatchQueue

    private var connection: (any PrismNetworkSocketConnection)?
    private var receiveBuffer = Data()

    /// Creates a new WebSocket adapter using the default `NWConnection` transport.
    public init() {
        self.init(
            connectionFactory: { host, port, parameters in
                PrismNetworkNWConnection(
                    host: host,
                    port: port,
                    parameters: parameters
                )
            },
            queueFactory: {
                DispatchQueue(
                    label: UUID().uuidString,
                    qos: .userInitiated
                )
            }
        )
    }

    init(
        connectionFactory:
            @escaping @Sendable (
                NWEndpoint.Host,
                NWEndpoint.Port,
                NWParameters
            ) -> any PrismNetworkSocketConnection,
        queueFactory: @escaping @Sendable () -> DispatchQueue
    ) {
        self.connectionFactory = connectionFactory
        self.queueFactory = queueFactory
    }

    /// Opens a WebSocket connection and returns an async stream of newline-delimited data frames.
    ///
    /// - Parameter endpoint: The WebSocket endpoint to connect to.
    /// - Returns: An `AsyncStream` that yields complete data frames as they arrive.
    /// - Throws: ``PrismNetworkError`` if the connection cannot be established.
    public func connect(
        to endpoint: any PrismNetworkSocketEndpoint
    ) async throws -> AsyncStream<Data> {
        let logger = PrismNetworkLogger()
        endpoint.log()

        let port = try endpoint.port.rawValue
        let portDescription = String(port)
        logger.info(
            .connecting(
                endpoint.host.debugDescription,
                portDescription,
                endpoint.parameters.debugDescription
            )
        )

        receiveBuffer.removeAll(keepingCapacity: true)
        let connection = connectionFactory(
            endpoint.host,
            try endpoint.port,
            endpoint.parameters
        )
        self.connection = connection

        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.disconnect()
                    logger.info(
                        .disconnected(
                            endpoint.host.debugDescription,
                            portDescription
                        ))
                }
            }

            connection.stateUpdateHandler = { [weak self] state in
                guard let self else { return }
                Task {
                    await self.handle(
                        state: state,
                        endpoint: endpoint,
                        portDescription: portDescription,
                        continuation: continuation,
                        logger: logger
                    )
                }
            }

            connection.start(queue: queueFactory())
        }
    }

    private func handle(
        state: PrismNetworkSocketConnectionState,
        endpoint: any PrismNetworkSocketEndpoint,
        portDescription: String,
        continuation: AsyncStream<Data>.Continuation,
        logger: PrismNetworkLogger
    ) async {
        switch state {
        case .ready:
            logger.info(
                .connectionEstablished(
                    endpoint.host.debugDescription,
                    portDescription
                ))
            receive(
                on: continuation,
                logger: logger
            )
        case .cancelled:
            logger.info(
                .connectionClosed(
                    endpoint.host.debugDescription,
                    portDescription
                ))
            continuation.finish()
            connection = nil
        case .failed(let error):
            logger.error(.connectionFailed(error))
            continuation.finish()
            connection = nil
        case .other(let description):
            logger.info(.connectionStateChanged(description))
        }
    }

    private func receive(
        on continuation: AsyncStream<Data>.Continuation,
        logger: PrismNetworkLogger
    ) {
        connection?.receive(
            minimumIncompleteLength: 1,
            maximumLength: 10 * 1024 * 1024
        ) { [weak self] content, isComplete, error in
            guard let self else { return }
            Task {
                await self.processReceive(
                    content: content,
                    isComplete: isComplete,
                    error: error,
                    continuation: continuation,
                    logger: logger
                )
            }
        }
    }

    private func processReceive(
        content: Data?,
        isComplete: Bool,
        error: Error?,
        continuation: AsyncStream<Data>.Continuation,
        logger: PrismNetworkLogger
    ) async {
        if let error {
            logger.error(.receiveError(error.localizedDescription))
            continuation.finish()
            disconnect()
            return
        }

        if let content, !content.isEmpty {
            receiveBuffer.append(content)
            emitFrames(on: continuation)
        }

        if isComplete {
            if !receiveBuffer.isEmpty {
                logger.warning(
                    "⚠️ Discarding incomplete trailing buffer with \(receiveBuffer.count) bytes"
                )
                receiveBuffer.removeAll(keepingCapacity: true)
            }
            logger.info(.receptionComplete)
            continuation.finish()
            disconnect()
            return
        }

        receive(
            on: continuation,
            logger: logger
        )
    }

    private func emitFrames(on continuation: AsyncStream<Data>.Continuation) {
        let newline = UInt8(ascii: "\n")
        let carriageReturn = UInt8(ascii: "\r")

        while let index = receiveBuffer.firstIndex(of: newline) {
            let rawFrame = receiveBuffer[..<index]

            let frame: Data
            if rawFrame.last == carriageReturn {
                frame = Data(rawFrame.dropLast())
            } else {
                frame = Data(rawFrame)
            }

            if !frame.isEmpty {
                continuation.yield(frame)
            }

            let nextIndex = receiveBuffer.index(after: index)
            receiveBuffer.removeSubrange(..<nextIndex)
        }
    }

    /// Sends a command message over the active WebSocket connection.
    ///
    /// A trailing newline is appended automatically if not already present.
    ///
    /// - Parameter command: The command whose message will be sent.
    /// - Throws: ``PrismNetworkError/noConnectivity`` if no connection is active.
    public func send(command: PrismNetworkSocketCommand) async throws {
        let logger = PrismNetworkLogger()
        guard let connection else {
            throw PrismNetworkError.noConnectivity
        }

        let message = normalizedMessage(from: command.message)
        let content = Data(message.utf8)

        logger.info(.sendingMessage(command.message))

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(
                content: content,
                completion: { error in
                    guard let error else {
                        logger.info(.messageSent(command.message))
                        continuation.resume(returning: ())
                        return
                    }

                    logger.error(.sendError(error.localizedDescription))
                    continuation.resume(throwing: error)
                }
            )
        }
    }

    private func disconnect() {
        connection?.cancel()
        connection = nil
        receiveBuffer.removeAll(keepingCapacity: true)
    }

    private func normalizedMessage(
        from message: String
    ) -> String {
        message.hasSuffix(.breakLine)
            ? message
            : message.breakLine
    }
}
