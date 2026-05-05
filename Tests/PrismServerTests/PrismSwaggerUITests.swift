import Foundation
import Testing

@testable import PrismServer

@Suite("PrismSwaggerUI Tests")
struct PrismSwaggerUITests {

    @Test("Builder generates basic spec")
    func basicSpec() throws {
        let builder = PrismSwaggerBuilder(title: "Test API", version: "1.0.0")
        let spec = builder.generateSpec()
        let info = spec["info"] as? [String: Any]
        #expect(info?["title"] as? String == "Test API")
        #expect(info?["version"] as? String == "1.0.0")
        #expect(spec["openapi"] as? String == "3.1.0")
    }

    @Test("Builder adds server URL")
    func serverURL() throws {
        let builder = PrismSwaggerBuilder(title: "API", serverURL: "https://api.example.com")
        let spec = builder.generateSpec()
        let servers = spec["servers"] as? [[String: Any]]
        #expect(servers?.first?["url"] as? String == "https://api.example.com")
    }

    @Test("Builder adds routes with metadata")
    func routeMetadata() throws {
        let metadata = PrismRouteMetadata(
            summary: "List users",
            description: "Get all users",
            tags: ["Users"]
        )
        let builder = PrismSwaggerBuilder(title: "API")
            .adding(method: "GET", path: "/users", metadata: metadata)
        let spec = builder.generateSpec()
        let paths = spec["paths"] as? [String: Any]
        let usersPath = paths?["/users"] as? [String: Any]
        let getOp = usersPath?["get"] as? [String: Any]
        #expect(getOp?["summary"] as? String == "List users")
        #expect(getOp?["description"] as? String == "Get all users")
    }

    @Test("Path parameters converted to OpenAPI format")
    func pathParams() throws {
        let metadata = PrismRouteMetadata(summary: "Get user")
        let builder = PrismSwaggerBuilder(title: "API")
            .adding(method: "GET", path: "/users/:id", metadata: metadata)
        let spec = builder.generateSpec()
        let paths = spec["paths"] as? [String: Any]
        #expect(paths?["/users/{id}"] != nil)
    }

    @Test("Tags collected from routes")
    func tagsCollection() throws {
        let m1 = PrismRouteMetadata(tags: ["Users"])
        let m2 = PrismRouteMetadata(tags: ["Products"])
        let builder = PrismSwaggerBuilder(title: "API")
            .adding(method: "GET", path: "/users", metadata: m1)
            .adding(method: "GET", path: "/products", metadata: m2)
        let spec = builder.generateSpec()
        let tags = spec["tags"] as? [[String: Any]]
        let tagNames = tags?.compactMap { $0["name"] as? String } ?? []
        #expect(tagNames.contains("Users"))
        #expect(tagNames.contains("Products"))
    }

    @Test("Request body schema generated")
    func requestBody() throws {
        let schema = PrismOpenAPISchema.object(
            [
                ("name", .string("User name")),
                ("email", .string("Email address")),
            ], required: ["name", "email"])
        let metadata = PrismRouteMetadata(requestBody: schema)
        let builder = PrismSwaggerBuilder(title: "API")
            .adding(method: "POST", path: "/users", metadata: metadata)
        let spec = builder.generateSpec()
        let paths = spec["paths"] as? [String: Any]
        let usersPath = paths?["/users"] as? [String: Any]
        let postOp = usersPath?["post"] as? [String: Any]
        let body = postOp?["requestBody"] as? [String: Any]
        #expect(body?["required"] as? Bool == true)
    }

    @Test("Response specs generated")
    func responseSpecs() throws {
        let resp = PrismOpenAPIResponseSpec(statusCode: 200, description: "Success")
        let metadata = PrismRouteMetadata(responses: [resp])
        let builder = PrismSwaggerBuilder(title: "API")
            .adding(method: "GET", path: "/health", metadata: metadata)
        let spec = builder.generateSpec()
        let paths = spec["paths"] as? [String: Any]
        let healthPath = paths?["/health"] as? [String: Any]
        let getOp = healthPath?["get"] as? [String: Any]
        let responses = getOp?["responses"] as? [String: Any]
        let r200 = responses?["200"] as? [String: Any]
        #expect(r200?["description"] as? String == "Success")
    }

    @Test("Default response when none specified")
    func defaultResponse() throws {
        let metadata = PrismRouteMetadata(summary: "Ping")
        let builder = PrismSwaggerBuilder(title: "API")
            .adding(method: "GET", path: "/ping", metadata: metadata)
        let spec = builder.generateSpec()
        let paths = spec["paths"] as? [String: Any]
        let pingPath = paths?["/ping"] as? [String: Any]
        let getOp = pingPath?["get"] as? [String: Any]
        let responses = getOp?["responses"] as? [String: Any]
        #expect(responses?["200"] != nil)
    }

