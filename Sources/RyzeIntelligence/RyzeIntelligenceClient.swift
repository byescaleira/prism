//
//  RyzeIntelligenceClient.swift
//  Ryze
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import RyzeFoundation

public enum RyzeIntelligenceBackendKind: String, Codable, Sendable, CaseIterable {
    case local
    case apple
    case remote
}

public enum RyzeIntelligenceCapability: String, Codable, Sendable, CaseIterable {
    case textClassification
    case tabularClassification
    case tabularRegression
    case languageGeneration
}

public struct RyzeIntelligenceStatus: Codable, Equatable, Hashable, Sendable {
    public var backend: RyzeIntelligenceBackendKind
    public var isAvailable: Bool
    public var reason: String?
    public var capabilities: [RyzeIntelligenceCapability]
    public var modelID: String?
    public var modelName: String?
    public var provider: RyzeLanguageIntelligenceProviderKind?
    public var supportsStreaming: Bool
    public var supportsCustomInstructions: Bool
    public var supportsModelAdapters: Bool

    public init(
        backend: RyzeIntelligenceBackendKind,
        isAvailable: Bool,
        reason: String? = nil,
        capabilities: [RyzeIntelligenceCapability],
        modelID: String? = nil,
        modelName: String? = nil,
        provider: RyzeLanguageIntelligenceProviderKind? = nil,
        supportsStreaming: Bool = false,
        supportsCustomInstructions: Bool = false,
        supportsModelAdapters: Bool = false
    ) {
        self.backend = backend
        self.isAvailable = isAvailable
        self.reason = reason
        self.capabilities = capabilities
        self.modelID = modelID
        self.modelName = modelName
        self.provider = provider
        self.supportsStreaming = supportsStreaming
        self.supportsCustomInstructions = supportsCustomInstructions
        self.supportsModelAdapters = supportsModelAdapters
    }
}

public enum RyzeIntelligenceRequest: Sendable, Equatable {
    case classifyText(String)
    case classifyFeatures(RyzeIntelligenceFeatureRow)
    case regressFeatures(RyzeIntelligenceFeatureRow)
    case generate(RyzeLanguageIntelligenceRequest)
}

public enum RyzeIntelligenceResponse: Sendable, Equatable {
    case textClassification(String)
    case tabularClassification([String: Double])
    case tabularRegression(Double)
    case language(RyzeLanguageIntelligenceResponse)

    public var text: String? {
        switch self {
        case .textClassification(let value):
            value
        case .language(let response):
            response.content
        case .tabularClassification, .tabularRegression:
            nil
        }
    }
}

internal protocol RyzeIntelligenceLocalServing: Sendable {
    func predictText(from text: String) async throws -> String
    func predictClassifier(
        from features: RyzeIntelligenceFeatureRow
    ) async throws -> [String: Double]
    func predictRegression(
        from features: RyzeIntelligenceFeatureRow
    ) async throws -> Double
}

internal protocol RyzeLanguageIntelligenceServing: Sendable {
    func status() async -> RyzeLanguageIntelligenceStatus
    func generate(
        _ request: RyzeLanguageIntelligenceRequest
    ) async throws -> RyzeLanguageIntelligenceResponse
}

extension RyzeIntelligencePrediction: RyzeIntelligenceLocalServing {}
extension RyzeLanguageIntelligence: RyzeLanguageIntelligenceServing {}

