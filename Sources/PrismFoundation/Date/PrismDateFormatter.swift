//
//  PrismDateFormatter.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/08/25.
//

import Foundation

public protocol PrismDateFormatter {
    var rawValue: DateFormatter { get }

    func string(from date: Date?) -> String?
    func date(from string: String?) -> Date?
}

extension PrismDateFormatter {
    public func getFormatter(from format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = PrismLocale.current.rawValue
        return formatter
    }

    public func string(from date: Date?) -> String? {
        guard let date else { return nil }
        return rawValue.string(from: date)
    }

    public func date(from string: String?) -> Date? {
        guard let string else { return nil }
        return rawValue.date(from: string)
    }
}
