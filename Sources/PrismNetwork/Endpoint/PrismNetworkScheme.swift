//
//  PrismNetworkScheme.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

public enum PrismNetworkScheme: String, Sendable, CaseIterable {
    case http = "http"
    case https = "https"
    case ws = "ws"
    case wss = "wss"
}
