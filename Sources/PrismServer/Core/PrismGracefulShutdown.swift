#if canImport(Network)
import Foundation

/// Manages graceful server shutdown with connection draining.
public actor PrismGracefulShutdown {
    private var shutdownHandlers: [@Sendable () async -> Void] = []
    private var isShuttingDown = false
    private let drainTimeout: Duration
    private var signalSources: [any Sendable] = []

    public init(drainTimeout: Duration = .seconds(30)) {
        self.drainTimeout = drainTimeout
    }

    /// Registers a handler to be called during shutdown.
    public func onShutdown(_ handler: @escaping @Sendable () async -> Void) {
        shutdownHandlers.append(handler)
    }

    /// Whether the server is in shutdown mode.
    public var shuttingDown: Bool { isShuttingDown }

    /// Installs signal handlers for SIGTERM and SIGINT.
    public func installSignalHandlers(shutdown: @escaping @Sendable () async -> Void) {
        let termSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .global())
        let intSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())

        signal(SIGTERM, SIG_IGN)
        signal(SIGINT, SIG_IGN)

        let selfRef = self

        termSource.setEventHandler {
            Task { await selfRef.performShutdown(shutdown) }
        }
        intSource.setEventHandler {
            Task { await selfRef.performShutdown(shutdown) }
        }

        termSource.resume()
        intSource.resume()

        signalSources.append(termSource as any Sendable)
        signalSources.append(intSource as any Sendable)
    }

    /// Performs graceful shutdown: runs all handlers, then calls the final shutdown closure.
    public func performShutdown(_ finalShutdown: @escaping @Sendable () async -> Void) async {
        guard !isShuttingDown else { return }
        isShuttingDown = true

        for handler in shutdownHandlers {
            await handler()
        }

        await finalShutdown()
    }
}

/// Middleware that rejects new requests during shutdown.
public struct PrismShutdownMiddleware: PrismMiddleware, Sendable {
    private let shutdown: PrismGracefulShutdown

    public init(shutdown: PrismGracefulShutdown) {
        self.shutdown = shutdown
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        if await shutdown.shuttingDown {
            return PrismHTTPResponse(
                status: .serviceUnavailable,
                headers: PrismHTTPHeaders([("Connection", "close"), ("Retry-After", "5")]),
                body: .text("Server is shutting down")
            )
        }
        return try await next(request)
    }
}
#endif
