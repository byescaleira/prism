//
//  PrismIntelligenceCatalog.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

public actor PrismIntelligenceCatalog {
    private let defaults: PrismDefaults

    public init(
        defaults: PrismDefaults = .init()
    ) {
        self.defaults = defaults
    }

    public func allModels() -> [PrismIntelligenceModel] {
        PrismIntelligenceModel.loadStoredModels(defaults: defaults)
    }

    public func model(
        id: String
    ) -> PrismIntelligenceModel? {
        allModels().first { $0.id == id }
    }

    public func save(
        _ model: PrismIntelligenceModel
    ) {
        var models = allModels()

        if let index = models.firstIndex(where: { $0.id == model.id }) {
            models[index] = model
        } else {
            models.append(model)
        }

        PrismIntelligenceModel.persistStoredModels(
            models,
            defaults: defaults
        )
    }

    @discardableResult
    public func remove(
        id: String
    ) -> PrismIntelligenceModel? {
        var models = allModels()
        guard let index = models.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        let removed = models.remove(at: index)
        PrismIntelligenceModel.persistStoredModels(
            models,
            defaults: defaults
        )
        return removed
    }

    public func clean() {
        PrismIntelligenceModel.persistStoredModels(
            [],
            defaults: defaults
        )
    }
}
