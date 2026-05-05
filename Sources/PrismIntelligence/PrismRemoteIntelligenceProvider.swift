//
//  PrismRemoteIntelligenceProvider.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation

/// A transport layer that performs HTTP requests for remote intelligence.
///
/// Conform to this protocol to provide a custom networking stack (e.g., for testing).
public protocol PrismRemoteIntelligenceTransport: Sendable {
    /// Sends a URL request and returns the response data.
    ///
    /// - Parameter request: The URL request to send.
    /// - Returns: A tuple of the response data and URL response.
    /// - Throws: An error if the request fails.
    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse)
}

/// A ``PrismRemoteIntelligenceTransport`` backed by `URLSession`.
public struct PrismURLSessionRemoteIntelligenceTransport: PrismRemoteIntelligenceTransport {
    private let session: URLSession

    /// Creates a transport using the given URL session.
    ///
    /// - Parameter session: The URL session. Defaults to `.shared`.
    public init(
        session: URLSession = .shared
    ) {
        self.session = session
    }

    /// Sends a URL request using the underlying session and returns the response data.
    public func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

/// A serializer that converts language requests to URL requests and decodes responses.
///
/// Conform to this protocol to integrate a custom remote API format.
public protocol PrismRemoteIntelligenceSerializer: Sendable {
    /// Builds a `URLRequest` for the given language generation request.
    ///
    /// - Parameter request: The language generation request to serialize.
    /// - Returns: A configured `URLRequest`.
    /// - Throws: An error if serialization fails.
    func makeURLRequest(
        for request: PrismLanguageIntelligenceRequest
    ) throws -> URLRequest

    /// Decodes raw response data into a language intelligence response.
    ///
    /// - Parameters:
    ///   - data: The raw response body.
    ///   - response: The URL response containing status and headers.
    /// - Returns: A ``PrismLanguageIntelligenceResponse``.
    /// - Throws: ``PrismIntelligenceError/invalidResponse(_:)`` or ``PrismIntelligenceError/networkFailure(_:)`` on failure.
    func decodeResponse(
        data: Data,
        response: URLResponse
    ) throws -> PrismLanguageIntelligenceResponse
}

/// A default JSON-based serializer for remote intelligence endpoints.
///
/// Encodes requests as JSON `POST` bodies and decodes responses that contain
/// an `outputText`, `text`, `content`, or `message` field.
public struct PrismDefaultRemoteIntelligenceSerializer: PrismRemoteIntelligenceSerializer {
    /// The remote endpoint URL.
    public var endpoint: URL
    /// An optional model identifier sent in the request payload.
    public var model: String?
    /// A label for the provider, included in response metadata.
    public var providerName: String
    /// Additional HTTP headers included with every request.
    public var headers: [String: String]
    /// The request timeout interval in seconds.
    public var timeout: TimeInterval

    /// Creates a default remote serializer.
    ///
    /// - Parameters:
    ///   - endpoint: The remote endpoint URL.
    ///   - model: An optional model identifier.
    ///   - providerName: A provider label. Defaults to `"remote"`.
    ///   - headers: Additional HTTP headers.
    ///   - timeout: The timeout in seconds. Defaults to 60.
    public init(
        endpoint: URL,
        model: String? = nil,
        providerName: String = "remote",
        headers: [String: String] = [:],
        timeout: TimeInterval = 60
    ) {
        self.endpoint = endpoint
        self.model = model
        self.providerName = providerName
        self.headers = headers
        self.timeout = timeout
    }

    /// Builds a JSON `POST` request for the given language generation request.
    public func makeURLRequest(
        for request: PrismLanguageIntelligenceRequest
    ) throws -> URLRequest {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = timeout
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (header, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: header)
        }

        let payload = Payload(
            model: model,
            prompt: request.prompt,
            systemPrompt: request.systemPrompt,
            context: request.context,
            temperature: request.options.temperature,
            maximumResponseTokens: request.options.maximumResponseTokens,
            metadata: request.metadata
        )
        urlRequest.httpBody = try JSONEncoder().encode(payload)
        return urlRequest
    }

