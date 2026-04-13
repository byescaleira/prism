//
//  TimeInterval+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/07/25.
//

import Foundation

extension TimeInterval {
    public var second: TimeInterval {
        self
    }

    public var minute: TimeInterval {
        self * 60
    }

    public var hour: TimeInterval {
        self * 3600
    }

    public var day: TimeInterval {
        self * 86400
    }

    public var date: Date {
        Date(timeIntervalSince1970: self)
    }

    public var yearMonth: Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return (year * 100) + month
    }
}
