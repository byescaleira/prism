//
//  PrismError.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import Foundation
import os

/// Base protocol for typed errors with description, failure reason, and recovery suggestion.
public protocol PrismError:
    Error,
    CustomStringConvertible,
    LocalizedError,
    PrismLogger
{
    /// A localized description of the error.
    var errorDescription: String? { get }
    /// A localized explanation of why the error occurred.
    var failureReason: String? { get }
    /// A localized suggestion for how to recover from the error.
    var recoverySuggestion: String? { get }
}

extension PrismError {
    /// Logs the error, its failure reason, and recovery suggestion via the Prism logger.
    public func log() {
        let logger = PrismFoundationLogger()
        logger.error(.error(self))

        if let failureReason {
            logger.warning(.message(failureReason))
        }

        if let recoverySuggestion {
            logger.info(.message(recoverySuggestion))
        }
    }
}
