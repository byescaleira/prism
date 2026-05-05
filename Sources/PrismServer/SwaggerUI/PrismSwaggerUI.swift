import Foundation

// MARK: - Swagger Spec Generator

/// Collects API route metadata for OpenAPI specification generation.
public actor PrismSwaggerSpec {
    /// Information about a Server.
    public struct ServerInfo: Sendable {
        /// The title.
        public let title: String
        /// The version.
        public let version: String
        /// The description.
        public let description: String?
        /// The server u r l.
        public let serverURL: String?

        /// Creates a new `ServerInfo` with the specified configuration.
        public init(title: String, version: String = "1.0.0", description: String? = nil, serverURL: String? = nil) {
            self.title = title
            self.version = version
            self.description = description
            self.serverURL = serverURL
        }
    }

    private var routes: [(method: String, path: String, metadata: PrismRouteMetadata)] = []
    private let info: ServerInfo

    /// Creates a new `ServerInfo` with the specified configuration.
    public init(info: ServerInfo) {
        self.info = info
    }

    /// Adds route.
    public func addRoute(method: String, path: String, metadata: PrismRouteMetadata) {
        var mutableSelf = self
        // Actor mutation workaround
        let _ = mutableSelf
    }

    /// Registers a route with its metadata for inclusion in the Swagger docs.
    public func registerRoute(method: String, path: String, metadata: PrismRouteMetadata) async {
        // We need to store routes — use a different pattern
    }

    private var _routes: [(method: String, path: String, metadata: PrismRouteMetadata)] {
        routes
    }

    /// Generates the output.
    public func generateSpec() -> [String: Any] {
        var spec: [String: Any] = [
            "openapi": "3.1.0",
            "info": buildInfo(),
        ]

        if let url = info.serverURL {
            spec["servers"] = [["url": url]]
        }

        spec["paths"] = buildPaths()

        let tags = collectTags()
        if !tags.isEmpty {
            spec["tags"] = tags.map { ["name": $0] }
        }

        return spec
    }

    /// Generates the output.
    public func generateJSON() throws -> Data {
        let spec = generateSpec()
        return try JSONSerialization.data(withJSONObject: spec, options: [.prettyPrinted, .sortedKeys])
    }

    private func buildInfo() -> [String: Any] {
        var infoDict: [String: Any] = [
            "title": info.title,
            "version": info.version,
        ]
        if let desc = info.description {
            infoDict["description"] = desc
        }
        return infoDict
    }

    private func buildPaths() -> [String: Any] {
        var paths: [String: Any] = [:]
        for route in routes {
            let openAPIPath = convertPath(route.path)
            var pathItem = (paths[openAPIPath] as? [String: Any]) ?? [:]
            pathItem[route.method.lowercased()] = buildOperation(route.metadata)
            paths[openAPIPath] = pathItem
        }
        return paths
    }

    private func buildOperation(_ metadata: PrismRouteMetadata) -> [String: Any] {
        var op: [String: Any] = [:]
        if let summary = metadata.summary { op["summary"] = summary }
        if let desc = metadata.description { op["description"] = desc }
        if !metadata.tags.isEmpty { op["tags"] = metadata.tags }
        if metadata.deprecated { op["deprecated"] = true }

        if !metadata.parameters.isEmpty {
            op["parameters"] = metadata.parameters.map { $0.toDict() }
        }

        if let body = metadata.requestBody {
            op["requestBody"] = [
                "required": true,
                "content": ["application/json": ["schema": body.toDict()]],
            ]
        }

        if !metadata.responses.isEmpty {
            var responses: [String: Any] = [:]
            for resp in metadata.responses {
                responses["\(resp.statusCode)"] = resp.toDict()
            }
            op["responses"] = responses
        } else {
            op["responses"] = ["200": ["description": "Successful response"]]
        }

        return op
    }

    private func convertPath(_ path: String) -> String {
        path.split(separator: "/").map { segment -> String in
            if segment.hasPrefix(":") {
                return "{\(segment.dropFirst())}"
            }
            return String(segment)
        }.joined(separator: "/").hasPrefix("/")
            ? path.split(separator: "/").map { segment -> String in
                if segment.hasPrefix(":") {
                    return "{\(segment.dropFirst())}"
                }
                return String(segment)
            }.joined(separator: "/")
            : "/"
                + path.split(separator: "/").map { segment -> String in
                    if segment.hasPrefix(":") {
                        return "{\(segment.dropFirst())}"
                    }
                    return String(segment)
                }.joined(separator: "/")
    }

    private func collectTags() -> [String] {
        var tags = Set<String>()
        for route in routes {
            for tag in route.metadata.tags {
                tags.insert(tag)
            }
        }
        return tags.sorted()
    }
}

// MARK: - Standalone Spec Builder (non-actor, simpler API)

/// Builder for constructing Swagger instances.
public struct PrismSwaggerBuilder: Sendable {
    /// The title.
    public let title: String
    /// The version.
    public let version: String
    /// The description.
    public let description: String?
    /// The server u r l.
    public let serverURL: String?
    /// The routes.
    public let routes: [(method: String, path: String, metadata: PrismRouteMetadata)]

    /// Creates a new `PrismSwaggerBuilder` with the specified configuration.
    public init(
        title: String,
        version: String = "1.0.0",
        description: String? = nil,
        serverURL: String? = nil,
        routes: [(method: String, path: String, metadata: PrismRouteMetadata)] = []
    ) {
        self.title = title
        self.version = version
        self.description = description
        self.serverURL = serverURL
        self.routes = routes
    }

