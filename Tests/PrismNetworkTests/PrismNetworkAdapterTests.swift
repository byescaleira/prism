import Foundation
import Testing

@testable import PrismNetwork

@Suite(.serialized)
struct PrismNetworkAdapterTests {
    @Test
    func requestDecodesNetworkResponseAndStoresCache() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return .response(
                response,
                try responseData()
            )
        }

        let cache = URLCache(
            memoryCapacity: 1_024 * 1_024,
            diskCapacity: 1_024 * 1_024
        )
        let adapter = makeNetworkAdapter(cache: cache)
        let request = NetworkFixtureRequest(
            endpoint: NetworkFixtureEndpoint(cacheInterval: 60)
        )
        let response = try await adapter.request(on: request)

        #expect(response == NetworkFixtureResponse(id: 1, title: "Prism"))
        #expect(MockURLProtocol.requestCount == 1)
        #expect(cache.cachedResponse(for: try request.endpoint.request) != nil)
    }

    @Test
    func validCacheBypassesTheNetwork() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return .response(
                response,
                try responseData(title: "unexpected")
            )
        }

        let cache = URLCache(
            memoryCapacity: 1_024 * 1_024,
            diskCapacity: 1_024 * 1_024
        )
        let adapter = makeNetworkAdapter(cache: cache)
        let request = NetworkFixtureRequest(
            endpoint: NetworkFixtureEndpoint(cacheInterval: 60)
        )
        let urlRequest = try request.endpoint.request
        let cachedResponse = CachedURLResponse(
            response: HTTPURLResponse(
                url: try #require(urlRequest.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!,
            data: try responseData(title: "cached"),
            userInfo: [
                "prism.network.cache.expiration": Date.now.timeIntervalSince1970 + 60
            ],
            storagePolicy: .allowed
        )

        cache.storeCachedResponse(
            cachedResponse,
            for: urlRequest
        )

        let response = try await adapter.request(on: request)

        #expect(response.title == "cached")
        #expect(MockURLProtocol.requestCount == 0)
    }

    @Test
    func corruptedOrExpiredCacheFallsBackToTheNetwork() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return .response(
                response,
                try responseData(title: "fresh")
            )
        }

        let cache = URLCache(
            memoryCapacity: 1_024 * 1_024,
            diskCapacity: 1_024 * 1_024
        )
        let adapter = makeNetworkAdapter(cache: cache)
        let request = NetworkFixtureRequest(
            endpoint: NetworkFixtureEndpoint(cacheInterval: 60)
        )
        let urlRequest = try request.endpoint.request

        cache.storeCachedResponse(
            CachedURLResponse(
                response: HTTPURLResponse(
                    url: try #require(urlRequest.url),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                data: Data("invalid".utf8),
                userInfo: [
                    "prism.network.cache.expiration": Date.now.timeIntervalSince1970 + 60
                ],
                storagePolicy: .allowed
            ),
            for: urlRequest
        )

        let corruptedResponse = try await adapter.request(on: request)

        cache.storeCachedResponse(
            CachedURLResponse(
                response: HTTPURLResponse(
                    url: try #require(urlRequest.url),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                data: try responseData(title: "stale"),
                userInfo: [
                    "prism.network.cache.expiration": Date.now.timeIntervalSince1970 - 1
                ],
                storagePolicy: .allowed
            ),
            for: urlRequest
        )

        let expiredResponse = try await adapter.request(on: request)

        #expect(corruptedResponse.title == "fresh")
        #expect(expiredResponse.title == "fresh")
        #expect(MockURLProtocol.requestCount == 2)
    }

    @Test
    func requestMapsStatusCodeAndConnectivityErrors() async {
        let adapter = makeNetworkAdapter()

        MockURLProtocol.reset()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!

            return .response(
                response,
                try responseData()
            )
        }

        do {
            _ = try await adapter.request(
                on: NetworkFixtureRequest(endpoint: NetworkFixtureEndpoint())
            )
            #expect(Bool(false))
        } catch {
            #expect(error as? PrismNetworkError == .unauthorized)
        }

        MockURLProtocol.requestHandler = { _ in
            .failure(URLError(.notConnectedToInternet))
        }

        do {
            _ = try await adapter.request(
                on: NetworkFixtureRequest(endpoint: NetworkFixtureEndpoint())
            )
            #expect(Bool(false))
        } catch {
            #expect(error as? PrismNetworkError == .noConnectivity)
        }
    }

    @Test
    func redirectReturnsLocationHeaderAndFailsWhenMissing() async throws {
        let adapter = makeNetworkAdapter()

        MockURLProtocol.reset()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 302,
                httpVersion: nil,
                headerFields: [
                    "Location": "/redirected"
                ]
            )!

            return .response(
                response,
                Data()
            )
        }

        let redirectedURL = try await adapter.redirect(
            from: NetworkFixtureRequest(endpoint: NetworkFixtureEndpoint())
        )

        #expect(redirectedURL.absoluteString == "https://example.com/redirected")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return .response(
                response,
                Data()
            )
        }

        do {
            _ = try await adapter.redirect(
                from: NetworkFixtureRequest(endpoint: NetworkFixtureEndpoint())
            )
            #expect(Bool(false))
        } catch {
            #expect(error as? PrismNetworkError == .invalidResponse)
        }
    }

    @Test
    func requestWithoutCacheIntervalDoesNotStoreCacheAndRejectsNonHTTPResponses() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.requestHandler = { request in
            .response(
                URLResponse(
                    url: try #require(request.url),
                    mimeType: "application/json",
                    expectedContentLength: 0,
                    textEncodingName: nil
                ),
                Data()
            )
        }

        let cache = URLCache(
            memoryCapacity: 1_024 * 1_024,
            diskCapacity: 1_024 * 1_024
        )
        let adapter = makeNetworkAdapter(cache: cache)
        let request = NetworkFixtureRequest(
            endpoint: NetworkFixtureEndpoint(cacheInterval: nil)
        )

        do {
            _ = try await adapter.request(on: request)
            #expect(Bool(false))
        } catch {
            #expect(error as? PrismNetworkError == .invalidResponse)
        }

        #expect(cache.cachedResponse(for: try request.endpoint.request) == nil)
    }

    @Test
    func requestWithoutCacheIntervalCanSucceedWithoutPersistingData() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return .response(
                response,
                try responseData(title: "fresh-no-cache")
            )
        }

        let cache = URLCache(
            memoryCapacity: 1_024 * 1_024,
            diskCapacity: 1_024 * 1_024
        )
        let adapter = makeNetworkAdapter(cache: cache)
        let request = NetworkFixtureRequest(
            endpoint: NetworkFixtureEndpoint(cacheInterval: nil)
        )

        let response = try await adapter.request(on: request)

        #expect(response.title == "fresh-no-cache")
        #expect(cache.cachedResponse(for: try request.endpoint.request) == nil)
    }

    @Test
    func redirectCanUseCapturedDelegateURL() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 302,
                httpVersion: nil,
                headerFields: nil
            )!

            return .redirect(
                response,
                URLRequest(
                    url: URL(string: "https://example.com/captured")!
                )
            )
        }

        let adapter = makeNetworkAdapter()
        let redirectedURL = try await adapter.redirect(
            from: NetworkFixtureRequest(endpoint: NetworkFixtureEndpoint())
        )

        #expect(redirectedURL.absoluteString == "https://example.com/captured")
    }

    @Test
    func redirectMapsTransportErrorsAndRejectsInvalidRedirectTargets() async {
        let adapter = makeNetworkAdapter()

        MockURLProtocol.reset()
        MockURLProtocol.requestHandler = { _ in
            .failure(URLError(.cannotFindHost))
        }

        do {
            _ = try await adapter.redirect(
                from: NetworkFixtureRequest(endpoint: NetworkFixtureEndpoint())
            )
            #expect(Bool(false))
        } catch {
            #expect(error as? PrismNetworkError == .noConnectivity)
        }

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 302,
                httpVersion: nil,
                headerFields: [
                    "Location": "http://[::1"
                ]
            )!

            return .response(
                response,
                Data()
            )
        }

        do {
            _ = try await adapter.redirect(
                from: NetworkFixtureRequest(endpoint: NetworkFixtureEndpoint())
            )
            #expect(Bool(false))
        } catch {
            #expect(error as? PrismNetworkError == .invalidResponse)
        }
    }
}
