//
//  PrismNetworkRequest.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/03/25.
//

import Foundation
import PrismFoundation

public protocol PrismNetworkRequest: Sendable {
    associatedtype Endpoint: PrismNetworkEndpoint
    associatedtype Response: PrismEntity & Sendable

    var endpoint: Endpoint { get }

    func decode(
        data: Data,
        with formatter: DateFormatter?
    ) throws -> Response
}

extension PrismNetworkRequest {
    public func decode(
        data: Data,
        with formatter: DateFormatter?
    ) throws -> Response {
        let decoded = try data.entity(
            for: Response.self,
            with: formatter
        )
        decoded.log()
        return decoded
    }
}