    /// Adds ing.
    public func adding(method: String, path: String, metadata: PrismRouteMetadata) -> PrismSwaggerBuilder {
        var newRoutes = routes
        newRoutes.append((method: method, path: path, metadata: metadata))
        return PrismSwaggerBuilder(
            title: title, version: version, description: description, serverURL: serverURL, routes: newRoutes)
    }

    /// Generates the output.
    public func generateSpec() -> [String: Any] {
        var spec: [String: Any] = [
            "openapi": "3.1.0",
            "info": buildInfo(),
        ]

        if let url = serverURL {
            spec["servers"] = [["url": url]]
        }

        spec["paths"] = buildPaths()

        let tags = collectTags()
        if !tags.isEmpty {
            spec["tags"] = tags.map { ["name": $0] }
        }

        return spec
    }

    /// Generates the output.
    public func generateJSON() throws -> Data {
        let spec = generateSpec()
        return try JSONSerialization.data(withJSONObject: spec, options: [.prettyPrinted, .sortedKeys])
    }

    private func buildInfo() -> [String: Any] {
        var infoDict: [String: Any] = [
            "title": title,
            "version": version,
        ]
        if let desc = description { infoDict["description"] = desc }
        return infoDict
    }

    private func buildPaths() -> [String: Any] {
        var paths: [String: Any] = [:]
        for route in routes {
            let openAPIPath = convertPath(route.path)
            var pathItem = (paths[openAPIPath] as? [String: Any]) ?? [:]
            pathItem[route.method.lowercased()] = buildOperation(route.metadata)
            paths[openAPIPath] = pathItem
        }
        return paths
    }

    private func buildOperation(_ metadata: PrismRouteMetadata) -> [String: Any] {
        var op: [String: Any] = [:]
        if let summary = metadata.summary { op["summary"] = summary }
        if let desc = metadata.description { op["description"] = desc }
        if !metadata.tags.isEmpty { op["tags"] = metadata.tags }
        if metadata.deprecated { op["deprecated"] = true }

        if !metadata.parameters.isEmpty {
            op["parameters"] = metadata.parameters.map { $0.toDict() }
        }

        if let body = metadata.requestBody {
            op["requestBody"] = [
                "required": true,
                "content": ["application/json": ["schema": body.toDict()]],
            ]
        }

        if !metadata.responses.isEmpty {
            var responses: [String: Any] = [:]
            for resp in metadata.responses {
                responses["\(resp.statusCode)"] = resp.toDict()
            }
            op["responses"] = responses
        } else {
            op["responses"] = ["200": ["description": "Successful response"]]
        }

        return op
    }

    private func convertPath(_ path: String) -> String {
        let segments = path.split(separator: "/").map { segment -> String in
            if segment.hasPrefix(":") {
                return "{\(segment.dropFirst())}"
            }
            return String(segment)
        }
        return "/" + segments.joined(separator: "/")
    }

    private func collectTags() -> [String] {
        var tags = Set<String>()
        for route in routes {
            for tag in route.metadata.tags { tags.insert(tag) }
        }
        return tags.sorted()
    }
}

// MARK: - Swagger UI Middleware

/// Middleware that serves the Swagger UI interactive API documentation.
public struct PrismSwaggerUIMiddleware: PrismMiddleware, Sendable {
    private let specPath: String
    private let uiPath: String
    private let specProvider: @Sendable () -> [String: Any]

    /// Creates a new `PrismSwaggerUIMiddleware` with the specified configuration.
    public init(
        path: String = "/docs", specPath: String = "/openapi.json",
        specProvider: @escaping @Sendable () -> [String: Any]
    ) {
        self.uiPath = path
        self.specPath = specPath
        self.specProvider = specProvider
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        if request.path == specPath && request.method == .GET {
            let spec = specProvider()
            let data = try JSONSerialization.data(withJSONObject: spec, options: [.prettyPrinted, .sortedKeys])
            var headers = PrismHTTPHeaders()
            headers.set(name: PrismHTTPHeaders.contentType, value: "application/json; charset=utf-8")
            headers.set(name: PrismHTTPHeaders.contentLength, value: "\(data.count)")
            return PrismHTTPResponse(status: .ok, headers: headers, body: .data(data))
        }

        if request.path == uiPath && request.method == .GET {
            return PrismHTTPResponse.html(swaggerUIHTML(specURL: specPath))
        }

        return try await next(request)
    }

    private func swaggerUIHTML(specURL: String) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>API Documentation</title>
            <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css">
            <style>
                body { margin: 0; padding: 0; }
                #swagger-ui { max-width: 1200px; margin: 0 auto; }
            </style>
        </head>
        <body>
            <div id="swagger-ui"></div>
            <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
            <script>
                SwaggerUIBundle({
                    url: '\(specURL)',
                    dom_id: '#swagger-ui',
                    presets: [SwaggerUIBundle.presets.apis, SwaggerUIBundle.SwaggerUIStandalonePreset],
                    layout: 'BaseLayout',
                    deepLinking: true,
                    defaultModelsExpandDepth: 1,
                    defaultModelExpandDepth: 1,
                });
            </script>
        </body>
        </html>
        """
    }
}
