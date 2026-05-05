import Foundation

/// Routes HTTP requests to registered handlers with middleware support.
public final class PrismRouter: Sendable {
    private let routes: [PrismRoute]
    private let middlewares: [any PrismMiddleware]
    private let groups: [PrismRouteGroup]

    init(
        routes: [PrismRoute],
        middlewares: [any PrismMiddleware],
        groups: [PrismRouteGroup]
    ) {
        self.routes = routes
        self.middlewares = middlewares
        self.groups = groups
    }

    /// Resolves a request to the matching handler, applying middleware chain.
    func handle(_ request: PrismHTTPRequest) async throws -> PrismHTTPResponse {
        if let (route, params) = findRoute(method: request.method, path: request.path, in: routes, groups: groups) {
            var req = request
            req.parameters = params

            let allMiddleware = collectMiddleware(for: request.path)
            let chain = buildChain(middlewares: allMiddleware, handler: route.handler)
            return try await chain(req)
        }

        return PrismHTTPResponse(status: .notFound, body: .text("Not Found"))
    }

    private func findRoute(
        method: PrismHTTPMethod,
        path: String,
        in routes: [PrismRoute],
        groups: [PrismRouteGroup]
    ) -> (PrismRoute, [String: String])? {
        for route in routes where route.method == method {
            if let params = route.match(path: path) {
                return (route, params)
            }
        }

        for group in groups {
            if path.hasPrefix(group.prefix) || path == group.prefix {
                let subPath = String(path.dropFirst(group.prefix.count))
                let normalizedSubPath = subPath.isEmpty ? "/" : subPath
                if let result = findRoute(
                    method: method, path: normalizedSubPath, in: group.routes, groups: group.subgroups)
                {
                    return result
                }
            }
        }

        return nil
    }

    private func collectMiddleware(for path: String) -> [any PrismMiddleware] {
        var result = middlewares

        for group in groups {
            if path.hasPrefix(group.prefix) {
                result.append(contentsOf: group.middlewares)
                result.append(
                    contentsOf: collectGroupMiddleware(path: path, groups: group.subgroups, prefix: group.prefix))
            }
        }

        return result
    }

    private func collectGroupMiddleware(path: String, groups: [PrismRouteGroup], prefix: String)
        -> [any PrismMiddleware]
    {
        var result: [any PrismMiddleware] = []
        for group in groups {
            let fullPrefix = prefix + group.prefix
            if path.hasPrefix(fullPrefix) {
                result.append(contentsOf: group.middlewares)
                result.append(
                    contentsOf: collectGroupMiddleware(path: path, groups: group.subgroups, prefix: fullPrefix))
            }
        }
        return result
    }

    private func buildChain(
        middlewares: [any PrismMiddleware],
        handler: @escaping PrismRouteHandler
    ) -> PrismRouteHandler {
        var chain = handler
        for middleware in middlewares.reversed() {
            let next = chain
            chain = { request in
                try await middleware.handle(request, next: next)
            }
        }
        return chain
    }
}

/// A group of routes sharing a common path prefix and middleware stack.
struct PrismRouteGroup: Sendable {
    let prefix: String
    let middlewares: [any PrismMiddleware]
    let routes: [PrismRoute]
    let subgroups: [PrismRouteGroup]
}
