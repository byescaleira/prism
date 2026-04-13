//
//  RyzeLanguageIntelligence.swift
//  Ryze
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import RyzeFoundation

public enum RyzeLanguageIntelligenceProviderKind: String, Codable, Sendable, CaseIterable {
    case apple
    case remote
}

public struct RyzeLanguageGenerationOptions: Codable, Equatable, Hashable, Sendable {
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

public struct RyzeLanguageIntelligenceRequest: Codable, Equatable, Hashable, Sendable {
    public var prompt: String
    public var systemPrompt: String?
    public var context: [String]
    public var options: RyzeLanguageGenerationOptions
    public var metadata: [String: String]

    public init(
        prompt: String,
        systemPrompt: String? = nil,
        context: [String] = [],
        options: RyzeLanguageGenerationOptions = .init(),
        metadata: [String: String] = [:]
    ) {
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.context = context
        self.options = options
        self.metadata = metadata
    }
}

public struct RyzeLanguageTokenUsage: Codable, Equatable, Hashable, Sendable {
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

public struct RyzeLanguageIntelligenceResponse: RyzeEntity, Sendable {
    public var id: String
    public var provider: RyzeLanguageIntelligenceProviderKind
    public var model: String?
    public var content: String
    public var finishReason: String?
    public var usage: RyzeLanguageTokenUsage?
    public var createDate: TimeInterval
    public var metadata: [String: String]

    public init(
        id: String = UUID().uuidString,
        provider: RyzeLanguageIntelligenceProviderKind,
        model: String? = nil,
        content: String,
        finishReason: String? = nil,
        usage: RyzeLanguageTokenUsage? = nil,
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

public struct RyzeLanguageIntelligenceStatus: Codable, Equatable, Hashable, Sendable {
    public var provider: RyzeLanguageIntelligenceProviderKind
    public var isAvailable: Bool
    public var reason: String?
    public var supportsStreaming: Bool
    public var supportsCustomInstructions: Bool
    public var supportsModelAdapters: Bool

    public init(
        provider: RyzeLanguageIntelligenceProviderKind,
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

public protocol RyzeLanguageIntelligenceProvider: Sendable {
    var kind: RyzeLanguageIntelligenceProviderKind { get }

    func status() async -> RyzeLanguageIntelligenceStatus
    func generate(
        _ request: RyzeLanguageIntelligenceRequest
    ) async throws -> RyzeLanguageIntelligenceResponse
}

public actor RyzeLanguageIntelligence {
    private let provider: any RyzeLanguageIntelligenceProvider

    public init(
        provider: any RyzeLanguageIntelligenceProvider
    ) {
        self.provider = provider
    }

    public func status() async -> RyzeLanguageIntelligenceStatus {
        await provider.status()
    }

    public func generate(
        _ request: RyzeLanguageIntelligenceRequest
    ) async throws -> RyzeLanguageIntelligenceResponse {
        let status = await provider.status()
        guard status.isAvailable else {
            throw RyzeIntelligenceError.providerUnavailable(
                status.reason ?? "The provider is currently unavailable."
            )
        }

        return try await provider.generate(request)
    }
}
