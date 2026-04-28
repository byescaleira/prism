//
//  PrismModelManager.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// The type of a managed model.
public enum PrismModelType: String, Sendable, CaseIterable {
    /// A classification model.
    case classifier
    /// A regression model.
    case regressor
    /// A natural language processing model.
    case nlp
    /// An embedding model.
    case embedding
    /// A custom or user-defined model.
    case custom
}

/// Metadata describing a managed model.
public struct PrismModelInfo: Sendable, Equatable, Identifiable {
    /// A unique identifier for the model.
    public let id: String
    /// A human-readable name.
    public let name: String
    /// The model type.
    public let type: PrismModelType
    /// The on-disk size in bytes, if known.
    public let size: Int64?
    /// Whether the model is currently loaded into memory.
    public var isLoaded: Bool

    /// Creates model info.
    public init(id: String, name: String, type: PrismModelType, size: Int64? = nil, isLoaded: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.size = size
        self.isLoaded = isLoaded
    }
}

/// An actor that manages the lifecycle of registered models.
public actor PrismModelManager {
    private var models: [String: PrismModelInfo] = [:]

    /// Creates an empty model manager.
    public init() {}

    /// Registers a model in the manager.
    public func register(_ model: PrismModelInfo) {
        models[model.id] = model
    }

    /// Unloads a model by its identifier.
    public func unload(id: String) {
        guard var model = models[id] else { return }
        model.isLoaded = false
        models[id] = model
    }

    /// Returns all currently registered models.
    public var loadedModels: [PrismModelInfo] {
        Array(models.values)
    }

    /// Hot-swaps one model for another by unloading the source and loading the target.
    public func swap(from sourceID: String, to targetID: String) {
        if var source = models[sourceID] {
            source.isLoaded = false
            models[sourceID] = source
        }
        if var target = models[targetID] {
            target.isLoaded = true
            models[targetID] = target
        }
    }

    /// Returns a model by its identifier.
    public func model(for id: String) -> PrismModelInfo? {
        models[id]
    }

    /// Removes a model from the manager.
    public func remove(id: String) {
        models.removeValue(forKey: id)
    }

    /// The number of registered models.
    public var count: Int {
        models.count
    }
}
