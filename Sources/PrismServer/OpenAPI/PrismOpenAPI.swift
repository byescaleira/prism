import Foundation

/// Metadata for an API endpoint used in OpenAPI documentation.
public struct PrismAPIEndpoint: Sendable {
    /// The method.
    public let method: PrismHTTPMethod
    /// The path.
    public let path: String
    /// The summary.
    public let summary: String
    /// The description.
    public let description: String
    /// The tags.
    public let tags: [String]
    /// The parameters.
    public let parameters: [PrismAPIParameter]
    /// The request body.
    public let requestBody: PrismAPIBody?
    /// The responses.
    public let responses: [PrismAPIResponse]

    /// Creates a new `PrismAPIEndpoint` with the specified configuration.
    public init(
        method: PrismHTTPMethod,
        path: String,
        summary: String = "",
        description: String = "",
        tags: [String] = [],
        parameters: [PrismAPIParameter] = [],
        requestBody: PrismAPIBody? = nil,
        responses: [PrismAPIResponse] = []
    ) {
        self.method = method
        self.path = path
        self.summary = summary
        self.description = description
        self.tags = tags
        self.parameters = parameters
        self.requestBody = requestBody
        self.responses = responses
    }
}

/// An API parameter (path, query, header).
public struct PrismAPIParameter: Sendable {
    /// The location of the parameter in the HTTP request.
    public enum Location: String, Sendable {
        case path, query, header
    }

    /// The name.
    public let name: String
    /// The location.
    public let location: Location
    /// The required.
    public let required: Bool
    /// The type.
    public let type: String
    /// The description.
    public let description: String

    /// Creates a new `Location` with the specified configuration.
    public init(
        name: String, location: Location = .query, required: Bool = false, type: String = "string",
        description: String = ""
    ) {
        self.name = name
        self.location = location
        self.required = required
        self.type = type
        self.description = description
    }
}

/// An API request/response body definition.
public struct PrismAPIBody: Sendable {
    /// The content type.
    public let contentType: String
    /// The description.
    public let description: String
    /// The schema ref.
    public let schemaRef: String?

    /// Creates a new `PrismAPIBody` with the specified configuration.
    public init(contentType: String = "application/json", description: String = "", schemaRef: String? = nil) {
        self.contentType = contentType
        self.description = description
        self.schemaRef = schemaRef
    }
}

/// An API response definition.
public struct PrismAPIResponse: Sendable {
    /// The status code.
    public let statusCode: Int
    /// The description.
    public let description: String
    /// The content type.
    public let contentType: String?
    /// The schema ref.
    public let schemaRef: String?

    /// Creates a new `PrismAPIResponse` with the specified configuration.
    public init(statusCode: Int, description: String = "", contentType: String? = nil, schemaRef: String? = nil) {
        self.statusCode = statusCode
        self.description = description
        self.contentType = contentType
        self.schemaRef = schemaRef
    }
}

/// Generates OpenAPI 3.0 JSON specification from documented endpoints.
public struct PrismOpenAPIGenerator: Sendable {
    private let title: String
    private let version: String
    private let description: String
    private let serverURL: String
    private let endpoints: [PrismAPIEndpoint]

    /// Creates a new `PrismOpenAPIGenerator` with the specified configuration.
    public init(
        title: String,
        version: String = "1.0.0",
        description: String = "",
        serverURL: String = "http://localhost:8080",
        endpoints: [PrismAPIEndpoint]
    ) {
        self.title = title
        self.version = version
        self.description = description
        self.serverURL = serverURL
        self.endpoints = endpoints
    }

    /// Generates the OpenAPI spec as a JSON-serializable dictionary.
    public func generate() -> [String: Any] {
        var spec: [String: Any] = [
            "openapi": "3.0.3",
            "info": [
                "title": title,
                "version": version,
                "description": description,
            ] as [String: Any],
            "servers": [
                ["url": serverURL]
            ],
        ]

        var paths: [String: Any] = [:]

        for endpoint in endpoints {
            let openAPIPath = endpoint.path.replacingOccurrences(of: ":", with: "{")
                .split(separator: "/")
                .map { segment in
                    var s = String(segment)
                    if s.hasPrefix("{") && !s.hasSuffix("}") { s += "}" }
                    return s
                }
                .joined(separator: "/")
            let pathKey = "/" + openAPIPath

            var existing = paths[pathKey] as? [String: Any] ?? [:]
            existing[endpoint.method.rawValue.lowercased()] = buildOperation(endpoint)
            paths[pathKey] = existing
        }

        spec["paths"] = paths
        return spec
    }

