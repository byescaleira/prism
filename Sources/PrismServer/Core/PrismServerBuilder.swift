#if canImport(Network)
import Foundation
import PrismFoundation

/// Fluent builder for configuring and starting a PrismHTTPServer.
///
/// Usage:
/// ```swift
/// try await PrismServer {
///     Port(8080)
///     Log(.info)
///     CORS()
///     GET("/health") { _ in .json(["status": "up"]) }
///     GET("/users/:id") { req in .text("User \(req.parameter("id")!)") }
///     Group("/api") {
///         Auth { token in token == "secret" }
///         POST("/items") { req in
///             let item = try req.decodeJSON(Item.self)
///             return .json(item, status: .created)
///         }
///     }
/// }
/// ```
public struct PrismServerBuilder: Sendable {
    private let host: String
    private let port: UInt16
    private let middlewares: [any PrismMiddleware]
    private let routes: [PrismRoute]
    private let groups: [PrismRouteGroup]
    private let webSocketHandlers: [(String, any PrismWebSocketHandler)]
    private let tlsConfig: PrismTLSConfiguration?
    private let logLevel: PrismLogLevel

    public init(
        host: String = "0.0.0.0",
        port: UInt16 = 8080,
        tlsConfig: PrismTLSConfiguration? = nil,
        logLevel: PrismLogLevel = .info
    ) {
        self.host = host
        self.port = port
        self.middlewares = []
        self.routes = []
        self.groups = []
        self.webSocketHandlers = []
        self.tlsConfig = tlsConfig
        self.logLevel = logLevel
    }

    private init(
        host: String,
        port: UInt16,
        middlewares: [any PrismMiddleware],
        routes: [PrismRoute],
        groups: [PrismRouteGroup],
        webSocketHandlers: [(String, any PrismWebSocketHandler)],
        tlsConfig: PrismTLSConfiguration?,
        logLevel: PrismLogLevel
    ) {
        self.host = host
        self.port = port
        self.middlewares = middlewares
        self.routes = routes
        self.groups = groups
        self.webSocketHandlers = webSocketHandlers
        self.tlsConfig = tlsConfig
        self.logLevel = logLevel
    }

    /// Adds a middleware.
    public func middleware(_ m: any PrismMiddleware) -> PrismServerBuilder {
        PrismServerBuilder(host: host, port: port, middlewares: middlewares + [m], routes: routes, groups: groups, webSocketHandlers: webSocketHandlers, tlsConfig: tlsConfig, logLevel: logLevel)
    }

    /// Adds a route.
    public func route(_ method: PrismHTTPMethod, _ pattern: String, handler: @escaping PrismRouteHandler) -> PrismServerBuilder {
        let route = PrismRoute(method: method, pattern: pattern, handler: handler)
        return PrismServerBuilder(host: host, port: port, middlewares: middlewares, routes: routes + [route], groups: groups, webSocketHandlers: webSocketHandlers, tlsConfig: tlsConfig, logLevel: logLevel)
    }

    /// Adds a GET route.
    public func get(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismServerBuilder {
        route(.GET, pattern, handler: handler)
    }

    /// Adds a POST route.
    public func post(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismServerBuilder {
        route(.POST, pattern, handler: handler)
    }

    /// Adds a PUT route.
    public func put(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismServerBuilder {
        route(.PUT, pattern, handler: handler)
    }

    /// Adds a DELETE route.
    public func delete(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismServerBuilder {
        route(.DELETE, pattern, handler: handler)
    }

    /// Builds and starts the server.
    public func start() async throws -> PrismHTTPServer {
        let logger = PrismStructuredLogger(
            minimumLevel: logLevel,
            destinations: [PrismConsoleLogDestination()]
        )

        let server = PrismHTTPServer(host: host, port: port, tlsConfig: tlsConfig, logger: logger)

        for m in middlewares {
            await server.use(m)
        }

        for route in routes {
            await server.route(route.method, route.pattern, handler: route.handler)
        }

        for (path, handler) in webSocketHandlers {
            await server.webSocket(path, handler: handler)
        }

        try await server.start()
        return server
    }
}
#endif
