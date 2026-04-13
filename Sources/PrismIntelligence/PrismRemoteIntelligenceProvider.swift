//
//  PrismRemoteIntelligenceProvider.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation

public protocol PrismRemoteIntelligenceTransport: Sendable {
    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse)
}

public struct PrismURLSessionRemoteIntelligenceTransport: PrismRemoteIntelligenceTransport {
    private let session: URLSession

    public init(
        session: URLSession = .shared
    ) {
        self.session = session
    }

    public func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

public protocol PrismRemoteIntelligenceSerializer: Sendable {
    func makeURLRequest(
        for request: PrismLanguageIntelligenceRequest
    ) throws -> URLRequest

    func decodeResponse(
        data: Data,
        response: URLResponse
    ) throws -> PrismLanguageIntelligenceResponse
}

public struct PrismDefaultRemoteIntelligenceSerializer: PrismRemoteIntelligenceSerializer {
    public var endpoint: URL
    public var model: String?
    public var providerName: String
    public var headers: [String: String]
    public var timeout: TimeInterval

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

public struct PrismRemoteIntelligenceProvider: PrismLanguageIntelligenceProvider {
    public let kind: PrismLanguageIntelligenceProviderKind = .remote

    private let serializer: any PrismRemoteIntelligenceSerializer
    private let transport: any PrismRemoteIntelligenceTransport

    public init(
        serializer: any PrismRemoteIntelligenceSerializer,
        transport: any PrismRemoteIntelligenceTransport = PrismURLSessionRemoteIntelligenceTransport()
    ) {
        self.serializer = serializer
        self.transport = transport
    }

    public func status() async -> PrismLanguageIntelligenceStatus {
        PrismLanguageIntelligenceStatus(
            provider: .remote,
            isAvailable: true,
            supportsStreaming: false,
            supportsCustomInstructions: true,
            supportsModelAdapters: false
        )
    }

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
