//
//  PrismNetworkSocketClient.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import PrismFoundation

public protocol PrismNetworkSocketClient: Sendable {
    func send(command: PrismNetworkSocketCommand) async throws
    func connect(
        to endpoint: any PrismNetworkSocketEndpoint
    ) async throws -> AsyncStream<Data>
}

extension PrismNetworkSocketClient {
    public func connect<Request: PrismNetworkSocketRequest>(
        with request: Request
    ) async throws -> AsyncStream<Data> {
        guard let endpoint = request.endpoint else {
            throw PrismNetworkError.invalidURL
        }

        return try await connect(to: endpoint)
    }
}
