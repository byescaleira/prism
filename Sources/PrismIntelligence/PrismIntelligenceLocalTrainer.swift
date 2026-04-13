//
//  PrismIntelligenceLocalTrainer.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

#if canImport(CoreML)
    import CoreML
#endif
#if canImport(TabularData)
    import TabularData
#endif
#if canImport(CreateML)
    import CreateML
#endif
#if canImport(NaturalLanguage)
    import NaturalLanguage
#endif

public struct PrismTextTrainingConfiguration: Sendable, Equatable {
    public var id: String
    public var name: String
    public var localeIdentifier: String?
    public var maxIterations: Int?

    public init(
        id: String,
        name: String,
        localeIdentifier: String? = nil,
        maxIterations: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.localeIdentifier = localeIdentifier
        self.maxIterations = maxIterations
    }
}

public struct PrismTabularTrainingConfiguration: Sendable, Equatable {
    public var id: String
    public var name: String
    public var targetColumn: String
    public var maxDepth: Int
    public var maxIterations: Int
    public var minLossReduction: Double
    public var minChildWeight: Double
    public var randomSeed: Int
    public var stepSize: Double

    public init(
        id: String,
        name: String,
        targetColumn: String = "target",
        maxDepth: Int = 20,
        maxIterations: Int = 10_000,
        minLossReduction: Double = .zero,
        minChildWeight: Double = 0.01,
        randomSeed: Int = 42,
        stepSize: Double = 0.01
    ) {
        self.id = id
        self.name = name
        self.targetColumn = targetColumn
        self.maxDepth = maxDepth
        self.maxIterations = maxIterations
        self.minLossReduction = minLossReduction
        self.minChildWeight = minChildWeight
        self.randomSeed = randomSeed
        self.stepSize = stepSize
    }
}

