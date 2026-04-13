//
//  RyzeIntelligenceResult.swift
//  Ryze
//
//  Created by Rafael Escaleira on 13/09/25.
//

public enum RyzeIntelligenceResult: Sendable, Equatable {
    case error
    case saved(model: RyzeIntelligenceModel)
    case failure(RyzeIntelligenceError)
}
