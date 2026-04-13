//
//  RyzeIntelligenceError.swift
//  Ryze
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation

public enum RyzeIntelligenceError: Error, Sendable, Equatable {
    case invalidTrainingData(String)
    case unsupportedPlatform(String)
    case unsupportedOperation(String)
    case modelNotFound(String)
    case artifactNotFound(String)
    case unsupportedInput(String)
    case predictionFailed(String)
    case trainingFailed(String)
    case providerUnavailable(String)
    case invalidResponse(String)
    case networkFailure(String)
    case adapterFailure(String)
    case underlying(String)
}

extension RyzeIntelligenceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidTrainingData(let message):
            "Invalid training data: \(message)"
        case .unsupportedPlatform(let message):
            "Unsupported platform: \(message)"
        case .unsupportedOperation(let message):
            "Unsupported operation: \(message)"
        case .modelNotFound(let identifier):
            "Model not found: \(identifier)"
        case .artifactNotFound(let artifact):
            "Model artifact not found: \(artifact)"
        case .unsupportedInput(let message):
            "Unsupported input: \(message)"
        case .predictionFailed(let message):
            "Prediction failed: \(message)"
        case .trainingFailed(let message):
            "Training failed: \(message)"
        case .providerUnavailable(let message):
            "Provider unavailable: \(message)"
        case .invalidResponse(let message):
            "Invalid response: \(message)"
        case .networkFailure(let message):
            "Network failure: \(message)"
        case .adapterFailure(let message):
            "Adapter failure: \(message)"
        case .underlying(let message):
            message
        }
    }
}
