//
//  PrismGraphQLClient.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// A GraphQL query or mutation with optional variables.
public struct PrismGraphQLQuery: Sendable {
    /// The GraphQL query or mutation string.
    public let query: String
    /// Variables to pass with the query, encoded as JSON-compatible values.
    public let variables: [String: any Sendable]?
    /// An optional operation name when the document contains multiple operations.
    public let operationName: String?

    /// Creates a GraphQL query.
    public init(
        query: String,
        variables: [String: any Sendable]? = nil,
        operationName: String? = nil
    ) {
        self.query = query
        self.variables = variables
        self.operationName = operationName
    }
}

/// A typed GraphQL response with optional errors.
public struct PrismGraphQLResponse<T: Decodable & Sendable>: Sendable {
    /// The decoded data from the GraphQL response.
    public let data: T?
    /// Errors returned by the GraphQL server.
    public let errors: [PrismGraphQLError]?

    /// Creates a GraphQL response.
    public init(data: T? = nil, errors: [PrismGraphQLError]? = nil) {
        self.data = data
        self.errors = errors
    }
}

/// A GraphQL error returned by the server.
public struct PrismGraphQLError: Decodable, Sendable, Equatable {
    /// The error message.
    public let message: String
    /// Source locations in the query where the error occurred.
    public let locations: [PrismGraphQLErrorLocation]?
    /// The response path to the field that caused the error.
    public let path: [String]?

    /// Creates a GraphQL error.
    public init(
        message: String,
        locations: [PrismGraphQLErrorLocation]? = nil,
        path: [String]? = nil
    ) {
        self.message = message
        self.locations = locations
        self.path = path
    }
}

/// A source location within a GraphQL document.
public struct PrismGraphQLErrorLocation: Decodable, Sendable, Equatable {
    /// The line number in the query.
    public let line: Int
    /// The column number in the query.
    public let column: Int

    /// Creates a GraphQL error location.
    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

/// Sends GraphQL queries and mutations, decoding typed responses.
public actor PrismGraphQLClient {
    private let endpointURL: URL
    private let session: URLSession
    private let additionalHeaders: [String: String]

    /// Creates a GraphQL client targeting the given endpoint.
    public init(
        endpointURL: URL,
        session: URLSession = .shared,
        additionalHeaders: [String: String] = [:]
    ) {
        self.endpointURL = endpointURL
        self.session = session
        self.additionalHeaders = additionalHeaders
    }

    /// Executes a GraphQL query and decodes the response.
    public func execute<T: Decodable & Sendable>(
        _ query: PrismGraphQLQuery
    ) async throws -> PrismGraphQLResponse<T> {
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in additionalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        var bodyDict: [String: Any] = ["query": query.query]
        if let operationName = query.operationName {
            bodyDict["operationName"] = operationName
        }
        if let variables = query.variables {
            bodyDict["variables"] = variables
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)

        let (data, _) = try await session.data(for: request)
        let decoded = try JSONDecoder().decode(GraphQLRawResponse<T>.self, from: data)

        return PrismGraphQLResponse(data: decoded.data, errors: decoded.errors)
    }
}

/// Internal raw response matching the GraphQL JSON shape.
private struct GraphQLRawResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [PrismGraphQLError]?
}