    @Test("Deprecated route flag")
    func deprecatedRoute() throws {
        let metadata = PrismRouteMetadata(summary: "Old endpoint", deprecated: true)
        let builder = PrismSwaggerBuilder(title: "API")
            .adding(method: "GET", path: "/v1/old", metadata: metadata)
        let spec = builder.generateSpec()
        let paths = spec["paths"] as? [String: Any]
        let oldPath = paths?["/v1/old"] as? [String: Any]
        let getOp = oldPath?["get"] as? [String: Any]
        #expect(getOp?["deprecated"] as? Bool == true)
    }

    @Test("Parameters in operation")
    func operationParams() throws {
        let param = PrismOpenAPIParameter(name: "id", in: .path, description: "User ID", type: .integer)
        let metadata = PrismRouteMetadata(parameters: [param])
        let builder = PrismSwaggerBuilder(title: "API")
            .adding(method: "GET", path: "/users/:id", metadata: metadata)
        let spec = builder.generateSpec()
        let paths = spec["paths"] as? [String: Any]
        let usersPath = paths?["/users/{id}"] as? [String: Any]
        let getOp = usersPath?["get"] as? [String: Any]
        let params = getOp?["parameters"] as? [[String: Any]]
        #expect(params?.first?["name"] as? String == "id")
        #expect(params?.first?["in"] as? String == "path")
    }

    @Test("JSON generation")
    func jsonGeneration() throws {
        let builder = PrismSwaggerBuilder(title: "Test", version: "2.0.0")
        let data = try builder.generateJSON()
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let info = json?["info"] as? [String: Any]
        #expect(info?["title"] as? String == "Test")
    }

    @Test("OpenAPI schema object")
    func schemaObject() {
        let schema = PrismOpenAPISchema.object(
            [
                ("name", .string()),
                ("age", .integer()),
            ], required: ["name"])
        let dict = schema.toDict()
        #expect(dict["type"] as? String == "object")
        let props = dict["properties"] as? [String: Any]
        #expect(props?["name"] != nil)
        let req = dict["required"] as? [String]
        #expect(req?.contains("name") == true)
    }

    @Test("OpenAPI schema array")
    func schemaArray() {
        let schema = PrismOpenAPISchema.array(of: .string(), description: "List of names")
        let dict = schema.toDict()
        #expect(dict["type"] as? String == "array")
        #expect(dict["description"] as? String == "List of names")
    }

    @Test("Property with enum values")
    func propertyEnum() {
        let prop = PrismOpenAPIProperty(type: .string, enumValues: ["admin", "user", "guest"])
        let dict = prop.toDict()
        let vals = dict["enum"] as? [String]
        #expect(vals == ["admin", "user", "guest"])
    }

    @Test("Swagger UI middleware serves HTML")
    func swaggerUIMiddleware() async throws {
        let middleware = PrismSwaggerUIMiddleware(
            path: "/docs",
            specPath: "/openapi.json",
            specProvider: { ["openapi": "3.1.0"] }
        )
        let request = PrismHTTPRequest(method: .GET, uri: "/docs")
        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }
        #expect(response.status == .ok)
        let bodyStr = String(data: response.body.data, encoding: .utf8) ?? ""
        #expect(bodyStr.contains("swagger-ui"))
    }

    @Test("Swagger UI middleware serves spec JSON")
    func swaggerUISpec() async throws {
        let middleware = PrismSwaggerUIMiddleware(
            specProvider: { ["openapi": "3.1.0", "info": ["title": "Test"]] }
        )
        let request = PrismHTTPRequest(method: .GET, uri: "/openapi.json")
        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }
        #expect(response.status == .ok)
        #expect(response.headers.value(for: "Content-Type")?.contains("application/json") == true)
    }

    @Test("Swagger UI middleware passes through other requests")
    func swaggerUIPassthrough() async throws {
        let middleware = PrismSwaggerUIMiddleware(
            specProvider: { [:] }
        )
        let request = PrismHTTPRequest(method: .GET, uri: "/api/users")
        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("ok")
        }
        let bodyStr = String(data: response.body.data, encoding: .utf8) ?? ""
        #expect(bodyStr == "ok")
    }

    @Test("Multiple methods on same path")
    func multipleMethodsSamePath() throws {
        let getMetadata = PrismRouteMetadata(summary: "List users")
        let postMetadata = PrismRouteMetadata(summary: "Create user")
        let builder = PrismSwaggerBuilder(title: "API")
            .adding(method: "GET", path: "/users", metadata: getMetadata)
            .adding(method: "POST", path: "/users", metadata: postMetadata)
        let spec = builder.generateSpec()
        let paths = spec["paths"] as? [String: Any]
        let usersPath = paths?["/users"] as? [String: Any]
        #expect(usersPath?["get"] != nil)
        #expect(usersPath?["post"] != nil)
    }

    @Test("Description in spec info")
    func specDescription() throws {
        let builder = PrismSwaggerBuilder(title: "API", description: "My API docs")
        let spec = builder.generateSpec()
        let info = spec["info"] as? [String: Any]
        #expect(info?["description"] as? String == "My API docs")
    }
}
