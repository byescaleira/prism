import Foundation

/// In-process test client for PrismServer that bypasses network transport.
public struct PrismTestClient: Sendable {
    private let router: PrismRouter

    /// Creates a new `PrismTestClient` with the specified configuration.
    public init(router: PrismRouter) {
        self.router = router
    }

    /// Sends a request through the router and returns the response.
    public func send(_ request: PrismHTTPRequest) async throws -> PrismHTTPResponse {
        try await router.handle(request)
    }

    /// Sends a GET request to the given path.
    public func get(_ path: String, headers: PrismHTTPHeaders = PrismHTTPHeaders()) async throws -> PrismHTTPResponse {
        let request = PrismHTTPRequest(method: .GET, uri: path, headers: headers)
        return try await send(request)
    }

    /// Sends a POST request with an optional body.
    public func post(_ path: String, body: Data? = nil, headers: PrismHTTPHeaders = PrismHTTPHeaders()) async throws
        -> PrismHTTPResponse
    {
        let request = PrismHTTPRequest(method: .POST, uri: path, headers: headers, body: body)
        return try await send(request)
    }

    /// Sends a POST request with a JSON-encoded body.
    public func postJSON<T: Encodable>(_ path: String, body: T, encoder: JSONEncoder = JSONEncoder()) async throws
        -> PrismHTTPResponse
    {
        let data = try encoder.encode(body)
        var headers = PrismHTTPHeaders()
        headers.set(name: PrismHTTPHeaders.contentType, value: "application/json")
        headers.set(name: PrismHTTPHeaders.contentLength, value: "\(data.count)")
        return try await post(path, body: data, headers: headers)
    }

    /// Sends a PUT request with an optional body.
    public func put(_ path: String, body: Data? = nil, headers: PrismHTTPHeaders = PrismHTTPHeaders()) async throws
        -> PrismHTTPResponse
    {
        let request = PrismHTTPRequest(method: .PUT, uri: path, headers: headers, body: body)
        return try await send(request)
    }

    /// Sends a PATCH request with an optional body.
    public func patch(_ path: String, body: Data? = nil, headers: PrismHTTPHeaders = PrismHTTPHeaders()) async throws
        -> PrismHTTPResponse
    {
        let request = PrismHTTPRequest(method: .PATCH, uri: path, headers: headers, body: body)
        return try await send(request)
    }

    /// Sends a DELETE request.
    public func delete(_ path: String, headers: PrismHTTPHeaders = PrismHTTPHeaders()) async throws -> PrismHTTPResponse
    {
        let request = PrismHTTPRequest(method: .DELETE, uri: path, headers: headers)
        return try await send(request)
    }
}

/// Builder that constructs a PrismTestClient from route and middleware definitions.
public final class PrismTestClientBuilder: Sendable {
    private let _routes: LockedTestBox<[PrismRoute]>
    private let _middlewares: LockedTestBox<[any PrismMiddleware]>

    /// Creates a new `PrismTestClientBuilder`.
    public init() {
        self._routes = LockedTestBox([])
        self._middlewares = LockedTestBox([])
    }

    /// Registers a route handler for the given method and pattern.
    public func route(_ method: PrismHTTPMethod, _ pattern: String, handler: @escaping PrismRouteHandler)
        -> PrismTestClientBuilder
    {
        _routes.mutate { $0.append(PrismRoute(method: method, pattern: pattern, handler: handler)) }
        return self
    }

    /// Registers a GET route handler for the given pattern.
    public func get(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismTestClientBuilder {
        route(.GET, pattern, handler: handler)
    }

    /// Sends a POST request.
    public func post(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismTestClientBuilder {
        route(.POST, pattern, handler: handler)
    }

    /// Adds a middleware to the test client pipeline.
    public func use(_ middleware: any PrismMiddleware) -> PrismTestClientBuilder {
        _middlewares.mutate { $0.append(middleware) }
        return self
    }

    /// Builds the test client with all registered routes and middleware.
    public func build() -> PrismTestClient {
        let router = PrismRouter(routes: _routes.value, middlewares: _middlewares.value, groups: [])
        return PrismTestClient(router: router)
    }
}

private final class LockedTestBox<T>: @unchecked Sendable {
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
