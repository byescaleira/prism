//
//  PrismTextIntelligence.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/09/25.
//

import Foundation
import PrismFoundation

public final class PrismTextIntelligence {
    let data: [PrismTextTrainingSample]
    private let invalidRowCount: Int
    private let trainer: PrismIntelligenceLocalTrainer

    public init(
        data: [[String: String]],
        trainer: PrismIntelligenceLocalTrainer = .init()
    ) {
        self.data = data.compactMap { row in
            guard let text = row["text"],
                let label = row["label"]
            else {
                return nil
            }

            return PrismTextTrainingSample(
                text: text,
                label: label
            )
        }
        self.invalidRowCount = data.count - self.data.count
        self.trainer = trainer
    }

    public init(
        samples: [PrismTextTrainingSample],
        trainer: PrismIntelligenceLocalTrainer = .init()
    ) {
        self.data = samples
        self.invalidRowCount = 0
        self.trainer = trainer
    }

    public func trainingTextClassifier(
        id: String,
        name: String,
        maxIterations: Int? = nil
    ) async -> PrismIntelligenceResult {
        if invalidRowCount > 0 {
            return .failure(
                .invalidTrainingData("Found \(invalidRowCount) invalid text training rows.")
            )
        }

        do {
            let model = try await trainer.trainTextClassifier(
                data: data,
                configuration: PrismTextTrainingConfiguration(
                    id: id,
                    name: name,
                    localeIdentifier: PrismLocale.current.rawValue.identifier,
                    maxIterations: maxIterations
                )
            )
            return .saved(model: model)
        } catch let error as PrismIntelligenceError {
            return .failure(error)
        } catch {
            return .failure(.underlying(error.localizedDescription))
        }
    }
}
