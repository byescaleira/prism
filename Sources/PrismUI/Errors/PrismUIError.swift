//
//  PrismUIError.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import PrismFoundation

public enum PrismUIError: PrismError {
    case systemSymbolNotFound
    case emailValidationFailed

    public var description: String {
        switch self {
        case .systemSymbolNotFound:
            return "❌ SF Symbol not found in the system."
        case .emailValidationFailed:
            return "Email validation failed."
        }
    }

    public var failureReason: String? {
        switch self {
        case .systemSymbolNotFound:
            return "🔍 The system does not contain the specified SF Symbol."
        case .emailValidationFailed:
            return PrismUIString.validateEmailFailureReason.value
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .systemSymbolNotFound:
            return "💡 Check if the SF Symbol name is correct and available on this iOS version."
        case .emailValidationFailed:
            return PrismUIString.validateEmailRecoverySuggestion.value
        }
    }

}
