//
//  PrismStructuredLogger.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// Severity levels for structured log entries, ordered from least to most critical.
public enum PrismLogLevel: Int, Sendable, Comparable, CaseIterable {
    /// Finest-grained informational events for detailed tracing.
    case trace = 0
    /// Diagnostic information useful during development.
    case debug = 1
    /// General informational messages about normal operation.
    case info = 2
    /// An indication of a potential issue that does not prevent operation.
    case warning = 3
    /// An error that affected a specific operation but not the overall system.
    case error = 4
    /// A severe error that may cause the application to terminate.
    case critical = 5

    /// Compares two log levels by their severity order.
    public static func < (lhs: PrismLogLevel, rhs: PrismLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// A single structured log entry capturing message, context, and source location.
public struct PrismLogEntry: Sendable {
    /// The severity level of this log entry.
    public let level: PrismLogLevel
    /// The human-readable log message.
    public let message: String
    /// The category grouping for this log entry.
    public let category: String
    /// Arbitrary key-value metadata attached to this entry.
    public let metadata: [String: String]
    /// The timestamp when this entry was created.
    public let timestamp: Date
    /// The source file where the log was emitted.
    public let file: String
    /// The source line where the log was emitted.
    public let line: Int

    /// Creates a new log entry with all fields.
    public init(
        level: PrismLogLevel,
        message: String,
        category: String = "default",
        metadata: [String: String] = [:],
        timestamp: Date = .now,
        file: String = #file,
        line: Int = #line
    ) {
        self.level = level
        self.message = message
        self.category = category
        self.metadata = metadata
        self.timestamp = timestamp
        self.file = file
        self.line = line
    }
}

/// A destination that receives structured log entries for output.
public protocol PrismLogDestination: Sendable {
    /// Writes a log entry to this destination.
    func write(_ entry: PrismLogEntry)
}

/// A console log destination that prints entries to standard output.
public struct PrismConsoleLogDestination: PrismLogDestination {
    /// Creates a new console log destination.
    public init() {}

    /// Prints the log entry to standard output in `[level] [category] message` format.
    public func write(_ entry: PrismLogEntry) {
        print("[\(entry.level)] [\(entry.category)] \(entry.message)")
    }
}

/// Thread-safe structured logger with configurable minimum level and buffered history.
public actor PrismStructuredLogger {
    /// The minimum log level; entries below this level are discarded.
    public var minimumLevel: PrismLogLevel
    /// Recent log entries kept in a circular buffer.
    public private(set) var entries: [PrismLogEntry]

    private let maxEntries: Int
    private var destinations: [any PrismLogDestination]

    /// Creates a structured logger with a minimum level, buffer size, and optional destinations.
    public init(
        minimumLevel: PrismLogLevel = .trace,
        maxEntries: Int = 1000,
        destinations: [any PrismLogDestination] = []
    ) {
        self.minimumLevel = minimumLevel
        self.maxEntries = maxEntries
        self.entries = []
        self.destinations = destinations
    }

    /// Logs an entry if its level meets the minimum threshold.
    public func log(
        _ level: PrismLogLevel,
        _ message: String,
        category: String = "default",
        metadata: [String: String] = [:],
        file: String = #file,
        line: Int = #line
    ) {
        guard level >= minimumLevel else { return }

        let entry = PrismLogEntry(
            level: level,
            message: message,
            category: category,
            metadata: metadata,
            file: file,
            line: line
        )

        entries.append(entry)
        if entries.count > maxEntries {
            entries.removeFirst(entries.count - maxEntries)
        }

        for destination in destinations {
            destination.write(entry)
        }
    }

    /// Logs a trace-level message.
    public func trace(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.trace, message, category: category, metadata: metadata, file: file, line: line)
    }

    /// Logs a debug-level message.
    public func debug(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.debug, message, category: category, metadata: metadata, file: file, line: line)
    }

    /// Logs an info-level message.
    public func info(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.info, message, category: category, metadata: metadata, file: file, line: line)
    }

    /// Logs a warning-level message.
    public func warning(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.warning, message, category: category, metadata: metadata, file: file, line: line)
    }

    /// Logs an error-level message.
    public func error(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.error, message, category: category, metadata: metadata, file: file, line: line)
    }

    /// Logs a critical-level message.
    public func critical(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.critical, message, category: category, metadata: metadata, file: file, line: line)
    }
}
