//
//  PrismIntelligenceModel.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/09/25.
//

import Foundation
import PrismFoundation

public enum PrismIntelligenceModelKind: String, Codable, Sendable, CaseIterable {
    case custom
    case textClassifier
    case tabularClassifier
    case tabularRegressor
    case foundationModelAdapter
}

public enum PrismIntelligenceEngineKind: String, Codable, Sendable, CaseIterable {
    case coreML
    case createML
    case foundationModels
    case remote
}

public struct PrismIntelligenceModelMetrics: Codable, Equatable, Hashable, Sendable {
    public var accuracy: Double?
    public var rootMeanSquaredError: Double?

    public init(
        accuracy: Double? = nil,
        rootMeanSquaredError: Double? = nil
    ) {
        self.accuracy = accuracy
        self.rootMeanSquaredError = rootMeanSquaredError
    }
}

private enum PrismIntelligenceStorageKey {
    static let current = "prism.intelligence.models"
    static let legacy = "prism.models"
}

private struct PrismLegacyIntelligenceModel: Codable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let isTraining: Bool
    let createDate: TimeInterval?
    let updateDate: TimeInterval?
    let accuracy: Double?
    let rootMeanSquaredError: Double?
}

public struct PrismIntelligenceModel: PrismEntity, Sendable {
    public var id: String
    public var name: String
    public var kind: PrismIntelligenceModelKind
    public var engine: PrismIntelligenceEngineKind
    public var artifactName: String
    public var isTraining: Bool
    public var createDate: TimeInterval?
    public var updateDate: TimeInterval?
    public var localeIdentifier: String?
    public var metrics: PrismIntelligenceModelMetrics
    public var metadata: [String: String]

    public init(
        id: String,
        name: String,
        kind: PrismIntelligenceModelKind = .custom,
        engine: PrismIntelligenceEngineKind = .coreML,
        artifactName: String? = nil,
        isTraining: Bool = false,
        createDate: TimeInterval? = nil,
        updateDate: TimeInterval? = nil,
        localeIdentifier: String? = nil,
        metrics: PrismIntelligenceModelMetrics = .init(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.engine = engine
        self.artifactName = artifactName ?? "\(id).mlmodel"
        self.isTraining = isTraining
        self.createDate = createDate
        self.updateDate = updateDate
        self.localeIdentifier = localeIdentifier
        self.metrics = metrics
        self.metadata = metadata
    }

    public init(
        id: String,
        name: String,
        isTraining: Bool = false,
        createDate: TimeInterval? = nil,
        updateDate: TimeInterval? = nil,
        accuracy: Double? = nil,
        rootMeanSquaredError: Double? = nil
    ) {
        self.init(
            id: id,
            name: name,
            kind: .custom,
            engine: .coreML,
            artifactName: "\(id).mlmodel",
            isTraining: isTraining,
            createDate: createDate,
            updateDate: updateDate,
            metrics: .init(
                accuracy: accuracy,
                rootMeanSquaredError: rootMeanSquaredError
            )
        )
    }

    public var accuracy: Double? {
        metrics.accuracy
    }

    public var rootMeanSquaredError: Double? {
        metrics.rootMeanSquaredError
    }

    public var size: String {
        let fileManager = PrismFileManager()
        return fileManager.size(at: artifactURL(fileManager: fileManager))
    }

    public func artifactURL(
        fileManager: PrismFileManager = .init()
    ) -> URL? {
        fileManager.path(with: artifactName, privacy: .public)
    }

    public static var models: [PrismIntelligenceModel] {
        loadStoredModels()
    }

    public static func clean() {
        persistStoredModels([])
    }

    static func loadStoredModels(
        defaults: PrismDefaults = .init()
    ) -> [PrismIntelligenceModel] {
        if let models: [PrismIntelligenceModel] = defaults.get(for: PrismIntelligenceStorageKey.current) {
            return sort(models)
        }

        if let models: [PrismIntelligenceModel] = defaults.get(for: PrismIntelligenceStorageKey.legacy) {
            return sort(models)
        }

        if let legacy: [PrismLegacyIntelligenceModel] = defaults.get(for: PrismIntelligenceStorageKey.legacy) {
            return sort(
                legacy.map {
                    PrismIntelligenceModel(
                        id: $0.id,
                        name: $0.name,
                        isTraining: $0.isTraining,
                        createDate: $0.createDate,
                        updateDate: $0.updateDate,
                        accuracy: $0.accuracy,
                        rootMeanSquaredError: $0.rootMeanSquaredError
                    )
                }
            )
        }

        return []
    }

    static func persistStoredModels(
        _ models: [PrismIntelligenceModel],
        defaults: PrismDefaults = .init()
    ) {
        let sortedModels = sort(models)
        defaults.set(sortedModels, for: PrismIntelligenceStorageKey.current)
        defaults.set(sortedModels, for: PrismIntelligenceStorageKey.legacy)
    }

    private static func sort(
        _ models: [PrismIntelligenceModel]
    ) -> [PrismIntelligenceModel] {
        models.sorted {
            ($0.updateDate ?? $0.createDate ?? .zero) > ($1.updateDate ?? $1.createDate ?? .zero)
        }
    }
}
