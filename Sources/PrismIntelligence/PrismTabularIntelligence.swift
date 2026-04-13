//
//  PrismTabularIntelligence.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/09/25.
//

import Foundation

public final class PrismTabularIntelligence {
    private let data: [PrismIntelligenceFeatureRow]
    private let invalidRowCount: Int
    private let trainer: PrismIntelligenceLocalTrainer

    public init(
        data: [[String: Any]],
        trainer: PrismIntelligenceLocalTrainer = .init()
    ) {
        let converted = data.map {
            $0.compactMapValues(PrismIntelligenceFeatureValue.init)
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
        rows: [PrismIntelligenceFeatureRow],
        trainer: PrismIntelligenceLocalTrainer = .init()
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
    ) async -> PrismIntelligenceResult {
        await train(
            kind: .tabularRegressor,
            configuration: PrismTabularTrainingConfiguration(
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
    ) async -> PrismIntelligenceResult {
        await train(
            kind: .tabularClassifier,
            configuration: PrismTabularTrainingConfiguration(
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
        kind: PrismIntelligenceModelKind,
        configuration: PrismTabularTrainingConfiguration
    ) async -> PrismIntelligenceResult {
        if invalidRowCount > 0 {
            return .failure(
                .invalidTrainingData("Found \(invalidRowCount) invalid tabular training rows.")
            )
        }

        do {
            let model: PrismIntelligenceModel

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
        } catch let error as PrismIntelligenceError {
            return .failure(error)
        } catch {
            return .failure(.underlying(error.localizedDescription))
        }
    }
}
