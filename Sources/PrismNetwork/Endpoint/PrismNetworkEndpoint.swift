//
//  PrismNetworkEndpoint.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

import Foundation
import PrismFoundation

public protocol PrismNetworkEndpoint: PrismLogger, Sendable {
    var scheme: PrismNetworkScheme { get }
    var host: String { get }
    var path: String { get }
    var method: PrismNetworkMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [String: String] { get }
    var body: (any Encodable)? { get }
    var timeoutInterval: TimeInterval? { get }
    var cacheInterval: TimeInterval? { get }
}

extension PrismNetworkEndpoint {
    public var scheme: PrismNetworkScheme { .https }
    public var method: PrismNetworkMethod { .get }
    public var queryItems: [URLQueryItem]? { nil }
    public var headers: [String: String] { [:] }
    public var body: (any Encodable)? { nil }
    public var timeoutInterval: TimeInterval? { nil }
    public var cacheInterval: TimeInterval? { nil }

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
