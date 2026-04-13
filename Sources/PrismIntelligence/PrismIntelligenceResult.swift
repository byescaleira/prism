//
//  PrismIntelligenceResult.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/09/25.
//

public enum PrismIntelligenceResult: Sendable, Equatable {
    case error
    case saved(model: PrismIntelligenceModel)
    case failure(PrismIntelligenceError)
}
