//
//  PrismIntelligenceClient.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

/// A unified facade for intelligence: local, Apple, and remote.
///
/// `PrismIntelligenceClient` is the primary entry point for running predictions and
/// generating text. Create a client with one of the factory methods, then call
/// ``status()``, ``classify(text:)``, ``regress(features:)-5v8wn``, or ``generate(_:)-4kb7s``.
///
/// ```swift
/// // Local text classification
/// let client = try await PrismIntelligenceClient.local(modelID: "sentiment")
/// let label = try await client.classify(text: "I love this product!")
///
/// // Apple Intelligence generation
/// let apple = PrismIntelligenceClient.apple()
/// let answer = try await apple.generate("Summarize quantum computing.")
///
/// // Remote provider generation
/// let remote = PrismIntelligenceClient.remote(endpoint: url)
/// let response = try await remote.generate("Hello, world!")
/// ```
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

    // MARK: - Factory Methods

    /// Creates a client backed by an on-device Core ML model.
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

    /// Creates a client backed by an on-device model resolved from the catalog by identifier.
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

    /// Creates a client backed by Apple Intelligence via the FoundationModels framework.
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

    /// Creates a client backed by a remote language model endpoint.
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

    /// Creates a client backed by a remote language model with Bearer token authentication.
    public static func remote(
        endpoint: URL,
        token: String,
        model: String? = nil,
        providerName: String = "remote",
        timeout: TimeInterval = 60,
        transport: any PrismRemoteIntelligenceTransport = PrismURLSessionRemoteIntelligenceTransport()
    ) -> PrismIntelligenceClient {
        remote(
            endpoint: endpoint,
            model: model,
            providerName: providerName,
            headers: ["Authorization": "Bearer \(token)"],
            timeout: timeout,
            transport: transport
        )
    }

    /// Creates a client backed by a remote language model using a custom serializer.
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

    /// Creates a client backed by a custom language-intelligence provider.
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

    // MARK: - Internal Init

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

    // MARK: - Status

    /// Returns the current availability status and capabilities of the backend.
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

    // MARK: - Execute

    /// Executes an intelligence request and returns the corresponding response.
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

    // MARK: - Classification

    /// Classifies free-form text into a label using the local model.
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

    /// Classifies a tabular feature row into label probabilities using the local model.
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

    /// Classifies an untyped feature dictionary into label probabilities.
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

    // MARK: - Regression

    /// Predicts a continuous value from a tabular feature row using the local model.
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

    /// Predicts a continuous value from an untyped feature dictionary.
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

    // MARK: - Generation

    /// Generates text from a prompt string using the language backend.
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

    /// Generates a full language response from a structured request.
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

    // MARK: - Private Helpers

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
