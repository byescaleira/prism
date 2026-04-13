//
//  RyzeTabularIntelligence.swift
//  Ryze
//
//  Created by Rafael Escaleira on 14/09/25.
//

import Foundation

public final class RyzeTabularIntelligence {
    private let data: [RyzeIntelligenceFeatureRow]
    private let invalidRowCount: Int
    private let trainer: RyzeIntelligenceLocalTrainer

    public init(
        data: [[String: Any]],
        trainer: RyzeIntelligenceLocalTrainer = .init()
    ) {
        let converted = data.map {
            $0.compactMapValues(RyzeIntelligenceFeatureValue.init)
        }
        self.data = converted
        self.invalidRowCount =
            zip(data, converted)
            .filter { original, sanitized in
                original.count != sanitized.count || sanitized.isEmpty
            }
            .count
        self.trainer = trainer
    }

    public init(
        rows: [RyzeIntelligenceFeatureRow],
        trainer: RyzeIntelligenceLocalTrainer = .init()
    ) {
        self.data = rows
        self.invalidRowCount = 0
        self.trainer = trainer
    }

    public func trainingRegressor(
        id: String,
        name: String,
        maxDepth: Int = 20,
        maxIterations: Int = 10_000,
        minLossReduction: Double = .zero,
        minChildWeight: Double = 0.01,
        randomSeed: Int = 42,
        stepSize: Double = 0.01
    ) async -> RyzeIntelligenceResult {
        await train(
            kind: .tabularRegressor,
            configuration: RyzeTabularTrainingConfiguration(
                id: id,
                name: name,
                maxDepth: maxDepth,
                maxIterations: maxIterations,
                minLossReduction: minLossReduction,
                minChildWeight: minChildWeight,
                randomSeed: randomSeed,
                stepSize: stepSize
            )
        )
    }

    public func trainingClassifier(
        id: String,
        name: String,
        maxDepth: Int = 20,
        maxIterations: Int = 10_000,
        minLossReduction: Double = .zero,
        minChildWeight: Double = 0.01,
        randomSeed: Int = 42,
        stepSize: Double = 0.01
    ) async -> RyzeIntelligenceResult {
        await train(
            kind: .tabularClassifier,
            configuration: RyzeTabularTrainingConfiguration(
                id: id,
                name: name,
                maxDepth: maxDepth,
                maxIterations: maxIterations,
                minLossReduction: minLossReduction,
                minChildWeight: minChildWeight,
                randomSeed: randomSeed,
                stepSize: stepSize
            )
        )
    }

    private func train(
        kind: RyzeIntelligenceModelKind,
        configuration: RyzeTabularTrainingConfiguration
    ) async -> RyzeIntelligenceResult {
        if invalidRowCount > 0 {
            return .failure(
                .invalidTrainingData("Found \(invalidRowCount) invalid tabular training rows.")
            )
        }

        do {
            let model: RyzeIntelligenceModel

            switch kind {
            case .tabularClassifier:
                model = try await trainer.trainTabularClassifier(
                    data: data,
                    configuration: configuration
                )
            case .tabularRegressor:
                model = try await trainer.trainTabularRegressor(
                    data: data,
                    configuration: configuration
                )
            case .custom, .textClassifier, .foundationModelAdapter:
                return .failure(
                    .unsupportedInput("Unsupported tabular training kind: \(kind.rawValue)")
                )
            }

            return .saved(model: model)
        } catch let error as RyzeIntelligenceError {
            return .failure(error)
        } catch {
            return .failure(.underlying(error.localizedDescription))
        }
    }
}