    /// Decodes a JSON response body into a ``PrismLanguageIntelligenceResponse``.
    public func decodeResponse(
        data: Data,
        response: URLResponse
    ) throws -> PrismLanguageIntelligenceResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PrismIntelligenceError.invalidResponse("Response is not HTTP.")
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw PrismIntelligenceError.networkFailure("HTTP \(httpResponse.statusCode)")
        }

        let decoded = try JSONDecoder().decode(
            ResponsePayload.self,
            from: data
        )

        guard !decoded.outputText.isEmpty else {
            throw PrismIntelligenceError.invalidResponse("Missing output text.")
        }

        return PrismLanguageIntelligenceResponse(
            provider: .remote,
            model: decoded.model ?? model,
            content: decoded.outputText,
            finishReason: decoded.finishReason,
            usage: decoded.usage,
            metadata: decoded.metadata.merging(
                ["provider": decoded.provider ?? providerName],
                uniquingKeysWith: { current, _ in current }
            )
        )
    }

    private struct Payload: Codable {
        var model: String?
        var prompt: String
        var systemPrompt: String?
        var context: [String]
        var temperature: Double?
        var maximumResponseTokens: Int?
        var metadata: [String: String]
    }

    private struct ResponsePayload: Decodable {
        let outputText: String
        let model: String?
        let provider: String?
        let finishReason: String?
        let usage: PrismLanguageTokenUsage?
        let metadata: [String: String]

        private enum CodingKeys: String, CodingKey {
            case outputText
            case text
            case content
            case message
            case model
            case provider
            case finishReason
            case usage
            case metadata
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.outputText =
                try container.decodeIfPresent(String.self, forKey: .outputText)
                ?? container.decodeIfPresent(String.self, forKey: .text)
                ?? container.decodeIfPresent(String.self, forKey: .content)
                ?? container.decodeIfPresent(String.self, forKey: .message)
                ?? ""
            self.model = try container.decodeIfPresent(String.self, forKey: .model)
            self.provider = try container.decodeIfPresent(String.self, forKey: .provider)
            self.finishReason = try container.decodeIfPresent(
                String.self,
                forKey: .finishReason
            )
            self.usage = try container.decodeIfPresent(
                PrismLanguageTokenUsage.self,
                forKey: .usage
            )
            self.metadata =
                try container.decodeIfPresent(
                    [String: String].self,
                    forKey: .metadata
                ) ?? [:]
        }
    }
}

/// A language-intelligence provider that delegates to a remote HTTP endpoint.
public struct PrismRemoteIntelligenceProvider: PrismLanguageIntelligenceProvider {
    /// The provider kind, always ``PrismLanguageIntelligenceProviderKind/remote``.
    public let kind: PrismLanguageIntelligenceProviderKind = .remote

    private let serializer: any PrismRemoteIntelligenceSerializer
    private let transport: any PrismRemoteIntelligenceTransport

    /// Creates a remote intelligence provider.
    ///
    /// - Parameters:
    ///   - serializer: The serializer that encodes requests and decodes responses.
    ///   - transport: The networking transport. Defaults to a `URLSession`-backed transport.
    public init(
        serializer: any PrismRemoteIntelligenceSerializer,
        transport: any PrismRemoteIntelligenceTransport = PrismURLSessionRemoteIntelligenceTransport()
    ) {
        self.serializer = serializer
        self.transport = transport
    }

    /// Returns the remote provider status.
    ///
    /// Remote providers are always reported as available; actual connectivity
    /// is checked when a request is made.
    public func status() async -> PrismLanguageIntelligenceStatus {
        PrismLanguageIntelligenceStatus(
            provider: .remote,
            isAvailable: true,
            supportsStreaming: false,
            supportsCustomInstructions: true,
            supportsModelAdapters: false
        )
    }

    /// Generates a response by sending the request to the remote endpoint.
    ///
    /// - Parameter request: The language generation request.
    /// - Returns: A ``PrismLanguageIntelligenceResponse`` decoded from the remote response.
    /// - Throws: ``PrismIntelligenceError/networkFailure(_:)`` or ``PrismIntelligenceError/invalidResponse(_:)`` on failure.
    public func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse {
        let urlRequest = try serializer.makeURLRequest(for: request)

        do {
            let (data, response) = try await transport.data(for: urlRequest)
            return try serializer.decodeResponse(
                data: data,
                response: response
            )
        } catch let error as PrismIntelligenceError {
            throw error
        } catch {
            throw PrismIntelligenceError.networkFailure(
                error.localizedDescription
            )
        }
    }
}
