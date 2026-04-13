//
//  PrismIntelligencePrediction.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/09/25.
//

import Foundation
import PrismFoundation

#if canImport(CoreML)
    import CoreML
#endif
#if canImport(NaturalLanguage)
    import NaturalLanguage
#endif

public enum PrismIntelligencePredictionResult: Sendable, Equatable {
    case textClassification(String)
    case tabularRegression(Double)
    case tabularClassification([String: Double])
    case empty
}

public enum PrismIntelligencePredictionInput: Equatable {
    case tabularData([String: Any])
    case text(String)
    case empty

    var tabularData: [String: Any] {
        switch self {
        case .tabularData(let dictionary):
            dictionary
        default:
            [:]
        }
    }

    var text: String {
        switch self {
        case .text(let text):
            text
        default:
            ""
        }
    }

    var tabularFeatures: PrismIntelligenceFeatureRow? {
        switch self {
        case .tabularData(let dictionary):
            let features = dictionary.compactMapValues {
                PrismIntelligenceFeatureValue($0)
            }
            return features.isEmpty ? nil : features
        case .text, .empty:
            return nil
        }
    }

    public static func == (
        lhs: PrismIntelligencePredictionInput,
        rhs: PrismIntelligencePredictionInput
    ) -> Bool {
        switch (lhs, rhs) {
        case (.tabularData(let lhs), .tabularData(let rhs)):
            NSDictionary(dictionary: lhs).isEqual(to: rhs)
        case (.text(let lhs), .text(let rhs)):
            lhs == rhs
        case (.empty, .empty):
            true
        default:
            false
        }
    }
}

internal protocol PrismIntelligencePredictionRuntime: Sendable {
    func regressionPrediction(
        modelURL: URL,
        features: PrismIntelligenceFeatureRow
    ) async throws -> Double

    func classifierPrediction(
        modelURL: URL,
        features: PrismIntelligenceFeatureRow
    ) async throws -> [String: Double]

    func textPrediction(
        modelURL: URL,
        text: String
    ) async throws -> String
}

#if canImport(CoreML)
    internal final class PrismCoreMLIntelligencePredictionRuntime: PrismIntelligencePredictionRuntime, @unchecked Sendable
    {
        private let lock = NSLock()
        private var cache: [URL: MLModel] = [:]

        func regressionPrediction(
            modelURL: URL,
            features: PrismIntelligenceFeatureRow
        ) async throws -> Double {
            let model = try await resolvedModel(at: modelURL)
            let provider = try MLDictionaryFeatureProvider(
                dictionary: features.mapValues(\.foundationValue)
            )
            let prediction = try await model.prediction(from: provider)

            if let value = prediction.featureValue(for: "target")?.doubleValue {
                return value
            }

            throw PrismIntelligenceError.predictionFailed("Missing regression target output.")
        }

        func classifierPrediction(
            modelURL: URL,
            features: PrismIntelligenceFeatureRow
        ) async throws -> [String: Double] {
            let model = try await resolvedModel(at: modelURL)
            let provider = try MLDictionaryFeatureProvider(
                dictionary: features.mapValues(\.foundationValue)
            )
            let prediction = try await model.prediction(from: provider)

            if let rawDictionary = prediction.featureValue(for: "target")?.dictionaryValue {
                return rawDictionary.reduce(into: [:]) { partialResult, entry in
                    if let key = entry.key as? String {
                        partialResult[key] = entry.value.doubleValue
                    }
                }
            }

            throw PrismIntelligenceError.predictionFailed("Missing classifier target output.")
        }

        func textPrediction(
            modelURL: URL,
            text: String
        ) async throws -> String {
            #if canImport(NaturalLanguage)
                let model = try await resolvedModel(at: modelURL)
                let nlModel = try NLModel(mlModel: model)

                if let label = nlModel.predictedLabel(for: text) {
                    return label
                }

                throw PrismIntelligenceError.predictionFailed("Text classifier returned no label.")
            #else
                throw PrismIntelligenceError.unsupportedPlatform(
                    "Natural Language prediction is unavailable."
                )
            #endif
        }

        private func resolvedModel(
            at url: URL
        ) async throws -> MLModel {
            if let cachedModel = lock.withLock({ cache[url] }) {
                return cachedModel
            }

            guard FileManager.default.fileExists(atPath: url.path) else {
                throw PrismIntelligenceError.artifactNotFound(url.lastPathComponent)
            }

            let compiledURL = try await MLModel.compileModel(at: url)
            let model = try MLModel(contentsOf: compiledURL)
            lock.withLock {
                cache[url] = model
            }
            return model
        }
    }
