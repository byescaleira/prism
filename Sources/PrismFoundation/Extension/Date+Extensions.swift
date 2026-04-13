//
//  Date+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/06/25.
//

import Foundation

extension Date {
    public var timestamp: Int {
        Int(self.timeIntervalSince1970)
    }

    public var milliseconds: Int {
        Int(self.timeIntervalSince1970 * 1000)
    }

    public var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    public var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    public var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    public func string(with formatter: PrismDateFormatter) -> String? {
        formatter.string(from: self)
    }
}
