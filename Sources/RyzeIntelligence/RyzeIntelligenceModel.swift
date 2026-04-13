//
//  RyzeIntelligenceModel.swift
//  Ryze
//
//  Created by Rafael Escaleira on 13/09/25.
//

import Foundation
import RyzeFoundation

public enum RyzeIntelligenceModelKind: String, Codable, Sendable, CaseIterable {
    case custom
    case textClassifier
    case tabularClassifier
    case tabularRegressor
    case foundationModelAdapter
}

public enum RyzeIntelligenceEngineKind: String, Codable, Sendable, CaseIterable {
    case coreML
    case createML
    case foundationModels
    case remote
}

public struct RyzeIntelligenceModelMetrics: Codable, Equatable, Hashable, Sendable {
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

private enum RyzeIntelligenceStorageKey {
    static let current = "ryze.intelligence.models"
    static let legacy = "ryze.models"
}

private struct RyzeLegacyIntelligenceModel: Codable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let isTraining: Bool
    let createDate: TimeInterval?
    let updateDate: TimeInterval?
    let accuracy: Double?
    let rootMeanSquaredError: Double?
}

public struct RyzeIntelligenceModel: RyzeEntity, Sendable {
    public var id: String
    public var name: String
    public var kind: RyzeIntelligenceModelKind
    public var engine: RyzeIntelligenceEngineKind
    public var artifactName: String
    public var isTraining: Bool
    public var createDate: TimeInterval?
    public var updateDate: TimeInterval?
    public var localeIdentifier: String?
    public var metrics: RyzeIntelligenceModelMetrics
    public var metadata: [String: String]

    public init(
        id: String,
        name: String,
        kind: RyzeIntelligenceModelKind = .custom,
        engine: RyzeIntelligenceEngineKind = .coreML,
        artifactName: String? = nil,
        isTraining: Bool = false,
        createDate: TimeInterval? = nil,
        updateDate: TimeInterval? = nil,
        localeIdentifier: String? = nil,
        metrics: RyzeIntelligenceModelMetrics = .init(),
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
        let fileManager = RyzeFileManager()
        return fileManager.size(at: artifactURL(fileManager: fileManager))
    }

    public func artifactURL(
        fileManager: RyzeFileManager = .init()
    ) -> URL? {
        fileManager.path(with: artifactName, privacy: .public)
    }

    public static var models: [RyzeIntelligenceModel] {
        loadStoredModels()
    }

    public static func clean() {
        persistStoredModels([])
    }

    static func loadStoredModels(
        defaults: RyzeDefaults = .init()
    ) -> [RyzeIntelligenceModel] {
        if let models: [RyzeIntelligenceModel] = defaults.get(for: RyzeIntelligenceStorageKey.current) {
            return sort(models)
        }

        if let models: [RyzeIntelligenceModel] = defaults.get(for: RyzeIntelligenceStorageKey.legacy) {
            return sort(models)
        }

        if let legacy: [RyzeLegacyIntelligenceModel] = defaults.get(for: RyzeIntelligenceStorageKey.legacy) {
            return sort(
                legacy.map {
                    RyzeIntelligenceModel(
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
        _ models: [RyzeIntelligenceModel],
        defaults: RyzeDefaults = .init()
    ) {
        let sortedModels = sort(models)
        defaults.set(sortedModels, for: RyzeIntelligenceStorageKey.current)
        defaults.set(sortedModels, for: RyzeIntelligenceStorageKey.legacy)
    }

    private static func sort(
        _ models: [RyzeIntelligenceModel]
    ) -> [RyzeIntelligenceModel] {
        models.sorted {
            ($0.updateDate ?? $0.createDate ?? .zero) > ($1.updateDate ?? $1.createDate ?? .zero)
        }
    }
}
