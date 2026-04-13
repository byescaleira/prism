//
//  RyzeIntelligenceCatalog.swift
//  Ryze
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import RyzeFoundation

public actor RyzeIntelligenceCatalog {
    private let defaults: RyzeDefaults

    public init(
        defaults: RyzeDefaults = .init()
    ) {
        self.defaults = defaults
    }

    public func allModels() -> [RyzeIntelligenceModel] {
        RyzeIntelligenceModel.loadStoredModels(defaults: defaults)
    }

    public func model(
        id: String
    ) -> RyzeIntelligenceModel? {
        allModels().first { $0.id == id }
    }

    public func save(
        _ model: RyzeIntelligenceModel
    ) {
        var models = allModels()

        if let index = models.firstIndex(where: { $0.id == model.id }) {
            models[index] = model
        } else {
            models.append(model)
        }

        RyzeIntelligenceModel.persistStoredModels(
            models,
            defaults: defaults
        )
    }

    @discardableResult
    public func remove(
        id: String
    ) -> RyzeIntelligenceModel? {
        var models = allModels()
        guard let index = models.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        let removed = models.remove(at: index)
        RyzeIntelligenceModel.persistStoredModels(
            models,
            defaults: defaults
        )
        return removed
    }

    public func clean() {
        RyzeIntelligenceModel.persistStoredModels(
            [],
            defaults: defaults
        )
    }
}
