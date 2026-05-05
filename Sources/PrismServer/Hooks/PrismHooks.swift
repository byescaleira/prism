import Foundation

/// Hook called before request routing. Can modify the request.
public typealias PrismRequestHook = @Sendable (PrismHTTPRequest) async throws -> PrismHTTPRequest

/// Hook called after handler produces a response. Can modify the response.
public typealias PrismResponseHook = @Sendable (PrismHTTPRequest, PrismHTTPResponse) async throws -> PrismHTTPResponse

/// Hook called when an error occurs. Can return a custom response.
public typealias PrismErrorHook = @Sendable (Error, PrismHTTPRequest) async -> PrismHTTPResponse?

/// Registry for request lifecycle hooks.
public actor PrismHookRegistry {
    private var requestHooks: [PrismRequestHook] = []
    private var responseHooks: [PrismResponseHook] = []
    private var errorHooks: [PrismErrorHook] = []

    /// Creates a new `PrismHookRegistry` with the specified configuration.
    public init() {}

    /// Registers a hook that runs before request routing.
    public func onRequest(_ hook: @escaping PrismRequestHook) {
        requestHooks.append(hook)
    }

    /// Registers a hook that runs after the response is produced.
    public func onResponse(_ hook: @escaping PrismResponseHook) {
        responseHooks.append(hook)
    }

    /// Registers a hook that runs when an error occurs.
    public func onError(_ hook: @escaping PrismErrorHook) {
        errorHooks.append(hook)
    }

    /// Runs all request hooks in order, threading the request through each.
    public func runRequestHooks(_ request: PrismHTTPRequest) async throws -> PrismHTTPRequest {
        var req = request
        for hook in requestHooks {
            req = try await hook(req)
        }
        return req
    }

    /// Runs all response hooks in order, threading the response through each.
    public func runResponseHooks(_ request: PrismHTTPRequest, response: PrismHTTPResponse) async throws -> PrismHTTPResponse {
        var resp = response
        for hook in responseHooks {
            resp = try await hook(request, resp)
        }
        return resp
    }

    /// Runs error hooks until one returns a response, or returns nil.
    public func runErrorHooks(_ error: Error, request: PrismHTTPRequest) async -> PrismHTTPResponse? {
        for hook in errorHooks {
            if let response = await hook(error, request) {
                return response
            }
        }
        return nil
    }

    /// Number of registered request hooks.
    public var requestHookCount: Int { requestHooks.count }

    /// Number of registered response hooks.
    public var responseHookCount: Int { responseHooks.count }

    /// Number of registered error hooks.
    public var errorHookCount: Int { errorHooks.count }
}

/// Middleware that integrates hook registry into the request pipeline.
public struct PrismHooksMiddleware: PrismMiddleware, Sendable {
    private let registry: PrismHookRegistry

    /// Creates a new `PrismHooksMiddleware` with the specified configuration.
    public init(registry: PrismHookRegistry) {
        self.registry = registry
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        do {
            let modifiedRequest = try await registry.runRequestHooks(request)
            let response = try await next(modifiedRequest)
            let modifiedResponse = try await registry.runResponseHooks(modifiedRequest, response: response)
            return modifiedResponse
        } catch {
            if let errorResponse = await registry.runErrorHooks(error, request: request) {
                return errorResponse
            }
            throw error
        }
    }
}
