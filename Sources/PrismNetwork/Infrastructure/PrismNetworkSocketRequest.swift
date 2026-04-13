//
//  PrismNetworkSocketRequest.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import PrismFoundation

public protocol PrismNetworkSocketRequest: Sendable {
    var endpoint: (any PrismNetworkSocketEndpoint)? { get }
}
