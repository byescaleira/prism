import Testing
import Foundation
@testable import PrismServer

@Suite("PrismOpenAPIGenerator Tests")
struct PrismOpenAPIGeneratorTests {

    @Test("Generates valid OpenAPI 3.0 spec")
    func generateSpec() throws {
        let endpoint = PrismAPIEndpoint(
            method: .GET,
            path: "/users/:id",
            summary: "Get user by ID",
            tags: ["Users"],
            parameters: [
                PrismAPIParameter(name: "id", location: .path, required: true, type: "integer", description: "User ID")
            ],
            responses: [
                PrismAPIResponse(statusCode: 200, description: "Success", contentType: "application/json", schemaRef: "User")
            ]
        )

        let generator = PrismOpenAPIGenerator(
            title: "Test API",
            version: "1.0.0",
            endpoints: [endpoint]
        )

        let spec = generator.generate()
        #expect(spec["openapi"] as? String == "3.0.3")

        let info = spec["info"] as? [String: Any]
        #expect(info?["title"] as? String == "Test API")
    }

    @Test("Generates JSON data")
    func generateJSON() throws {
        let generator = PrismOpenAPIGenerator(
            title: "Test",
            endpoints: [
                PrismAPIEndpoint(method: .GET, path: "/health", summary: "Health check")
            ]
        )

        let data = try generator.generateJSON()
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["openapi"] as? String == "3.0.3")
    }

    @Test("Path parameters converted to OpenAPI format")
    func pathParams() {
        let endpoint = PrismAPIEndpoint(method: .GET, path: "/users/:id/posts/:postId")
        let generator = PrismOpenAPIGenerator(title: "Test", endpoints: [endpoint])
        let spec = generator.generate()
        let paths = spec["paths"] as? [String: Any]
        #expect(paths?.keys.contains("/users/{id}/posts/{postId}") == true)
    }

    @Test("Multiple methods on same path")
    func multipleMethods() {
        let endpoints = [
            PrismAPIEndpoint(method: .GET, path: "/users", summary: "List users"),
            PrismAPIEndpoint(method: .POST, path: "/users", summary: "Create user"),
        ]
        let generator = PrismOpenAPIGenerator(title: "Test", endpoints: endpoints)
        let spec = generator.generate()
        let paths = spec["paths"] as? [String: Any]
        let usersPath = paths?["/users"] as? [String: Any]
        #expect(usersPath?["get"] != nil)
        #expect(usersPath?["post"] != nil)
    }

    @Test("Request body schema ref")
    func requestBody() {
        let endpoint = PrismAPIEndpoint(
            method: .POST,
            path: "/users",
            requestBody: PrismAPIBody(description: "User data", schemaRef: "CreateUser")
        )
        let generator = PrismOpenAPIGenerator(title: "Test", endpoints: [endpoint])
        let spec = generator.generate()
        let paths = spec["paths"] as? [String: Any]
        let post = (paths?["/users"] as? [String: Any])?["post"] as? [String: Any]
        #expect(post?["requestBody"] != nil)
    }

    @Test("Empty endpoint has default 200 response")
    func defaultResponse() {
        let endpoint = PrismAPIEndpoint(method: .GET, path: "/ping")
        let generator = PrismOpenAPIGenerator(title: "Test", endpoints: [endpoint])
        let spec = generator.generate()
        let paths = spec["paths"] as? [String: Any]
        let get = (paths?["/ping"] as? [String: Any])?["get"] as? [String: Any]
        let responses = get?["responses"] as? [String: Any]
        #expect(responses?["200"] != nil)
    }
}

@Suite("PrismAPIEndpoint Tests")
struct PrismAPIEndpointTests {

    @Test("Default values")
    func defaults() {
        let ep = PrismAPIEndpoint(method: .GET, path: "/test")
        #expect(ep.summary.isEmpty)
        #expect(ep.tags.isEmpty)
        #expect(ep.parameters.isEmpty)
        #expect(ep.requestBody == nil)
        #expect(ep.responses.isEmpty)
    }
}

@Suite("PrismAPIParameter Tests")
struct PrismAPIParameterTests {

    @Test("Default values")
    func defaults() {
        let param = PrismAPIParameter(name: "q")
        #expect(param.location == .query)
        #expect(!param.required)
        #expect(param.type == "string")
    }
}

@Suite("PrismServerScaffold Tests")
struct PrismServerScaffoldTests {

    @Test("Package.swift generation")
    func packageSwift() {
        let scaffold = PrismServerScaffold()
        let content = scaffold.packageSwift(name: "MyApp")
        #expect(content.contains("name: \"MyApp\""))
        #expect(content.contains("PrismServer"))
        #expect(content.contains("swift-tools-version: 6.3"))
    }

    @Test("main.swift generation")
    func mainSwift() {
        let scaffold = PrismServerScaffold()
        let content = scaffold.mainSwift(name: "MyApp")
        #expect(content.contains("import PrismServer"))
        #expect(content.contains("PrismHTTPServer"))
    }

    @Test("Dockerfile generation")
    func dockerfile() {
        let scaffold = PrismServerScaffold()
        let content = scaffold.dockerfile(name: "MyApp")
        #expect(content.contains("swift:6.3"))
        #expect(content.contains("EXPOSE 8080"))
    }

    @Test("Generate all files")
    func generateAll() {
        let scaffold = PrismServerScaffold()
        let files = scaffold.generate(name: "TestApp")
        #expect(files.count == 4)
        #expect(files["Package.swift"] != nil)
        #expect(files["Dockerfile"] != nil)
        #expect(files[".gitignore"] != nil)
    }
}
