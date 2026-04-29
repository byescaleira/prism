import Foundation

// MARK: - OpenAPI Schema Types

public enum PrismOpenAPIType: String, Sendable {
    case string, integer, number, boolean, array, object
}

public struct PrismOpenAPISchema: Sendable {
    public let type: PrismOpenAPIType
    public let properties: [(String, PrismOpenAPIProperty)]
    public let required: [String]
    public let items: PrismOpenAPIProperty?
    public let description: String?

    public init(
        type: PrismOpenAPIType,
        properties: [(String, PrismOpenAPIProperty)] = [],
        required: [String] = [],
        items: PrismOpenAPIProperty? = nil,
        description: String? = nil
    ) {
        self.type = type
        self.properties = properties
        self.required = required
        self.items = items
        self.description = description
    }

    public static func object(_ properties: [(String, PrismOpenAPIProperty)], required: [String] = [], description: String? = nil) -> PrismOpenAPISchema {
        PrismOpenAPISchema(type: .object, properties: properties, required: required, description: description)
    }

    public static func array(of items: PrismOpenAPIProperty, description: String? = nil) -> PrismOpenAPISchema {
        PrismOpenAPISchema(type: .array, items: items, description: description)
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = ["type": type.rawValue]
        if let description { dict["description"] = description }
        if !properties.isEmpty {
            var props: [String: Any] = [:]
            for (name, prop) in properties {
                props[name] = prop.toDict()
            }
            dict["properties"] = props
        }
        if !required.isEmpty { dict["required"] = required }
        if let items { dict["items"] = items.toDict() }
        return dict
    }
}

public struct PrismOpenAPIProperty: Sendable {
    public let type: PrismOpenAPIType
    public let format: String?
    public let description: String?
    public let enumValues: [String]?
    public let nullable: Bool

    public init(type: PrismOpenAPIType, format: String? = nil, description: String? = nil, enumValues: [String]? = nil, nullable: Bool = false) {
        self.type = type
        self.format = format
        self.description = description
        self.enumValues = enumValues
        self.nullable = nullable
    }

    public static func string(_ description: String? = nil, format: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .string, format: format, description: description)
    }

    public static func integer(_ description: String? = nil, format: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .integer, format: format ?? "int64", description: description)
    }

    public static func number(_ description: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .number, description: description)
    }

    public static func boolean(_ description: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .boolean, description: description)
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = ["type": type.rawValue]
        if let format { dict["format"] = format }
        if let description { dict["description"] = description }
        if let enumValues { dict["enum"] = enumValues }
        if nullable { dict["nullable"] = true }
        return dict
    }
}

// MARK: - Route Metadata

public struct PrismOpenAPIParameter: Sendable {
    public enum Location: String, Sendable { case path, query, header }

    public let name: String
    public let location: Location
    public let description: String?
    public let required: Bool
    public let type: PrismOpenAPIType

    public init(name: String, in location: Location, description: String? = nil, required: Bool = false, type: PrismOpenAPIType = .string) {
        self.name = name
        self.location = location
        self.description = description
        self.required = location == .path ? true : required
        self.type = type
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "in": location.rawValue,
            "required": self.required,
            "schema": ["type": type.rawValue]
        ]
        if let description { dict["description"] = description }
        return dict
    }
}

public struct PrismOpenAPIResponseSpec: Sendable {
    public let statusCode: Int
    public let description: String
    public let schema: PrismOpenAPISchema?
    public let contentType: String

    public init(statusCode: Int, description: String, schema: PrismOpenAPISchema? = nil, contentType: String = "application/json") {
        self.statusCode = statusCode
        self.description = description
        self.schema = schema
        self.contentType = contentType
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = ["description": description]
        if let schema {
            dict["content"] = [contentType: ["schema": schema.toDict()]]
        }
        return dict
    }
}

public struct PrismRouteMetadata: Sendable {
    public let summary: String?
    public let description: String?
    public let tags: [String]
    public let parameters: [PrismOpenAPIParameter]
    public let requestBody: PrismOpenAPISchema?
    public let responses: [PrismOpenAPIResponseSpec]
    public let deprecated: Bool

