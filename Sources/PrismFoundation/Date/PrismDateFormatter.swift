//
//  PrismDateFormatter.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/08/25.
//

import Foundation

/// A protocol for date formatting with DateFormatter support.
public protocol PrismDateFormatter {
    /// The underlying `DateFormatter` used for conversions.
    var rawValue: DateFormatter { get }

    /// Converts a date to its string representation using this formatter.
    func string(from date: Date?) -> String?
    /// Parses a string into a date using this formatter.
    func date(from string: String?) -> Date?
}

extension PrismDateFormatter {
    /// Creates a `DateFormatter` configured with the given format string and the current Prism locale.
    public func getFormatter(from format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = PrismLocale.current.rawValue
        return formatter
    }

    /// Converts a date to its string representation, returning `nil` if the date is `nil`.
    public func string(from date: Date?) -> String? {
        guard let date else { return nil }
        return rawValue.string(from: date)
    }

    /// Parses a string into a date, returning `nil` if the string is `nil` or does not match the format.
    public func date(from string: String?) -> Date? {
        guard let string else { return nil }
        return rawValue.date(from: string)
    }
}