public actor RyzeIntelligenceClient {
    private enum Backend {
        case local(
            model: RyzeIntelligenceModel,
            fileManager: RyzeFileManager,
            service: any RyzeIntelligenceLocalServing
        )
        case language(
            backend: RyzeIntelligenceBackendKind,
            provider: RyzeLanguageIntelligenceProviderKind,
            service: any RyzeLanguageIntelligenceServing
        )
    }

    private let backend: Backend

    public static func local(
        model: RyzeIntelligenceModel,
        fileManager: RyzeFileManager = .init()
    ) async -> RyzeIntelligenceClient {
        let service = await RyzeIntelligencePrediction(
            model: model,
            fileManager: fileManager
        )
        return RyzeIntelligenceClient(
            localModel: model,
            fileManager: fileManager,
            service: service
        )
    }

    public static func local(
        modelID: String,
        catalog: RyzeIntelligenceCatalog = .init(),
        fileManager: RyzeFileManager = .init()
    ) async throws -> RyzeIntelligenceClient {
        guard let model = await catalog.model(id: modelID) else {
            throw RyzeIntelligenceError.modelNotFound(modelID)
        }

        return await local(
            model: model,
            fileManager: fileManager
        )
    }

    public static func apple(
        configuration: RyzeAppleIntelligenceConfiguration = .init()
    ) -> RyzeIntelligenceClient {
        let provider = RyzeAppleIntelligenceProvider(
            configuration: configuration
        )
        let service = RyzeLanguageIntelligence(provider: provider)

        return RyzeIntelligenceClient(
            languageService: service,
            backend: .apple,
            provider: .apple
        )
    }

    public static func remote(
        endpoint: URL,
        model: String? = nil,
        providerName: String = "remote",
        headers: [String: String] = [:],
        timeout: TimeInterval = 60,
        transport: any RyzeRemoteIntelligenceTransport = RyzeURLSessionRemoteIntelligenceTransport()
    ) -> RyzeIntelligenceClient {
        let serializer = RyzeDefaultRemoteIntelligenceSerializer(
            endpoint: endpoint,
            model: model,
            providerName: providerName,
            headers: headers,
            timeout: timeout
        )

        return remote(
            serializer: serializer,
            transport: transport
        )
    }

    public static func remote(
        serializer: any RyzeRemoteIntelligenceSerializer,
        transport: any RyzeRemoteIntelligenceTransport = RyzeURLSessionRemoteIntelligenceTransport()
    ) -> RyzeIntelligenceClient {
        let provider = RyzeRemoteIntelligenceProvider(
            serializer: serializer,
            transport: transport
        )
        let service = RyzeLanguageIntelligence(provider: provider)

        return RyzeIntelligenceClient(
            languageService: service,
            backend: .remote,
            provider: .remote
        )
    }

    public static func provider(
        _ provider: any RyzeLanguageIntelligenceProvider
    ) -> RyzeIntelligenceClient {
        let service = RyzeLanguageIntelligence(provider: provider)
        let backend: RyzeIntelligenceBackendKind =
            switch provider.kind {
            case .apple:
                .apple
            case .remote:
                .remote
            }

        return RyzeIntelligenceClient(
            languageService: service,
            backend: backend,
            provider: provider.kind
        )
    }

    init(
        localModel: RyzeIntelligenceModel,
        fileManager: RyzeFileManager,
        service: any RyzeIntelligenceLocalServing
    ) {
        self.backend = .local(
            model: localModel,
            fileManager: fileManager,
            service: service
        )
    }

    init(
        languageService: any RyzeLanguageIntelligenceServing,
        backend: RyzeIntelligenceBackendKind,
        provider: RyzeLanguageIntelligenceProviderKind
    ) {
        self.backend = .language(
            backend: backend,
            provider: provider,
            service: languageService
        )
    }

    public func status() async -> RyzeIntelligenceStatus {
        switch backend {
        case .local(let model, let fileManager, _):
            let isSupportedEngine = model.engine == .coreML || model.engine == .createML
            let artifactURL = model.artifactURL(fileManager: fileManager)
            let artifactExists =
                artifactURL.map {
                    FileManager.default.fileExists(atPath: $0.path)
                } ?? false

            return RyzeIntelligenceStatus(
                backend: .local,
                isAvailable: isSupportedEngine && artifactExists,
                reason: localAvailabilityReason(
                    for: model,
                    isSupportedEngine: isSupportedEngine,
                    artifactExists: artifactExists
                ),
                capabilities: capabilities(for: model),
                modelID: model.id,
                modelName: model.name
            )

        case .language(let backend, let provider, let service):
            let status = await service.status()
            return RyzeIntelligenceStatus(
                backend: backend,
                isAvailable: status.isAvailable,
                reason: status.reason,
                capabilities: [.languageGeneration],
                provider: provider,
                supportsStreaming: status.supportsStreaming,
                supportsCustomInstructions: status.supportsCustomInstructions,
                supportsModelAdapters: status.supportsModelAdapters
            )
        }
    }

    public func execute(
        _ request: RyzeIntelligenceRequest
    ) async throws -> RyzeIntelligenceResponse {
        switch request {
        case .classifyText(let text):
            return .textClassification(
                try await classify(text: text)
            )
        case .classifyFeatures(let features):
            return .tabularClassification(
                try await classify(features: features)
            )
        case .regressFeatures(let features):
            return .tabularRegression(
                try await regress(features: features)
            )
        case .generate(let request):
            return .language(
                try await generate(request)
            )
        }
    }

    public func classify(
        text: String
    ) async throws -> String {
        switch backend {
        case .local(_, _, let service):
            return try await service.predictText(from: text)
        case .language(let backend, _, _):
            throw RyzeIntelligenceError.unsupportedOperation(
                "Text classification is not supported by the \(backend.rawValue) backend."
            )
        }
    }

    public func classify(
        features: RyzeIntelligenceFeatureRow
    ) async throws -> [String: Double] {
        switch backend {
        case .local(_, _, let service):
            return try await service.predictClassifier(from: features)
        case .language(let backend, _, _):
            throw RyzeIntelligenceError.unsupportedOperation(
                "Tabular classification is not supported by the \(backend.rawValue) backend."
            )
        }
    }

    public func classify(
        features: [String: Any]
    ) async throws -> [String: Double] {
        guard let converted = features.intelligenceFeatures else {
            throw RyzeIntelligenceError.unsupportedInput(
                "Could not convert feature dictionary into supported values."
            )
        }

        return try await classify(features: converted)
    }

    public func regress(
        features: RyzeIntelligenceFeatureRow
    ) async throws -> Double {
        switch backend {
        case .local(_, _, let service):
            return try await service.predictRegression(from: features)
        case .language(let backend, _, _):
            throw RyzeIntelligenceError.unsupportedOperation(
                "Tabular regression is not supported by the \(backend.rawValue) backend."
            )
        }
    }

    public func regress(
        features: [String: Any]
    ) async throws -> Double {
        guard let converted = features.intelligenceFeatures else {
            throw RyzeIntelligenceError.unsupportedInput(
                "Could not convert feature dictionary into supported values."
            )
        }

        return try await regress(features: converted)
    }

    public func generate(
        _ prompt: String,
        systemPrompt: String? = nil,
        context: [String] = [],
        options: RyzeLanguageGenerationOptions = .init(),
        metadata: [String: String] = [:]
    ) async throws -> String {
        let response = try await generate(
            RyzeLanguageIntelligenceRequest(
                prompt: prompt,
                systemPrompt: systemPrompt,
                context: context,
                options: options,
                metadata: metadata
            )
        )

        return response.content
    }

    public func generate(
        _ request: RyzeLanguageIntelligenceRequest
    ) async throws -> RyzeLanguageIntelligenceResponse {
        switch backend {
        case .local(let model, _, _):
            throw RyzeIntelligenceError.unsupportedOperation(
                "Language generation is not supported by the local model \(model.id)."
            )
        case .language(_, _, let service):
            return try await service.generate(request)
        }
    }

    private func localAvailabilityReason(
        for model: RyzeIntelligenceModel,
        isSupportedEngine: Bool,
        artifactExists: Bool
    ) -> String? {
        if !isSupportedEngine {
            return "Local inference only supports Core ML compatible models."
        }

        if !artifactExists {
            return "Model artifact not found: \(model.artifactName)"
        }

        return nil
    }

    private func capabilities(
        for model: RyzeIntelligenceModel
    ) -> [RyzeIntelligenceCapability] {
        switch model.kind {
        case .textClassifier:
            [.textClassification]
        case .tabularClassifier:
            [.tabularClassification]
        case .tabularRegressor:
            [.tabularRegression]
        case .custom:
            [
                .textClassification,
                .tabularClassification,
                .tabularRegression,
            ]
        case .foundationModelAdapter:
            []
        }
    }
}

extension Dictionary where Key == String, Value == Any {
    fileprivate var intelligenceFeatures: RyzeIntelligenceFeatureRow? {
        let features = compactMapValues {
            RyzeIntelligenceFeatureValue($0)
        }

        return features.isEmpty ? nil : features
    }
}
