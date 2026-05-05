//
//  PrismNetworkEndpoint.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

import Foundation
import PrismFoundation

/// A protocol that defines type-safe HTTP endpoints.
public protocol PrismNetworkEndpoint: PrismLogger, Sendable {
    /// The URL scheme (e.g., `.https`). Defaults to `.https`.
    var scheme: PrismNetworkScheme { get }
    /// The host component of the URL (e.g., `"api.example.com"`).
    var host: String { get }
    /// The path component of the URL (e.g., `"/v1/users"`).
    var path: String { get }
    /// The HTTP method for this endpoint. Defaults to `.get`.
    var method: PrismNetworkMethod { get }
    /// Optional query parameters appended to the URL.
    var queryItems: [URLQueryItem]? { get }
    /// HTTP headers to include in the request. Defaults to an empty dictionary.
    var headers: [String: String] { get }
    /// An optional encodable body to send with the request.
    var body: (any Encodable)? { get }
    /// An optional request timeout interval in seconds.
    var timeoutInterval: TimeInterval? { get }
    /// An optional cache duration in seconds. Only applies to GET requests.
    var cacheInterval: TimeInterval? { get }
}

extension PrismNetworkEndpoint {
    /// Defaults to `.https`.
    public var scheme: PrismNetworkScheme { .https }
    /// Defaults to `.get`.
    public var method: PrismNetworkMethod { .get }
    /// Defaults to `nil` (no query parameters).
    public var queryItems: [URLQueryItem]? { nil }
    /// Defaults to an empty dictionary.
    public var headers: [String: String] { [:] }
    /// Defaults to `nil` (no request body).
    public var body: (any Encodable)? { nil }
    /// Defaults to `nil` (uses the system default timeout).
    public var timeoutInterval: TimeInterval? { nil }
    /// Defaults to `nil` (no caching).
    public var cacheInterval: TimeInterval? { nil }

    /// The fully constructed URL derived from `scheme`, `host`, `path`, and `queryItems`.
    ///
    /// - Throws: ``PrismNetworkError/invalidURL`` if the URL cannot be constructed.
    public var url: URL {
        get throws {
            guard let url = urlComponents.url else {
                let error = PrismNetworkError.invalidURL
                error.log()
                throw error
            }
            return url
        }
    }

    private var urlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme.rawValue
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems =
            queryItems?.isEmpty == true
            ? nil
            : queryItems
        return urlComponents
    }

    /// A configured `URLRequest` built from this endpoint's properties.
    ///
    /// - Throws: ``PrismNetworkError/invalidURL`` if the URL cannot be constructed.
    public var request: URLRequest {
        get throws {
            log()
            let cachePolicy: URLRequest.CachePolicy =
                method == .get && cacheInterval != nil
                ? .returnCacheDataElseLoad
                : .reloadIgnoringLocalCacheData

            var urlRequest = try URLRequest(
                url: url,
                cachePolicy: cachePolicy
            )
            urlRequest.httpMethod = method.rawValue
            urlRequest.allHTTPHeaderFields = headers
            urlRequest.timeoutInterval = timeoutInterval ?? urlRequest.timeoutInterval

            if let body = (body as? String)?.data(using: .utf8) {
                urlRequest.httpBody = body
            } else if let body = try body?.data() {
                urlRequest.httpBody = body
            }

            return urlRequest
        }
    }

    /// Logs the endpoint's URL, headers, and body using the network logger.
    public func log() {
        let logger = PrismNetworkLogger()
        if let url = try? url {
            logger.info(.url(url))
        }

        if !headers.isEmpty {
            logger.info(.headers(headers))
        }

        if let body = try? body?.json {
            logger.info(.body(body))
        }
    }
}
