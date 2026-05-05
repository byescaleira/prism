//
//  PrismLogger.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import os

/// A protocol for structured logging via os.Logger.
public protocol PrismLogger {
    /// Logs the conforming instance using the Prism logging system.
    func log()
}

/// System logging protocol with a dedicated Logger instance.
public protocol PrismSystemLogger {
    /// The log message type associated with this logger.
    associatedtype Message: PrismResourceLogMessage
    /// The underlying os.Logger instance used for output.
    var logger: Logger { get }

    /// Logs a message at the info level.
    func info(_ message: Message)
    /// Logs a message at the warning level.
    func warning(_ message: Message)
    /// Logs a message at the error level.
    func error(_ message: Message)
}
