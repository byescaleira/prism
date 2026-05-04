// MARK: - PrismNetwork Endpoint Template
// Usage: Copy, rename, customize.

import PrismNetwork
import PrismFoundation

struct FeatureEndpoint: PrismNetworkEndpoint {
    typealias Response = [Item]

    let path: String = "/api/v1/items"
    let method: PrismHTTPMethod = .get
    let headers: [String: String] = [:]
    let queryItems: [URLQueryItem]
    let body: (any Encodable & Sendable)?

    init(page: Int = 1, limit: Int = 20) {
        self.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]
        self.body = nil
    }
}

// MARK: - Resource

struct FeatureResource: PrismNetworkResource {
    let endpoint: FeatureEndpoint

    init(page: Int = 1) {
        self.endpoint = FeatureEndpoint(page: page)
    }
}
