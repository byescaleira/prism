//
//  PrismIntelligenceLocalTrainer.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

/// A local model trainer backed by CreateML.
///
/// Use `PrismIntelligenceLocalTrainer` to train text classifiers, tabular classifiers,
/// and tabular regressors on-device. Trained models are automatically persisted to the catalog.
public actor PrismIntelligenceLocalTrainer {
    private let catalog: PrismIntelligenceCatalog
    private let fileManager: PrismFileManager
    private let runtime: any PrismIntelligenceTrainingRuntime

    /// Creates a local trainer backed by CreateML.
    ///
    /// - Parameters:
    ///   - catalog: The catalog used to persist trained models.
    ///   - fileManager: The file manager used to resolve artifact paths.
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

    /// Trains a text classifier from labeled samples and persists the resulting model.
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

    /// Trains a tabular regressor from feature rows and persists the resulting model.
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

    /// Trains a tabular classifier from feature rows and persists the resulting model.
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
