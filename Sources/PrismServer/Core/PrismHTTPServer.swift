#if canImport(Network)
    import Foundation
    import Network
    import PrismFoundation

    /// A fully native HTTP/1.1 server built on Network.framework.
    public actor PrismHTTPServer {
        private let port: UInt16
        private let host: String
        private var listener: NWListener?
        private var connections: [String: NWConnection] = [:]
        private var isRunning = false
        private let parser = PrismHTTPParser()
        private let logger: PrismStructuredLogger

        private var routes: [PrismRoute] = []
        private var middlewares: [any PrismMiddleware] = []
        private var groups: [PrismRouteGroup] = []
        private var webSocketHandlers: [String: any PrismWebSocketHandler] = [:]

        #if canImport(Network)
            private let tlsConfig: PrismTLSConfiguration?
        #endif

        /// Creates an HTTP server bound to the given host and port.
        public init(
            host: String = "0.0.0.0",
            port: UInt16 = 8080,
            tlsConfig: PrismTLSConfiguration? = nil,
            logger: PrismStructuredLogger = PrismStructuredLogger(destinations: [PrismConsoleLogDestination()])
        ) {
            self.host = host
            self.port = port
            self.tlsConfig = tlsConfig
            self.logger = logger
        }

        // MARK: - Route Registration

        /// Registers a route with the given method and pattern.
        public func route(_ method: PrismHTTPMethod, _ pattern: String, handler: @escaping PrismRouteHandler) {
            routes.append(PrismRoute(method: method, pattern: pattern, handler: handler))
        }

        /// Registers a GET route.
        public func get(_ pattern: String, handler: @escaping PrismRouteHandler) {
            route(.GET, pattern, handler: handler)
        }

        /// Registers a POST route.
        public func post(_ pattern: String, handler: @escaping PrismRouteHandler) {
            route(.POST, pattern, handler: handler)
        }

        /// Registers a PUT route.
        public func put(_ pattern: String, handler: @escaping PrismRouteHandler) {
            route(.PUT, pattern, handler: handler)
        }

        /// Registers a PATCH route.
        public func patch(_ pattern: String, handler: @escaping PrismRouteHandler) {
            route(.PATCH, pattern, handler: handler)
        }

        /// Registers a DELETE route.
        public func delete(_ pattern: String, handler: @escaping PrismRouteHandler) {
            route(.DELETE, pattern, handler: handler)
        }

        // MARK: - Middleware

        /// Adds a middleware to the global middleware chain.
        public func use(_ middleware: any PrismMiddleware) {
            middlewares.append(middleware)
        }

        // MARK: - Route Groups

        /// Creates a route group with a shared prefix and optional middleware.
        public func group(
            _ prefix: String, middlewares: [any PrismMiddleware] = [], configure: (PrismRouteGroupBuilder) -> Void
        ) {
            let builder = PrismRouteGroupBuilder(prefix: prefix, middlewares: middlewares)
            configure(builder)
            groups.append(builder.build())
        }

        // MARK: - WebSocket

        /// Registers a WebSocket handler at the given path.
        public func webSocket(_ pattern: String, handler: any PrismWebSocketHandler) {
            webSocketHandlers[pattern] = handler
        }

        // MARK: - Server Lifecycle

        /// Starts the HTTP server, binding to the configured host and port.
        public func start() async throws {
            guard !isRunning else { throw PrismHTTPError.serverAlreadyRunning }

            let parameters: NWParameters
            if let tlsConfig {
                let tlsOptions = try tlsConfig.makeOptions()
                parameters = NWParameters(tls: tlsOptions, tcp: NWProtocolTCP.Options())
            } else {
                parameters = .tcp
            }

            let nwPort = NWEndpoint.Port(rawValue: port)!
            let newListener = try NWListener(using: parameters, on: nwPort)

            self.listener = newListener
            self.isRunning = true

            await logger.info("PrismServer starting on \(host):\(port)", category: "server")

            let serverRef = self

            newListener.stateUpdateHandler = { state in
                Task {
                    switch state {
                    case .ready:
                        await serverRef.logger.info("Server ready on port \(serverRef.port)", category: "server")
                    case .failed(let error):
                        await serverRef.logger.error("Server failed: \(error)", category: "server")
                    case .cancelled:
                        await serverRef.logger.info("Server cancelled", category: "server")
                    default:
                        break
                    }
                }
            }

            newListener.newConnectionHandler = { connection in
                Task {
                    await serverRef.handleConnection(connection)
                }
            }

            newListener.start(queue: .global(qos: .userInitiated))
        }

        /// Stops the server and closes all connections.
        public func stop() {
            guard isRunning else { return }
            isRunning = false

            for (_, connection) in connections {
                connection.cancel()
            }
            connections.removeAll()

            listener?.cancel()
            listener = nil
        }

        // MARK: - Connection Handling

        private func handleConnection(_ connection: NWConnection) {
            let connectionID = UUID().uuidString
            connections[connectionID] = connection

            let serverRef = self

            connection.stateUpdateHandler = { state in
                switch state {
                case .failed, .cancelled:
                    Task {
                        await serverRef.removeConnection(connectionID)
                    }
                default:
                    break
                }
            }

            connection.start(queue: .global(qos: .userInitiated))
            receiveData(on: connection, connectionID: connectionID, buffer: Data())
        }

        private func removeConnection(_ id: String) {
            connections.removeValue(forKey: id)
        }

        private nonisolated func receiveData(on connection: NWConnection, connectionID: String, buffer: Data) {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) {
                [self] content, _, isComplete, error in
                Task {
                    if let error {
                        await self.logger.debug("Receive error: \(error)", category: "connection")
                        connection.cancel()
                        return
                    }

                    var currentBuffer = buffer
                    if let content {
                        currentBuffer.append(content)
                    }

                    do {
                        let (request, consumed) = try self.parser.parse(currentBuffer)
                        currentBuffer = Data(currentBuffer.dropFirst(consumed))

                        // Check WebSocket upgrade
                        if PrismWebSocketUpgrade.isUpgradeRequest(request),
                            let wsHandler = await self.findWebSocketHandler(for: request.path)
                        {
                            await self.handleWebSocketUpgrade(
                                connection: connection, connectionID: connectionID, request: request, handler: wsHandler
                            )
                            return
                        }

                        let router = await self.buildRouter()
                        let response = try await router.handle(request)

                        let responseData = response.serialize()
                        let nextBuffer = currentBuffer
                        connection.send(
                            content: responseData,
                            completion: .contentProcessed { _ in
                                let shouldKeepAlive =
                                    request.headers.value(for: PrismHTTPHeaders.connection)?.lowercased() != "close"
                                if shouldKeepAlive && !isComplete {
                                    self.receiveData(on: connection, connectionID: connectionID, buffer: nextBuffer)
                                } else {
                                    connection.cancel()
                                }
                            })
                    } catch is PrismHTTPParser.ParserError {
                        if isComplete {
                            connection.cancel()
                        } else {
                            self.receiveData(on: connection, connectionID: connectionID, buffer: currentBuffer)
                        }
                    } catch {
                        let errorResponse = PrismHTTPResponse(
                            status: .internalServerError, body: .text("Internal Server Error"))
                        connection.send(
                            content: errorResponse.serialize(),
                            completion: .contentProcessed { _ in
                                connection.cancel()
                            })
                    }
                }
            }
        }

        private func buildRouter() -> PrismRouter {
            PrismRouter(routes: routes, middlewares: middlewares, groups: groups)
        }

        private func findWebSocketHandler(for path: String) -> (any PrismWebSocketHandler)? {
            webSocketHandlers[path]
        }

        private nonisolated func handleWebSocketUpgrade(
            connection: NWConnection,
            connectionID: String,
            request: PrismHTTPRequest,
            handler: any PrismWebSocketHandler
        ) async {
            guard let upgradeResponse = PrismWebSocketUpgrade.upgradeResponse(for: request) else {
                connection.cancel()
                return
            }

            let responseData = upgradeResponse.serialize()

            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                connection.send(
                    content: responseData,
                    completion: .contentProcessed { _ in
                        continuation.resume()
                    })
            }

            let wsConnection = PrismWebSocketConnection(id: connectionID) { frame in
                await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                    connection.send(
                        content: frame.serialize(),
                        completion: .contentProcessed { _ in
                            cont.resume()
                        })
                }
            }

            await handler.onConnect(connection: wsConnection)
            receiveWebSocketFrames(connection: connection, wsConnection: wsConnection, handler: handler, buffer: Data())
        }

        private nonisolated func receiveWebSocketFrames(
            connection: NWConnection,
            wsConnection: PrismWebSocketConnection,
            handler: any PrismWebSocketHandler,
            buffer: Data
        ) {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { content, _, isComplete, error in
                Task {
                    if error != nil || isComplete {
                        await handler.onDisconnect(connection: wsConnection)
                        connection.cancel()
                        return
                    }

                    var currentBuffer = buffer
                    if let content {
                        currentBuffer.append(content)
                    }

                    let parser = PrismWebSocketParser()

                    while let (frame, consumed) = parser.parse(currentBuffer) {
                        currentBuffer = Data(currentBuffer.dropFirst(consumed))

                        switch frame.opcode {
                        case .text:
                            let text = String(data: frame.payload, encoding: .utf8) ?? ""
                            await handler.onMessage(connection: wsConnection, message: .text(text))
                        case .binary:
                            await handler.onMessage(connection: wsConnection, message: .binary(frame.payload))
                        case .ping:
                            let pong = PrismWebSocketFrame.pong(frame.payload)
                            await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                                connection.send(
                                    content: pong.serialize(),
                                    completion: .contentProcessed { _ in
                                        cont.resume()
                                    })
                            }
                        case .close:
                            await handler.onDisconnect(connection: wsConnection)
                            let closeFrame = PrismWebSocketFrame.close()
                            connection.send(
                                content: closeFrame.serialize(),
                                completion: .contentProcessed { _ in
                                    connection.cancel()
                                })
                            return
                        default:
                            break
                        }
                    }

                    self.receiveWebSocketFrames(
                        connection: connection, wsConnection: wsConnection, handler: handler, buffer: currentBuffer)
                }
            }
        }
    }

    // MARK: - Route Group Builder

    /// Builder for configuring routes within a group.
    public final class PrismRouteGroupBuilder: Sendable {
        private let prefix: String
        private let groupMiddlewares: [any PrismMiddleware]
        private let _routes: LockedBox<[PrismRoute]>
        private let _subgroups: LockedBox<[PrismRouteGroup]>

        init(prefix: String, middlewares: [any PrismMiddleware]) {
            self.prefix = prefix
            self.groupMiddlewares = middlewares
            self._routes = LockedBox([])
            self._subgroups = LockedBox([])
        }

        /// Registers a GET route within this group.
        public func get(_ pattern: String, handler: @escaping PrismRouteHandler) {
            _routes.mutate { $0.append(PrismRoute(method: .GET, pattern: pattern, handler: handler)) }
        }

        /// Registers a POST route within this group.
        public func post(_ pattern: String, handler: @escaping PrismRouteHandler) {
            _routes.mutate { $0.append(PrismRoute(method: .POST, pattern: pattern, handler: handler)) }
        }

        /// Registers a PUT route within this group.
        public func put(_ pattern: String, handler: @escaping PrismRouteHandler) {
            _routes.mutate { $0.append(PrismRoute(method: .PUT, pattern: pattern, handler: handler)) }
        }

        /// Registers a PATCH route within this group.
        public func patch(_ pattern: String, handler: @escaping PrismRouteHandler) {
            _routes.mutate { $0.append(PrismRoute(method: .PATCH, pattern: pattern, handler: handler)) }
        }

        /// Registers a DELETE route within this group.
        public func delete(_ pattern: String, handler: @escaping PrismRouteHandler) {
            _routes.mutate { $0.append(PrismRoute(method: .DELETE, pattern: pattern, handler: handler)) }
        }

        /// Creates a nested sub-group with an additional prefix and optional middleware.
        public func group(
            _ subPrefix: String, middlewares: [any PrismMiddleware] = [], configure: (PrismRouteGroupBuilder) -> Void
        ) {
            let builder = PrismRouteGroupBuilder(prefix: subPrefix, middlewares: middlewares)
            configure(builder)
            _subgroups.mutate { $0.append(builder.build()) }
        }

        func build() -> PrismRouteGroup {
            PrismRouteGroup(
                prefix: prefix, middlewares: groupMiddlewares, routes: _routes.value, subgroups: _subgroups.value)
        }
    }

    /// Thread-safe mutable box for use in Sendable contexts.
    private final class LockedBox<T>: @unchecked Sendable {
        private var _value: T
        private let lock = NSLock()

        init(_ value: T) {
            self._value = value
        }

        var value: T {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }

        func mutate(_ transform: (inout T) -> Void) {
            lock.lock()
            defer { lock.unlock() }
            transform(&_value)
        }
    }
#endif