    public init(
        summary: String? = nil,
        description: String? = nil,
        tags: [String] = [],
        parameters: [PrismOpenAPIParameter] = [],
        requestBody: PrismOpenAPISchema? = nil,
        responses: [PrismOpenAPIResponseSpec] = [],
        deprecated: Bool = false
    ) {
        self.summary = summary
        self.description = description
        self.tags = tags
        self.parameters = parameters
        self.requestBody = requestBody
        self.responses = responses
        self.deprecated = deprecated
    }
}

// MARK: - Swagger Spec Generator

public actor PrismSwaggerSpec {
    public struct ServerInfo: Sendable {
        public let title: String
        public let version: String
        public let description: String?
        public let serverURL: String?

        public init(title: String, version: String = "1.0.0", description: String? = nil, serverURL: String? = nil) {
            self.title = title
            self.version = version
            self.description = description
            self.serverURL = serverURL
        }
    }

    private var routes: [(method: String, path: String, metadata: PrismRouteMetadata)] = []
    private let info: ServerInfo

    public init(info: ServerInfo) {
        self.info = info
    }

    public func addRoute(method: String, path: String, metadata: PrismRouteMetadata) {
        var mutableSelf = self
        // Actor mutation workaround
        let _ = mutableSelf
    }

    public func registerRoute(method: String, path: String, metadata: PrismRouteMetadata) async {
        // We need to store routes — use a different pattern
    }

    private var _routes: [(method: String, path: String, metadata: PrismRouteMetadata)] {
        get { routes }
    }

    public func generateSpec() -> [String: Any] {
        var spec: [String: Any] = [
            "openapi": "3.1.0",
            "info": buildInfo()
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

    public func generateJSON() throws -> Data {
        let spec = generateSpec()
        return try JSONSerialization.data(withJSONObject: spec, options: [.prettyPrinted, .sortedKeys])
    }

    private func buildInfo() -> [String: Any] {
        var infoDict: [String: Any] = [
            "title": info.title,
            "version": info.version
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
                "content": ["application/json": ["schema": body.toDict()]]
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
        }.joined(separator: "/").hasPrefix("/") ? path.split(separator: "/").map { segment -> String in
            if segment.hasPrefix(":") {
                return "{\(segment.dropFirst())}"
            }
            return String(segment)
        }.joined(separator: "/") : "/" + path.split(separator: "/").map { segment -> String in
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

public struct PrismSwaggerBuilder: Sendable {
    public let title: String
    public let version: String
    public let description: String?
    public let serverURL: String?
    public let routes: [(method: String, path: String, metadata: PrismRouteMetadata)]

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

    public func adding(method: String, path: String, metadata: PrismRouteMetadata) -> PrismSwaggerBuilder {
        var newRoutes = routes
        newRoutes.append((method: method, path: path, metadata: metadata))
        return PrismSwaggerBuilder(title: title, version: version, description: description, serverURL: serverURL, routes: newRoutes)
    }

    public func generateSpec() -> [String: Any] {
        var spec: [String: Any] = [
            "openapi": "3.1.0",
            "info": buildInfo()
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

    public func generateJSON() throws -> Data {
        let spec = generateSpec()
        return try JSONSerialization.data(withJSONObject: spec, options: [.prettyPrinted, .sortedKeys])
    }

    private func buildInfo() -> [String: Any] {
        var infoDict: [String: Any] = [
            "title": title,
            "version": version
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
                "content": ["application/json": ["schema": body.toDict()]]
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

public struct PrismSwaggerUIMiddleware: PrismMiddleware, Sendable {
    private let specPath: String
    private let uiPath: String
    private let specProvider: @Sendable () -> [String: Any]

    public init(path: String = "/docs", specPath: String = "/openapi.json", specProvider: @escaping @Sendable () -> [String: Any]) {
        self.uiPath = path
        self.specPath = specPath
        self.specProvider = specProvider
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
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
