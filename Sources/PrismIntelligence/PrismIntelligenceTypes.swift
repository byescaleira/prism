//
//  PrismIntelligenceTypes.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation

/// The kind of intelligence backend.
public enum PrismIntelligenceBackendKind: String, Codable, Sendable, CaseIterable {
    /// On-device inference using a Core ML or CreateML model artifact.
    case local
    /// Apple Intelligence via the FoundationModels framework.
    case apple
    /// A remote language model accessed over the network.
    case remote
}

/// Capabilities of an intelligence backend.
public enum PrismIntelligenceCapability: String, Codable, Sendable, CaseIterable {
    /// Classifying free-form text into discrete labels.
    case textClassification
    /// Classifying tabular feature rows into discrete labels.
    case tabularClassification
    /// Predicting a continuous numeric value from tabular features.
    case tabularRegression
    /// Generating natural-language text from a prompt.
    case languageGeneration
}

/// Availability status and capabilities of a backend.
public struct PrismIntelligenceStatus: Codable, Equatable, Hashable, Sendable {
    /// The kind of backend this status describes.
    public var backend: PrismIntelligenceBackendKind
    /// Whether the backend is ready to accept requests.
    public var isAvailable: Bool
    /// A human-readable explanation when the backend is unavailable.
    public var reason: String?
    /// The set of capabilities the backend supports.
    public var capabilities: [PrismIntelligenceCapability]
    /// The identifier of the model served by this backend, if applicable.
    public var modelID: String?
    /// The display name of the model, if applicable.
    public var modelName: String?
    /// The language-intelligence provider kind, for Apple or remote backends.
    public var provider: PrismLanguageIntelligenceProviderKind?
    /// Whether the backend supports streaming responses.
    public var supportsStreaming: Bool
    /// Whether the backend supports custom system instructions.
    public var supportsCustomInstructions: Bool
    /// Whether the backend supports model adapters.
    public var supportsModelAdapters: Bool

    /// Creates a new backend status.
    ///
    /// - Parameters:
    ///   - backend: The kind of backend.
    ///   - isAvailable: Whether the backend is ready.
    ///   - reason: An optional explanation when unavailable.
    ///   - capabilities: The supported capabilities.
    ///   - modelID: An optional model identifier.
    ///   - modelName: An optional model display name.
    ///   - provider: An optional language-intelligence provider kind.
    ///   - supportsStreaming: Whether streaming is supported.
    ///   - supportsCustomInstructions: Whether custom instructions are supported.
    ///   - supportsModelAdapters: Whether model adapters are supported.
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

/// An intelligence request (classification, regression, or generation).
public enum PrismIntelligenceRequest: Sendable, Equatable {
    /// Classify free-form text into a label.
    case classifyText(String)
    /// Classify a tabular feature row into label probabilities.
    case classifyFeatures(PrismIntelligenceFeatureRow)
    /// Predict a continuous value from a tabular feature row.
    case regressFeatures(PrismIntelligenceFeatureRow)
    /// Generate natural-language text from a language request.
    case generate(PrismLanguageIntelligenceRequest)
}

/// An intelligence response.
public enum PrismIntelligenceResponse: Sendable, Equatable {
    /// A predicted text label from a text classifier.
    case textClassification(String)
    /// Label probabilities from a tabular classifier.
    case tabularClassification([String: Double])
    /// A predicted continuous value from a tabular regressor.
    case tabularRegression(Double)
    /// A generated language response.
    case language(PrismLanguageIntelligenceResponse)

    /// The textual content of the response, if applicable.
    ///
    /// Returns the classification label for ``textClassification`` or the generated
    /// content for ``language``. Returns `nil` for tabular results.
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

extension Dictionary where Key == String, Value == Any {
    package var intelligenceFeatures: PrismIntelligenceFeatureRow? {
        let features = compactMapValues {
            PrismIntelligenceFeatureValue($0)
        }

        return features.isEmpty ? nil : features
    }
}
