//
//  PrismNetworkClient.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/03/25.
//

import Foundation
import PrismFoundation

public protocol PrismNetworkClient: Sendable {
    func request<Request: PrismNetworkRequest>(
        on request: Request,
        with formatter: DateFormatter?
    ) async throws -> Request.Response

    func redirect<Request: PrismNetworkRequest>(
        from request: Request
    ) async throws -> URL
}

extension PrismNetworkClient {
    public func request<Request: PrismNetworkRequest>(
        on request: Request
    ) async throws -> Request.Response {
        try await self.request(
            on: request,
            with: nil
        )
    }
}
