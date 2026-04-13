//
//  BinaryFloatingPoint+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/06/25.
//

import Foundation

extension BinaryFloatingPoint {
    public var abs: Self {
        Swift.abs(self)
    }

    public var double: Double {
        Double(self)
    }

    public var int: Int {
        Int(self)
    }

    public var string: String {
        String(double)
    }

    public var int64: Int64 {
        Int64(self)
    }

    public func formatted(decimals: Int = 2, locale: Locale = .current) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        formatter.locale = locale
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: double))
    }

    public func currency(locale: Locale = .current) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: NSNumber(value: double))
    }

    public var largeNormalized: Int64 {
        let scale: Double = 100_000_000
        let normalized = Int64((double * scale).rounded())
        return normalized
    }
}
