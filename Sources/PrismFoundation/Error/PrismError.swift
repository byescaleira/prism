//
//  PrismError.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import Foundation
import os

public protocol PrismError:
    Error,
    CustomStringConvertible,
    LocalizedError,
    PrismLogger
{
    var errorDescription: String? { get }
    var failureReason: String? { get }
    var recoverySuggestion: String? { get }
}

extension PrismError {
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
