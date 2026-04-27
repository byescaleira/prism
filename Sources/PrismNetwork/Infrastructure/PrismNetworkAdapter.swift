//
//  PrismNetworkAdapter.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/04/25.
//

import Foundation
import PrismFoundation

private enum PrismNetworkCacheMetadata {
    static let expirationKey = "prism.network.cache.expiration"
}

/// Thread-safe: `redirectURL` is guarded by `NSLock`.
private final class PrismNetworkRedirectCaptureDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    private let lock = NSLock()
    private var redirectURL: URL?

    func capturedURL() -> URL? {
        lock.withLock {
            redirectURL
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        lock.withLock {
            redirectURL = request.url
        }
        task.cancel()
        return nil
    }
}

/// A thread-safe HTTP adapter built on URLSession with cache and redirect support.
public actor PrismNetworkAdapter: PrismNetworkClient {
    private let session: URLSession
    private let sessionConfiguration: URLSessionConfiguration
    private let cache: URLCache

    /// Creates a new network adapter with the given session configuration and cache.
    ///
    /// - Parameters:
    ///   - configuration: The URL session configuration to use. Defaults to `.default`.
    ///   - cache: The URL cache for storing responses. Defaults to `.shared`.
    public init(
        configuration: URLSessionConfiguration = .default,
        cache: URLCache = .shared
    ) {
        let configuration = (configuration.copy() as? URLSessionConfiguration) ?? .default
        configuration.urlCache = cache
        self.sessionConfiguration = configuration
        self.cache = cache
        self.session = URLSession(configuration: configuration)
    }

    /// Executes an HTTP request, returning cached data when available or fetching from the network.
    ///
    /// - Parameters:
    ///   - request: The type-safe request to perform.
    ///   - formatter: An optional date formatter used for decoding the response.
    /// - Returns: The decoded response matching the request's associated `Response` type.
    /// - Throws: ``PrismNetworkError`` if the request fails or the response is invalid.
    public func request<Request>(
        on request: Request,
        with formatter: DateFormatter?
    ) async throws -> Request.Response where Request: PrismNetworkRequest {
        let endpoint = request.endpoint
        let urlRequest = try endpoint.request
        let logger = PrismNetworkLogger()
        logger.info(.requestStart(urlRequest.url?.absoluteString))

        do {
            let cachedData = try retrieveCachedData(
                for: endpoint,
                request: urlRequest
            )
            logger.info(.cacheHit(urlRequest.url?.absoluteString))

            do {
                return try request.decode(
                    data: cachedData,
                    with: formatter
                )
            } catch {
                cache.removeCachedResponse(for: urlRequest)
                logger.warning(
                    .cacheMiss(
                        urlRequest.url?.absoluteString,
                        error.localizedDescription
                    ))
            }
        } catch {
            logger.warning(
                .cacheMiss(
                    urlRequest.url?.absoluteString,
                    error.localizedDescription
                ))
        }

        let (data, response) = try await fetchData(for: urlRequest)
        let httpResponse = try validate(response)
        try storeCache(
            for: endpoint,
            request: urlRequest,
            data: data,
            response: httpResponse
        )
        return try request.decode(
            data: data,
            with: formatter
        )
    }

    /// Follows an HTTP redirect and returns the final destination URL without downloading the body.
    ///
    /// - Parameter request: The request whose endpoint may trigger a redirect.
    /// - Returns: The redirect destination URL.
    /// - Throws: ``PrismNetworkError/invalidResponse`` if no redirect is found.
    public func redirect<Request: PrismNetworkRequest>(
        from request: Request
    ) async throws -> URL {
        let delegate = PrismNetworkRedirectCaptureDelegate()
        let session = URLSession(
            configuration: sessionConfiguration,
            delegate: delegate,
            delegateQueue: nil
        )
        let urlRequest = try request.endpoint.request

        defer {
            session.invalidateAndCancel()
        }

        do {
            let (_, response) = try await session.data(for: urlRequest)
            if let url = redirectURL(
                from: response,
                originalURL: urlRequest.url
            ) {
                return url
            }
        } catch {
            if let url = delegate.capturedURL() {
                return url
            }

            throw PrismNetworkError.from(error: error)
        }

        throw PrismNetworkError.invalidResponse
    }

    private func retrieveCachedData(
        for endpoint: some PrismNetworkEndpoint,
        request urlRequest: URLRequest
    ) throws -> Data {
        let logger = PrismNetworkLogger()

        guard endpoint.method == .get,
            endpoint.cacheInterval != nil,
            let cacheResponse = cache.cachedResponse(for: urlRequest),
            let expiration = cacheResponse.userInfo?[PrismNetworkCacheMetadata.expirationKey] as? TimeInterval
        else {
            throw PrismNetworkError.noCache
        }

        guard expiration > Date.now.timeIntervalSince1970 else {
            cache.removeCachedResponse(for: urlRequest)
            throw PrismNetworkError.noCache
        }

        logger.info(
            .cacheWithExpiration(
                urlRequest.url?.absoluteString,
                expiration
            ))

        return cacheResponse.data
    }

    private func storeCache(
        for endpoint: some PrismNetworkEndpoint,
        request urlRequest: URLRequest,
        data: Data,
        response: HTTPURLResponse
    ) throws {
        let logger = PrismNetworkLogger()

        guard endpoint.method == .get,
            let cacheInterval = endpoint.cacheInterval
        else {
            logger.info(.noCacheInterval(urlRequest.url?.absoluteString))
            return
        }

        let expiration = Date.now.timeIntervalSince1970 + cacheInterval
        let userInfo: [String: TimeInterval] = [PrismNetworkCacheMetadata.expirationKey: expiration]
        let cacheResponse = CachedURLResponse(
            response: response,
            data: data,
            userInfo: userInfo,
            storagePolicy: .allowed
        )

        cache.storeCachedResponse(
            cacheResponse,
            for: urlRequest
        )
        logger.info(
            .cacheStored(
                urlRequest.url?.absoluteString,
                expiration
            ))
    }

    private func fetchData(
        for urlRequest: URLRequest
    ) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: urlRequest)
        } catch {
            throw PrismNetworkError.from(error: error)
        }
    }

    private func validate(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PrismNetworkError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw PrismNetworkError.from(statusCode: httpResponse.statusCode)
        }

        return httpResponse
    }

    private func redirectURL(
        from response: URLResponse,
        originalURL: URL?
    ) -> URL? {
        guard let httpResponse = response as? HTTPURLResponse,
            let location = httpResponse.value(forHTTPHeaderField: "Location")
        else {
            return nil
        }

        if let url = URL(
            string: location,
            relativeTo: originalURL
        ) {
            return url.absoluteURL
        }

        return nil
    }
}