#else
    internal struct PrismCoreMLIntelligencePredictionRuntime: PrismIntelligencePredictionRuntime {
        func regressionPrediction(
            modelURL: URL,
            features: PrismIntelligenceFeatureRow
        ) async throws -> Double {
            throw PrismIntelligenceError.unsupportedPlatform("Core ML prediction is unavailable.")
        }

        func classifierPrediction(
            modelURL: URL,
            features: PrismIntelligenceFeatureRow
        ) async throws -> [String: Double] {
            throw PrismIntelligenceError.unsupportedPlatform("Core ML prediction is unavailable.")
        }

        func textPrediction(
            modelURL: URL,
            text: String
        ) async throws -> String {
            throw PrismIntelligenceError.unsupportedPlatform(
                "Natural Language prediction is unavailable."
            )
        }
    }
#endif

public actor PrismIntelligencePrediction {
    public let model: PrismIntelligenceModel

    private let fileManager: PrismFileManager
    private let runtime: any PrismIntelligencePredictionRuntime

    public init(
        model: PrismIntelligenceModel,
        fileManager: PrismFileManager = .init()
    ) async {
        self.model = model
        self.fileManager = fileManager
        self.runtime = PrismCoreMLIntelligencePredictionRuntime()
    }

    init(
        model: PrismIntelligenceModel,
        fileManager: PrismFileManager = .init(),
        runtime: any PrismIntelligencePredictionRuntime
    ) async {
        self.model = model
        self.fileManager = fileManager
        self.runtime = runtime
    }

    public func predictRegression(
        from features: PrismIntelligenceFeatureRow
    ) async throws -> Double {
        guard let modelURL = model.artifactURL(fileManager: fileManager) else {
            throw PrismIntelligenceError.artifactNotFound(model.artifactName)
        }

        return try await runtime.regressionPrediction(
            modelURL: modelURL,
            features: features
        )
    }

    public func predictClassifier(
        from features: PrismIntelligenceFeatureRow
    ) async throws -> [String: Double] {
        guard let modelURL = model.artifactURL(fileManager: fileManager) else {
            throw PrismIntelligenceError.artifactNotFound(model.artifactName)
        }

        return try await runtime.classifierPrediction(
            modelURL: modelURL,
            features: features
        )
    }

    public func predictText(
        from text: String
    ) async throws -> String {
        guard let modelURL = model.artifactURL(fileManager: fileManager) else {
            throw PrismIntelligenceError.artifactNotFound(model.artifactName)
        }

        return try await runtime.textPrediction(
            modelURL: modelURL,
            text: text
        )
    }

    public func regressionPrediction(
        from input: PrismIntelligencePredictionInput
    ) async -> PrismIntelligencePredictionResult {
        guard let features = input.tabularFeatures,
            input != .empty,
            let prediction = try? await predictRegression(from: features)
        else {
            return .empty
        }

        return .tabularRegression(prediction)
    }

    public func classifierPrediction(
        from input: PrismIntelligencePredictionInput
    ) async -> PrismIntelligencePredictionResult {
        guard let features = input.tabularFeatures,
            input != .empty,
            let prediction = try? await predictClassifier(from: features)
        else {
            return .empty
        }

        return .tabularClassification(prediction)
    }

    public func textPrediction(
        from input: PrismIntelligencePredictionInput
    ) async -> PrismIntelligencePredictionResult {
        guard input != .empty,
            let prediction = try? await predictText(from: input.text)
        else {
            return .empty
        }

        return .textClassification(prediction)
    }
}
