//
//  RyzeTextIntelligence.swift
//  Ryze
//
//  Created by Rafael Escaleira on 13/09/25.
//

import Foundation
import RyzeFoundation

public final class RyzeTextIntelligence {
    let data: [RyzeTextTrainingSample]
    private let invalidRowCount: Int
    private let trainer: RyzeIntelligenceLocalTrainer

    public init(
        data: [[String: String]],
        trainer: RyzeIntelligenceLocalTrainer = .init()
    ) {
        self.data = data.compactMap { row in
            guard let text = row["text"],
                let label = row["label"]
            else {
                return nil
            }

            return RyzeTextTrainingSample(
                text: text,
                label: label
            )
        }
        self.invalidRowCount = data.count - self.data.count
        self.trainer = trainer
    }

    public init(
        samples: [RyzeTextTrainingSample],
        trainer: RyzeIntelligenceLocalTrainer = .init()
    ) {
        self.data = samples
        self.invalidRowCount = 0
        self.trainer = trainer
    }

    public func trainingTextClassifier(
        id: String,
        name: String,
        maxIterations: Int? = nil
    ) async -> RyzeIntelligenceResult {
        if invalidRowCount > 0 {
            return .failure(
                .invalidTrainingData("Found \(invalidRowCount) invalid text training rows.")
            )
        }

        do {
            let model = try await trainer.trainTextClassifier(
                data: data,
                configuration: RyzeTextTrainingConfiguration(
                    id: id,
                    name: name,
                    localeIdentifier: RyzeLocale.current.rawValue.identifier,
                    maxIterations: maxIterations
                )
            )
            return .saved(model: model)
        } catch let error as RyzeIntelligenceError {
            return .failure(error)
        } catch {
            return .failure(.underlying(error.localizedDescription))
        }
    }
}