internal protocol PrismIntelligenceTrainingRuntime: Sendable {
    func trainTextClassifier(
        data: [PrismTextTrainingSample],
        configuration: PrismTextTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics

    func trainTabularRegressor(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics

    func trainTabularClassifier(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics
}

internal struct PrismCreateMLIntelligenceTrainingRuntime: PrismIntelligenceTrainingRuntime {
    func trainTextClassifier(
        data: [PrismTextTrainingSample],
        configuration: PrismTextTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics {
        guard !data.isEmpty else {
            throw PrismIntelligenceError.invalidTrainingData("Text dataset is empty.")
        }

        #if canImport(CreateML) && canImport(TabularData)
            let rows = data.map { ["text": $0.text, "label": $0.label] }
            let jsonData = try JSONSerialization.data(withJSONObject: rows)
            let trainingData = try DataFrame(jsonData: jsonData)
            var parameters = MLTextClassifier.ModelParameters(
                validation: .dataFrame(
                    trainingData,
                    textColumn: "text",
                    labelColumn: "label"
                ),
                algorithm: .transferLearning(.bertEmbedding, revision: nil),
                language: resolvedLanguage(
                    identifier: configuration.localeIdentifier
                )
            )
            parameters.maxIterations = configuration.maxIterations

            let classifier = try MLTextClassifier(
                trainingData: trainingData,
                textColumn: "text",
                labelColumn: "label",
                parameters: parameters
            )

            try classifier.write(to: destination)

            return PrismIntelligenceModelMetrics(
                accuracy: 1 - classifier.validationMetrics.classificationError,
                rootMeanSquaredError: classifier.validationMetrics.classificationError
            )
        #else
            throw PrismIntelligenceError.unsupportedPlatform(
                "CreateML text training requires CreateML and TabularData."
            )
        #endif
    }

    func trainTabularRegressor(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics {
        guard !data.isEmpty else {
            throw PrismIntelligenceError.invalidTrainingData("Tabular dataset is empty.")
        }

        #if canImport(CreateML) && canImport(TabularData)
            let rows = data.map { row in
                row.mapValues(\.foundationValue)
            }
            let jsonData = try JSONSerialization.data(withJSONObject: rows)
            let trainingData = try DataFrame(jsonData: jsonData)
            let parameters = MLBoostedTreeRegressor.ModelParameters(
                validation: .dataFrame(trainingData),
                maxDepth: configuration.maxDepth,
                maxIterations: configuration.maxIterations,
                minLossReduction: configuration.minLossReduction,
                minChildWeight: configuration.minChildWeight,
                randomSeed: configuration.randomSeed,
                stepSize: configuration.stepSize,
                earlyStoppingRounds: nil,
                rowSubsample: 1,
                columnSubsample: 1
            )

            let regressor = try MLBoostedTreeRegressor(
                trainingData: trainingData,
                targetColumn: configuration.targetColumn,
                parameters: parameters
            )

            try regressor.write(to: destination)

            let evaluation = regressor.evaluation(on: trainingData)
            let expectedRange =
                maximumTargetValue(
                    in: data,
                    targetColumn: configuration.targetColumn
                ) ?? 1.0
            let relativeError = evaluation.rootMeanSquaredError / max(expectedRange, 1.0)

            return PrismIntelligenceModelMetrics(
                accuracy: max(0.0, 1.0 - relativeError),
                rootMeanSquaredError: evaluation.rootMeanSquaredError
            )
        #else
            throw PrismIntelligenceError.unsupportedPlatform(
                "CreateML tabular training requires CreateML and TabularData."
            )
        #endif
    }

    func trainTabularClassifier(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics {
        guard !data.isEmpty else {
            throw PrismIntelligenceError.invalidTrainingData("Tabular dataset is empty.")
        }

        #if canImport(CreateML) && canImport(TabularData)
            let rows = data.map { row in
                row.mapValues(\.foundationValue)
            }
            let jsonData = try JSONSerialization.data(withJSONObject: rows)
            let trainingData = try DataFrame(jsonData: jsonData)
            let parameters = MLBoostedTreeClassifier.ModelParameters(
                validation: .dataFrame(trainingData),
                maxDepth: configuration.maxDepth,
                maxIterations: configuration.maxIterations,
                minLossReduction: configuration.minLossReduction,
                minChildWeight: configuration.minChildWeight,
                randomSeed: configuration.randomSeed,
                stepSize: configuration.stepSize,
                earlyStoppingRounds: nil,
                rowSubsample: 1,
                columnSubsample: 1
            )

            let classifier = try MLBoostedTreeClassifier(
                trainingData: trainingData,
                targetColumn: configuration.targetColumn,
                parameters: parameters
            )

            try classifier.write(to: destination)

            return PrismIntelligenceModelMetrics(
                accuracy: 1 - classifier.validationMetrics.classificationError,
                rootMeanSquaredError: classifier.validationMetrics.classificationError
            )
        #else
            throw PrismIntelligenceError.unsupportedPlatform(
                "CreateML tabular training requires CreateML and TabularData."
            )
        #endif
    }

    #if canImport(CreateML) && canImport(TabularData) && canImport(NaturalLanguage)
        private func resolvedLanguage(
            identifier: String?
        ) -> NLLanguage? {
            if let identifier {
                return NLLanguage(rawValue: identifier)
            }

            return PrismLocale.current.naturalLanguage
        }
    #endif

    private func maximumTargetValue(
        in data: [PrismIntelligenceFeatureRow],
        targetColumn: String
    ) -> Double? {
        data.compactMap { $0[targetColumn]?.doubleValue }.max()
    }
}

public actor PrismIntelligenceLocalTrainer {
    private let catalog: PrismIntelligenceCatalog
    private let fileManager: PrismFileManager
    private let runtime: any PrismIntelligenceTrainingRuntime

    public init(
        catalog: PrismIntelligenceCatalog = .init(),
        fileManager: PrismFileManager = .init()
    ) {
        self.catalog = catalog
        self.fileManager = fileManager
        self.runtime = PrismCreateMLIntelligenceTrainingRuntime()
    }

    init(
        catalog: PrismIntelligenceCatalog = .init(),
        fileManager: PrismFileManager = .init(),
        runtime: any PrismIntelligenceTrainingRuntime
    ) {
        self.catalog = catalog
        self.fileManager = fileManager
        self.runtime = runtime
    }

    public func trainTextClassifier(
        data: [PrismTextTrainingSample],
        configuration: PrismTextTrainingConfiguration
    ) async throws -> PrismIntelligenceModel {
        let artifactName = "\(configuration.id).mlmodel"
        guard
            let destination = fileManager.path(
                with: artifactName,
                privacy: .public
            )
        else {
            throw PrismIntelligenceError.artifactNotFound(artifactName)
        }

        let metrics = try await runtime.trainTextClassifier(
            data: data,
            configuration: configuration,
            destination: destination
        )

        let now = Date.now.timeIntervalSince1970
        let model = PrismIntelligenceModel(
            id: configuration.id,
            name: configuration.name,
            kind: .textClassifier,
            engine: .createML,
            artifactName: artifactName,
            isTraining: false,
            createDate: now,
            updateDate: now,
            localeIdentifier: configuration.localeIdentifier,
            metrics: metrics
        )
        await catalog.save(model)
        return model
    }

    public func trainTabularRegressor(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration
    ) async throws -> PrismIntelligenceModel {
        try await trainTabularModel(
            kind: .tabularRegressor,
            data: data,
            configuration: configuration,
            train: runtime.trainTabularRegressor(data:configuration:destination:)
        )
    }

    public func trainTabularClassifier(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration
    ) async throws -> PrismIntelligenceModel {
        try await trainTabularModel(
            kind: .tabularClassifier,
            data: data,
            configuration: configuration,
            train: runtime.trainTabularClassifier(data:configuration:destination:)
        )
    }

    private func trainTabularModel(
        kind: PrismIntelligenceModelKind,
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        train: (
            _ data: [PrismIntelligenceFeatureRow],
            _ configuration: PrismTabularTrainingConfiguration,
            _ destination: URL
        ) async throws -> PrismIntelligenceModelMetrics
    ) async throws -> PrismIntelligenceModel {
        let artifactName = "\(configuration.id).mlmodel"
        guard
            let destination = fileManager.path(
                with: artifactName,
                privacy: .public
            )
        else {
            throw PrismIntelligenceError.artifactNotFound(artifactName)
        }

        let metrics = try await train(
            data,
            configuration,
            destination
        )

        let now = Date.now.timeIntervalSince1970
        let model = PrismIntelligenceModel(
            id: configuration.id,
            name: configuration.name,
            kind: kind,
            engine: .createML,
            artifactName: artifactName,
            isTraining: false,
            createDate: now,
            updateDate: now,
            metrics: metrics,
            metadata: [
                "targetColumn": configuration.targetColumn
            ]
        )
        await catalog.save(model)
        return model
    }
}
