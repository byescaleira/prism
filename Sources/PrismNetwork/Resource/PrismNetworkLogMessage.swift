//
//  PrismNetworkLogMessage.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/07/25.
//

import Foundation
import PrismFoundation

enum PrismNetworkLogMessage: PrismResourceLogMessage {
    case url(URL)
    case headers([String: String])
    case body(String)
    case host(String)
    case port(UInt16)
    case parameters(String)
    case requestStart(String?)
    case cacheHit(String?)
    case cacheMiss(String?, String)
    case responseCached(String?)
    case noCache(String?)
    case cacheWithExpiration(String?, TimeInterval)
    case noCacheInterval(String?)
    case cacheStored(String?, TimeInterval)
    case invalidURL(String)
    case connecting(String, String, String)
    case connectionEstablished(String, String)
    case connectionClosed(String, String)
    case disconnected(String, String)
    case connectionReady
    case connectionCancelled
    case connectionFailed(String)
    case connectionStateChanged(String?)
    case receiveError(String)
    case receptionComplete
    case failedToEncode(String)
    case sendingMessage(String)
    case messageSent(String)
    case sendError(String)

    var key: String {
        switch self {
        case .url: return "log.url"
        case .headers: return "log.headers"
        case .body: return "log.body"
        case .host: return "log.host"
        case .port: return "log.port"
        case .parameters: return "log.parameters"
        case .requestStart: return "log.requestStart"
        case .cacheHit: return "log.cacheHit"
        case .cacheMiss: return "log.cacheMiss"
        case .responseCached: return "log.responseCached"
        case .noCache: return "log.noCache"
        case .cacheWithExpiration: return "log.cacheWithExpiration"
        case .noCacheInterval: return "log.noCacheInterval"
        case .cacheStored: return "log.cacheStored"
        case .invalidURL: return "log.invalidURL"
        case .connecting: return "log.connecting"
        case .connectionEstablished: return "log.connectionEstablished"
        case .connectionClosed: return "log.connectionClosed"
        case .disconnected: return "log.disconnected"
        case .connectionReady: return "log.connectionReady"
        case .connectionCancelled: return "log.connectionCancelled"
        case .connectionFailed: return "log.connectionFailed"
        case .connectionStateChanged: return "log.connectionStateChanged"
        case .receiveError: return "log.receiveError"
        case .receptionComplete: return "log.receptionComplete"
        case .failedToEncode: return "log.failedToEncode"
        case .sendingMessage: return "log.sendingMessage"
        case .messageSent: return "log.messageSent"
        case .sendError: return "log.sendError"
        }
    }

    var format: String {
        String(
            localized: .init(key),
            table: "PrismNetworkLogMessage",
            bundle: .module,
            locale: PrismLocale.current.rawValue
        )
    }

    func formatted(with arguments: CVarArg...) -> String {
        String(format: format, arguments)
    }

    var value: String {
        switch self {
        case .url(let url): return formatted(with: url.absoluteString)
        case .headers(let headers): return formatted(with: headers.description)
        case .body(let body): return formatted(with: body)
        case .host(let host): return formatted(with: host)
        case .port(let port): return formatted(with: "\(port)")
        case .parameters(let params): return formatted(with: params)
        case .requestStart(let url): return formatted(with: url ?? "")
        case .cacheHit(let key): return formatted(with: key ?? "")
        case .cacheMiss(let key, let error): return formatted(with: key ?? "", error)
        case .responseCached(let url): return formatted(with: url ?? "")
        case .noCache(let url): return formatted(with: url ?? "")
        case .cacheWithExpiration(let url, let expiration): return formatted(with: url ?? "", expiration.description)
        case .noCacheInterval(let url): return formatted(with: url ?? "")
        case .cacheStored(let url, let interval): return formatted(with: url ?? "", interval)
        case .invalidURL(let url): return formatted(with: url)
        case .connecting(let host, let port, let params): return formatted(with: host, port, params)
        case .connectionEstablished(let host, let port): return formatted(with: host, port)
        case .connectionClosed(let host, let port): return formatted(with: host, port)
        case .disconnected(let host, let port): return formatted(with: host, port)
        case .connectionReady: return format
        case .connectionCancelled: return format
        case .connectionFailed(let error): return formatted(with: error)
        case .connectionStateChanged(let state): return formatted(with: state ?? "")
        case .receiveError(let error): return formatted(with: error)
        case .receptionComplete: return format
        case .failedToEncode(let message): return formatted(with: message)
        case .sendingMessage(let message): return formatted(with: message)
        case .messageSent(let message): return formatted(with: message)
        case .sendError(let error): return formatted(with: error)
        }
    }
}
