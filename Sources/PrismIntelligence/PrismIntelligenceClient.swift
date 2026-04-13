//
//  PrismIntelligenceClient.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

public enum PrismIntelligenceBackendKind: String, Codable, Sendable, CaseIterable {
    case local
    case apple
    case remote
}

public enum PrismIntelligenceCapability: String, Codable, Sendable, CaseIterable {
    case textClassification
    case tabularClassification
    case tabularRegression
    case languageGeneration
}

public struct PrismIntelligenceStatus: Codable, Equatable, Hashable, Sendable {
    public var backend: PrismIntelligenceBackendKind
    public var isAvailable: Bool
    public var reason: String?
    public var capabilities: [PrismIntelligenceCapability]
    public var modelID: String?
    public var modelName: String?
    public var provider: PrismLanguageIntelligenceProviderKind?
    public var supportsStreaming: Bool
    public var supportsCustomInstructions: Bool
    public var supportsModelAdapters: Bool

    public init(
        backend: PrismIntelligenceBackendKind,
        isAvailable: Bool,
        reason: String? = nil,
        capabilities: [PrismIntelligenceCapability],
        modelID: String? = nil,
        modelName: String? = nil,
        provider: PrismLanguageIntelligenceProviderKind? = nil,
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

public enum PrismIntelligenceRequest: Sendable, Equatable {
    case classifyText(String)
    case classifyFeatures(PrismIntelligenceFeatureRow)
    case regressFeatures(PrismIntelligenceFeatureRow)
    case generate(PrismLanguageIntelligenceRequest)
}

public enum PrismIntelligenceResponse: Sendable, Equatable {
    case textClassification(String)
    case tabularClassification([String: Double])
    case tabularRegression(Double)
    case language(PrismLanguageIntelligenceResponse)

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

internal protocol PrismIntelligenceLocalServing: Sendable {
    func predictText(from text: String) async throws -> String
    func predictClassifier(
        from features: PrismIntelligenceFeatureRow
    ) async throws -> [String: Double]
    func predictRegression(
        from features: PrismIntelligenceFeatureRow
    ) async throws -> Double
}

internal protocol PrismLanguageIntelligenceServing: Sendable {
    func status() async -> PrismLanguageIntelligenceStatus
    func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse
}

extension PrismIntelligencePrediction: PrismIntelligenceLocalServing {}
extension PrismLanguageIntelligence: PrismLanguageIntelligenceServing {}

public actor PrismIntelligenceClient {
    private enum Backend {
        case local(
            model: PrismIntelligenceModel,
            fileManager: PrismFileManager,
            service: any PrismIntelligenceLocalServing
        )
        case language(
            backend: PrismIntelligenceBackendKind,
            provider: PrismLanguageIntelligenceProviderKind,
            service: any PrismLanguageIntelligenceServing
        )
    }

    private let backend: Backend

    public static func local(
        model: PrismIntelligenceModel,
        fileManager: PrismFileManager = .init()
    ) async -> PrismIntelligenceClient {
        let service = await PrismIntelligencePrediction(
            model: model,
            fileManager: fileManager
        )
        return PrismIntelligenceClient(
            localModel: model,
            fileManager: fileManager,
            service: service
        )
    }

    public static func local(
        modelID: String,
        catalog: PrismIntelligenceCatalog = .init(),
        fileManager: PrismFileManager = .init()
    ) async throws -> PrismIntelligenceClient {
        guard let model = await catalog.model(id: modelID) else {
            throw PrismIntelligenceError.modelNotFound(modelID)
        }

        return await local(
            model: model,
            fileManager: fileManager
        )
    }

    public static func apple(
        configuration: PrismAppleIntelligenceConfiguration = .init()
    ) -> PrismIntelligenceClient {
        let provider = PrismAppleIntelligenceProvider(
            configuration: configuration
        )
        let service = PrismLanguageIntelligence(provider: provider)

        return PrismIntelligenceClient(
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
        transport: any PrismRemoteIntelligenceTransport = PrismURLSessionRemoteIntelligenceTransport()
    ) -> PrismIntelligenceClient {
        let serializer = PrismDefaultRemoteIntelligenceSerializer(
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
        serializer: any PrismRemoteIntelligenceSerializer,
        transport: any PrismRemoteIntelligenceTransport = PrismURLSessionRemoteIntelligenceTransport()
    ) -> PrismIntelligenceClient {
        let provider = PrismRemoteIntelligenceProvider(
            serializer: serializer,
            transport: transport
        )
        let service = PrismLanguageIntelligence(provider: provider)

        return PrismIntelligenceClient(
            languageService: service,
            backend: .remote,
            provider: .remote
        )
    }

    public static func provider(
        _ provider: any PrismLanguageIntelligenceProvider
    ) -> PrismIntelligenceClient {
        let service = PrismLanguageIntelligence(provider: provider)
        let backend: PrismIntelligenceBackendKind =
            switch provider.kind {
            case .apple:
                .apple
            case .remote:
                .remote
            }

        return PrismIntelligenceClient(
            languageService: service,
            backend: backend,
            provider: provider.kind
        )
    }

    init(
        localModel: PrismIntelligenceModel,
        fileManager: PrismFileManager,
        service: any PrismIntelligenceLocalServing
    ) {
        self.backend = .local(
            model: localModel,
            fileManager: fileManager,
            service: service
        )
    }

    init(
        languageService: any PrismLanguageIntelligenceServing,
        backend: PrismIntelligenceBackendKind,
        provider: PrismLanguageIntelligenceProviderKind
    ) {
        self.backend = .language(
            backend: backend,
            provider: provider,
            service: languageService
        )
    }

    public func status() async -> PrismIntelligenceStatus {
        switch backend {
        case .local(let model, let fileManager, _):
            let isSupportedEngine = model.engine == .coreML || model.engine == .createML
            let artifactURL = model.artifactURL(fileManager: fileManager)
            let artifactExists =
                artifactURL.map {
                    FileManager.default.fileExists(atPath: $0.path)
                } ?? false

            return PrismIntelligenceStatus(
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
            return PrismIntelligenceStatus(
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
        _ request: PrismIntelligenceRequest
    ) async throws -> PrismIntelligenceResponse {
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
            throw PrismIntelligenceError.unsupportedOperation(
                "Text classification is not supported by the \(backend.rawValue) backend."
            )
        }
    }

    public func classify(
        features: PrismIntelligenceFeatureRow
    ) async throws -> [String: Double] {
        switch backend {
        case .local(_, _, let service):
            return try await service.predictClassifier(from: features)
        case .language(let backend, _, _):
            throw PrismIntelligenceError.unsupportedOperation(
                "Tabular classification is not supported by the \(backend.rawValue) backend."
            )
        }
    }

    public func classify(
        features: [String: Any]
    ) async throws -> [String: Double] {
        guard let converted = features.intelligenceFeatures else {
            throw PrismIntelligenceError.unsupportedInput(
                "Could not convert feature dictionary into supported values."
            )
        }

        return try await classify(features: converted)
    }

    public func regress(
        features: PrismIntelligenceFeatureRow
    ) async throws -> Double {
        switch backend {
        case .local(_, _, let service):
            return try await service.predictRegression(from: features)
        case .language(let backend, _, _):
            throw PrismIntelligenceError.unsupportedOperation(
                "Tabular regression is not supported by the \(backend.rawValue) backend."
            )
        }
    }

    public func regress(
        features: [String: Any]
    ) async throws -> Double {
        guard let converted = features.intelligenceFeatures else {
            throw PrismIntelligenceError.unsupportedInput(
                "Could not convert feature dictionary into supported values."
            )
        }

        return try await regress(features: converted)
    }

    public func generate(
        _ prompt: String,
        systemPrompt: String? = nil,
        context: [String] = [],
        options: PrismLanguageGenerationOptions = .init(),
        metadata: [String: String] = [:]
    ) async throws -> String {
        let response = try await generate(
            PrismLanguageIntelligenceRequest(
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
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse {
        switch backend {
        case .local(let model, _, _):
            throw PrismIntelligenceError.unsupportedOperation(
                "Language generation is not supported by the local model \(model.id)."
            )
        case .language(_, _, let service):
            return try await service.generate(request)
        }
    }

    private func localAvailabilityReason(
        for model: PrismIntelligenceModel,
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
        for model: PrismIntelligenceModel
    ) -> [PrismIntelligenceCapability] {
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
    fileprivate var intelligenceFeatures: PrismIntelligenceFeatureRow? {
        let features = compactMapValues {
            PrismIntelligenceFeatureValue($0)
        }

        return features.isEmpty ? nil : features
    }
}
