//
//  PrismNetworkSocketCommand.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/06/25.
//

public protocol PrismNetworkSocketCommand: Sendable {
    var message: String { get }
}
