//
//  PrismIntelligenceTrainingTypes.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

/// Configuration for text classifier training.
public struct PrismTextTrainingConfiguration: Sendable, Equatable {
    /// A unique identifier for the resulting model.
    public var id: String
    /// A display name for the resulting model.
    public var name: String
    /// An optional BCP-47 locale identifier for the training language.
    public var localeIdentifier: String?
    /// An optional maximum number of training iterations.
    public var maxIterations: Int?

    /// Creates a text training configuration.
    ///
    /// - Parameters:
    ///   - id: A unique model identifier.
    ///   - name: A display name.
    ///   - localeIdentifier: An optional locale identifier.
    ///   - maxIterations: An optional iteration limit.
    public init(
        id: String,
        name: String,
        localeIdentifier: String? = nil,
        maxIterations: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.localeIdentifier = localeIdentifier
        self.maxIterations = maxIterations
    }
}

/// Configuration for tabular model training.
public struct PrismTabularTrainingConfiguration: Sendable, Equatable {
    /// A unique identifier for the resulting model.
    public var id: String
    /// A display name for the resulting model.
    public var name: String
    /// The name of the target column in the training data.
    public var targetColumn: String
    /// The maximum tree depth for boosted tree training.
    public var maxDepth: Int
    /// The maximum number of boosting iterations.
    public var maxIterations: Int
    /// The minimum loss reduction required to make a further partition.
    public var minLossReduction: Double
    /// The minimum sum of instance weight needed in a child node.
    public var minChildWeight: Double
    /// The random seed for reproducible training.
    public var randomSeed: Int
    /// The learning rate (step size) for each boosting round.
    public var stepSize: Double
    /// An optional subset of feature column names to use. If `nil`, all columns except target are used.
    public var featureColumns: [String]?
    /// The number of early stopping rounds. Training stops if validation loss doesn't improve for this many rounds.
    public var earlyStoppingRounds: Int?
    /// Row subsample ratio per boosting round (0.0–1.0). Defaults to 1.0.
    public var rowSubsample: Double
    /// Column subsample ratio per boosting round (0.0–1.0). Defaults to 1.0.
    public var columnSubsample: Double

    /// Creates a tabular training configuration.
    ///
    /// - Parameters:
    ///   - id: A unique model identifier.
    ///   - name: A display name.
    ///   - targetColumn: The target column name. Defaults to `"target"`.
    ///   - maxDepth: Maximum tree depth. Defaults to 20.
    ///   - maxIterations: Maximum boosting iterations. Defaults to 10,000.
    ///   - minLossReduction: Minimum loss reduction. Defaults to 0.
    ///   - minChildWeight: Minimum child weight. Defaults to 0.01.
    ///   - randomSeed: Random seed. Defaults to 42.
    ///   - stepSize: Learning rate. Defaults to 0.01.
    ///   - featureColumns: Optional subset of feature columns. `nil` = all except target.
    ///   - earlyStoppingRounds: Optional early stopping rounds.
    ///   - rowSubsample: Row subsample ratio. Defaults to 1.0.
    ///   - columnSubsample: Column subsample ratio. Defaults to 1.0.
    public init(
        id: String,
        name: String,
        targetColumn: String = "target",
        maxDepth: Int = 20,
        maxIterations: Int = 10_000,
        minLossReduction: Double = .zero,
        minChildWeight: Double = 0.01,
        randomSeed: Int = 42,
        stepSize: Double = 0.01,
        featureColumns: [String]? = nil,
        earlyStoppingRounds: Int? = nil,
        rowSubsample: Double = 1.0,
        columnSubsample: Double = 1.0
    ) {
        self.id = id
        self.name = name
        self.targetColumn = targetColumn
        self.maxDepth = maxDepth
        self.maxIterations = maxIterations
        self.minLossReduction = minLossReduction
        self.minChildWeight = minChildWeight
        self.randomSeed = randomSeed
        self.stepSize = stepSize
        self.featureColumns = featureColumns
        self.earlyStoppingRounds = earlyStoppingRounds
        self.rowSubsample = rowSubsample
        self.columnSubsample = columnSubsample
    }
}

internal protocol PrismIntelligenceTrainingRuntime: Sendable {
    func trainTextClassifier(
        data: [PrismTextTrainingSample],
        configuration: PrismTextTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics

    func trainTabularRegressor(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics

    func trainTabularClassifier(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics
}
