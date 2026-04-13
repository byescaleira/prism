//
//  BinaryInteger+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/06/25.
//

import Foundation

extension BinaryInteger {
    public var isEven: Bool {
        self % 2 == 0
    }

    public var isOdd: Bool {
        !isEven
    }

    public var double: Double {
        Double(self)
    }

    public var string: String {
        String(self)
    }

    public var timestamp: Date {
        Date(timeIntervalSince1970: TimeInterval(self))
    }

    public var milliseconds: Date {
        Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }

    public func formatted(withSeparator: Bool = true) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = withSeparator
        let number = NSNumber(value: Int64(self))
        return formatter.string(from: number)
    }

    public func currency(locale: Locale = .current) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        let number = NSNumber(value: Int64(self))
        return formatter.string(from: number)
    }
}