    /// Generates the OpenAPI spec as JSON data.
    public func generateJSON(prettyPrinted: Bool = true) throws -> Data {
        let spec = generate()
        let options: JSONSerialization.WritingOptions = prettyPrinted ? [.prettyPrinted, .sortedKeys] : [.sortedKeys]
        return try JSONSerialization.data(withJSONObject: spec, options: options)
    }

    private func buildOperation(_ endpoint: PrismAPIEndpoint) -> [String: Any] {
        var op: [String: Any] = [:]

        if !endpoint.summary.isEmpty { op["summary"] = endpoint.summary }
        if !endpoint.description.isEmpty { op["description"] = endpoint.description }
        if !endpoint.tags.isEmpty { op["tags"] = endpoint.tags }

        if !endpoint.parameters.isEmpty {
            op["parameters"] = endpoint.parameters.map { param in
                var p: [String: Any] = [
                    "name": param.name,
                    "in": param.location.rawValue,
                    "required": param.required,
                    "schema": ["type": param.type],
                ]
                if !param.description.isEmpty { p["description"] = param.description }
                return p
            }
        }

        if let body = endpoint.requestBody {
            var content: [String: Any] = [:]
            var mediaType: [String: Any] = [:]
            if let ref = body.schemaRef {
                mediaType["schema"] = ["$ref": "#/components/schemas/\(ref)"]
            }
            content[body.contentType] = mediaType
            op["requestBody"] =
                [
                    "description": body.description,
                    "content": content,
                ] as [String: Any]
        }

        if !endpoint.responses.isEmpty {
            var responses: [String: Any] = [:]
            for resp in endpoint.responses {
                var r: [String: Any] = ["description": resp.description]
                if let ct = resp.contentType {
                    var mediaType: [String: Any] = [:]
                    if let ref = resp.schemaRef {
                        mediaType["schema"] = ["$ref": "#/components/schemas/\(ref)"]
                    }
                    r["content"] = [ct: mediaType] as [String: Any]
                }
                responses["\(resp.statusCode)"] = r
            }
            op["responses"] = responses
        } else {
            op["responses"] = ["200": ["description": "Success"]]
        }

        return op
    }
}

/// Middleware that serves the OpenAPI spec at /openapi.json and Swagger UI at /docs.
public struct PrismOpenAPIMiddleware: PrismMiddleware {
    private let generator: PrismOpenAPIGenerator
    private let specPath: String
    private let docsPath: String

    /// Creates a new `PrismOpenAPIMiddleware` with the specified configuration.
    public init(generator: PrismOpenAPIGenerator, specPath: String = "/openapi.json", docsPath: String = "/docs") {
        self.generator = generator
        self.specPath = specPath
        self.docsPath = docsPath
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        if request.path == specPath && request.method == .GET {
            do {
                let data = try generator.generateJSON()
                var headers = PrismHTTPHeaders()
                headers.set(name: PrismHTTPHeaders.contentType, value: "application/json; charset=utf-8")
                return PrismHTTPResponse(status: .ok, headers: headers, body: .data(data))
            } catch {
                return PrismHTTPResponse(status: .internalServerError, body: .text("OpenAPI generation failed"))
            }
        }

        if request.path == docsPath && request.method == .GET {
            return .html(swaggerUI)
        }

        return try await next(request)
    }

    private var swaggerUI: String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <title>API Documentation</title>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css">
        </head>
        <body>
            <div id="swagger-ui"></div>
            <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
            <script>
                SwaggerUIBundle({ url: "\(specPath)", dom_id: '#swagger-ui' });
            </script>
        </body>
        </html>
        """
    }
}
