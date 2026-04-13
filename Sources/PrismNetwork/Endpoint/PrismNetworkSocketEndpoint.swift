//
//  PrismNetworkSocketEndpoint.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import Network
import PrismFoundation

public protocol PrismNetworkSocketEndpoint: PrismLogger, Sendable {
    var host: NWEndpoint.Host { get }
    var port: NWEndpoint.Port { get throws }
    var parameters: NWParameters { get }
}

extension PrismNetworkSocketEndpoint {
    public func log() {
        let logger = PrismNetworkLogger()
        logger.info(.host(host.debugDescription))

        if let port = try? port {
            logger.info(.port(port.rawValue))
        }

        logger.info(.parameters(parameters.debugDescription))
    }
}
