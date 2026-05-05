//
//  PrismCreateMLTrainingRuntime.swift
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
            let filteredData = filterFeatureColumns(
                data: data,
                configuration: configuration
            )
            let rows = filteredData.map { row in
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
                earlyStoppingRounds: configuration.earlyStoppingRounds,
                rowSubsample: configuration.rowSubsample,
                columnSubsample: configuration.columnSubsample
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
            let filteredData = filterFeatureColumns(
                data: data,
                configuration: configuration
            )
            let rows = filteredData.map { row in
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
                earlyStoppingRounds: configuration.earlyStoppingRounds,
                rowSubsample: configuration.rowSubsample,
                columnSubsample: configuration.columnSubsample
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

    private func filterFeatureColumns(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration
    ) -> [PrismIntelligenceFeatureRow] {
        guard let featureColumns = configuration.featureColumns else { return data }
        let allowed = Set(featureColumns + [configuration.targetColumn])
        return data.map { row in
            row.filter { allowed.contains($0.key) }
        }
    }

    private func maximumTargetValue(
        in data: [PrismIntelligenceFeatureRow],
        targetColumn: String
    ) -> Double? {
        data.compactMap { $0[targetColumn]?.doubleValue }.max()
    }
}
