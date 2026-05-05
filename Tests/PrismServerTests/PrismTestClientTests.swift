import Foundation
import Testing

@testable import PrismServer

@Suite("PrismTestClient Tests")
struct PrismTestClientTests {

    @Test("GET request through test client")
    func getRequest() async throws {
        let client = PrismTestClientBuilder()
            .get("/health") { _ in .text("ok") }
            .build()

        let response = try await client.get("/health")
        #expect(response.status == .ok)
        #expect(response.body.data == Data("ok".utf8))
    }

    @Test("POST with JSON body")
    func postJSON() async throws {
        struct Item: Codable { let name: String }

        let client = PrismTestClientBuilder()
            .post("/items") { req in
                let item = try req.decodeJSON(Item.self)
                return .json(item, status: .created)
            }
            .build()

        let response = try await client.postJSON("/items", body: Item(name: "Widget"))
        #expect(response.status == .created)
    }

    @Test("404 for unregistered route")
    func notFound() async throws {
        let client = PrismTestClientBuilder().build()
        let response = try await client.get("/missing")
        #expect(response.status == .notFound)
    }

    @Test("Middleware applied in test client")
    func middleware() async throws {
        struct TagMiddleware: PrismMiddleware {
            func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws
                -> PrismHTTPResponse
            {
                var response = try await next(request)
                response.headers.set(name: "X-Tag", value: "test")
                return response
            }
        }

        let client = PrismTestClientBuilder()
            .use(TagMiddleware())
            .get("/tagged") { _ in .text("ok") }
            .build()

        let response = try await client.get("/tagged")
        #expect(response.headers.value(for: "X-Tag") == "test")
    }

    @Test("PUT request")
    func putRequest() async throws {
        let client = PrismTestClientBuilder()
            .route(.PUT, "/items/1") { req in
                .text(req.bodyString ?? "empty")
            }
            .build()

        let response = try await client.put("/items/1", body: Data("updated".utf8))
        #expect(response.body.data == Data("updated".utf8))
    }

    @Test("DELETE request")
    func deleteRequest() async throws {
        let client = PrismTestClientBuilder()
            .route(.DELETE, "/items/1") { _ in
                PrismHTTPResponse.noContent
            }
            .build()

        let response = try await client.delete("/items/1")
        #expect(response.status == .noContent)
    }

    @Test("PATCH request")
    func patchRequest() async throws {
        let client = PrismTestClientBuilder()
            .route(.PATCH, "/items/1") { _ in .text("patched") }
            .build()

        let response = try await client.patch("/items/1")
        #expect(response.body.data == Data("patched".utf8))
    }
}

@Suite("PrismHTTPError Tests")
struct PrismHTTPErrorTests {

    @Test("Error cases exist")
    func errorCases() {
        let errors: [PrismHTTPError] = [
            .bindFailed("port in use"),
            .connectionFailed("refused"),
            .parsingFailed("bad request"),
            .timeout,
            .serverAlreadyRunning,
            .serverNotRunning,
            .tlsConfigurationFailed("no cert"),
            .webSocketUpgradeFailed,
            .fileMissing("/path"),
        ]
        #expect(errors.count == 9)
    }
}
