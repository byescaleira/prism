//
//  PrismLanguageIntelligence.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

public enum PrismLanguageIntelligenceProviderKind: String, Codable, Sendable, CaseIterable {
    case apple
    case remote
}

public struct PrismLanguageGenerationOptions: Codable, Equatable, Hashable, Sendable {
    public var temperature: Double?
    public var maximumResponseTokens: Int?

    public init(
        temperature: Double? = nil,
        maximumResponseTokens: Int? = nil
    ) {
        self.temperature = temperature
        self.maximumResponseTokens = maximumResponseTokens
    }
}

public struct PrismLanguageIntelligenceRequest: Codable, Equatable, Hashable, Sendable {
    public var prompt: String
    public var systemPrompt: String?
    public var context: [String]
    public var options: PrismLanguageGenerationOptions
    public var metadata: [String: String]

    public init(
        prompt: String,
        systemPrompt: String? = nil,
        context: [String] = [],
        options: PrismLanguageGenerationOptions = .init(),
        metadata: [String: String] = [:]
    ) {
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.context = context
        self.options = options
        self.metadata = metadata
    }
}

public struct PrismLanguageTokenUsage: Codable, Equatable, Hashable, Sendable {
    public var promptTokens: Int?
    public var completionTokens: Int?
    public var totalTokens: Int?

    public init(
        promptTokens: Int? = nil,
        completionTokens: Int? = nil,
        totalTokens: Int? = nil
    ) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}

public struct PrismLanguageIntelligenceResponse: PrismEntity, Sendable {
    public var id: String
    public var provider: PrismLanguageIntelligenceProviderKind
    public var model: String?
    public var content: String
    public var finishReason: String?
    public var usage: PrismLanguageTokenUsage?
    public var createDate: TimeInterval
    public var metadata: [String: String]

    public init(
        id: String = UUID().uuidString,
        provider: PrismLanguageIntelligenceProviderKind,
        model: String? = nil,
        content: String,
        finishReason: String? = nil,
        usage: PrismLanguageTokenUsage? = nil,
        createDate: TimeInterval = Date.now.timeIntervalSince1970,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.provider = provider
        self.model = model
        self.content = content
        self.finishReason = finishReason
        self.usage = usage
        self.createDate = createDate
        self.metadata = metadata
    }
}

public struct PrismLanguageIntelligenceStatus: Codable, Equatable, Hashable, Sendable {
    public var provider: PrismLanguageIntelligenceProviderKind
    public var isAvailable: Bool
    public var reason: String?
    public var supportsStreaming: Bool
    public var supportsCustomInstructions: Bool
    public var supportsModelAdapters: Bool

    public init(
        provider: PrismLanguageIntelligenceProviderKind,
        isAvailable: Bool,
        reason: String? = nil,
        supportsStreaming: Bool = false,
        supportsCustomInstructions: Bool = true,
        supportsModelAdapters: Bool = false
    ) {
        self.provider = provider
        self.isAvailable = isAvailable
        self.reason = reason
        self.supportsStreaming = supportsStreaming
        self.supportsCustomInstructions = supportsCustomInstructions
        self.supportsModelAdapters = supportsModelAdapters
    }
}

public protocol PrismLanguageIntelligenceProvider: Sendable {
    var kind: PrismLanguageIntelligenceProviderKind { get }

    func status() async -> PrismLanguageIntelligenceStatus
    func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse
}

public actor PrismLanguageIntelligence {
    private let provider: any PrismLanguageIntelligenceProvider

    public init(
        provider: any PrismLanguageIntelligenceProvider
    ) {
        self.provider = provider
    }

    public func status() async -> PrismLanguageIntelligenceStatus {
        await provider.status()
    }

    public func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse {
        let status = await provider.status()
        guard status.isAvailable else {
            throw PrismIntelligenceError.providerUnavailable(
                status.reason ?? "The provider is currently unavailable."
            )
        }

        return try await provider.generate(request)
    }
}
