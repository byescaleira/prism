import Foundation
import Testing

@testable import PrismNetwork

struct PrismNetworkEndpointTests {
    struct DefaultEndpoint: PrismNetworkEndpoint {
        let host = "default.example.com"
        let path = "/defaults"
    }

    @Test
    func requestBuildsURLRequestWithEncodableBodyAndTimeout() throws {
        let endpoint = NetworkFixtureEndpoint(
            host: "api.example.com",
            path: "/search",
            method: .post,
            queryItems: [
                URLQueryItem(
                    name: "page",
                    value: "1"
                )
            ],
            headers: [
                "Accept": PrismNetworkHeaderType.json.rawValue
            ],
            requestBody: .payload(NetworkFixturePayload(query: "prism")),
            timeoutInterval: 12,
            cacheInterval: 60
        )
        let request = try endpoint.request

        #expect(request.url?.absoluteString == "https://api.example.com/search?page=1")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.timeoutInterval == 12)
        #expect(request.cachePolicy == .reloadIgnoringLocalCacheData)
        #expect(request.httpBody?.isEmpty == false)
    }

    @Test
    func requestSupportsStringBodyAndGetCachePolicy() throws {
        let endpoint = NetworkFixtureEndpoint(
            path: "/stream",
            headers: [
                "Content-Type": PrismNetworkHeaderType.plainText.rawValue
            ],
            requestBody: .text("PING"),
            cacheInterval: 30
        )
        let request = try endpoint.request

        #expect(request.cachePolicy == .returnCacheDataElseLoad)
        #expect(request.httpBody == Data("PING".utf8))
    }

    @Test
    func invalidURLThrowsNetworkError() {
        let endpoint = NetworkFixtureEndpoint(
            host: "",
            path: "not-valid"
        )

        do {
            _ = try endpoint.url
            #expect(Bool(false))
        } catch {
            #expect(error as? PrismNetworkError == .invalidURL)
        }
    }

    @Test
    func endpointDefaultsProvideExpectedValues() throws {
        let endpoint = DefaultEndpoint()
        let request = try endpoint.request

        #expect(endpoint.scheme == .https)
        #expect(endpoint.method == .get)
        #expect(endpoint.queryItems == nil)
        #expect(endpoint.headers.isEmpty)
        #expect(endpoint.body == nil)
        #expect(endpoint.timeoutInterval == nil)
        #expect(endpoint.cacheInterval == nil)
        #expect(request.url?.absoluteString == "https://default.example.com/defaults")
    }

    @Test
    func socketEndpointCanLogAndResolvePort() throws {
        let endpoint = NetworkFixtureSocketEndpoint()

        endpoint.log()

        #expect(try endpoint.port.rawValue == 9_000)
    }
}
