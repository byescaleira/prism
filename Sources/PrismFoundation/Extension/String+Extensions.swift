//
//  String+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation

extension String {
    public var breakLine: String {
        self + "\n"
    }

    public static var breakLine: String {
        "\n"
    }

    public var space: String {
        self + " "
    }

    public static var space: String {
        " "
    }

    public var double: Double? {
        Double(self)
    }

    public var int: Int? {
        Int(self)
    }

    public var normalized: String {
        self.folding(
            options: [
                .diacriticInsensitive,
                .caseInsensitive,
            ],
            locale: .current
        )
    }

    public func date(with formatter: PrismDateFormatter) -> Date? {
        formatter.date(from: self)
    }

    public var stableHash: Int64 {
        var hash: Int64 = 1_469_598_103_934_665_603
        let fnvPrime: Int64 = 1_099_511_628_211

        for byte in utf8 {
            hash = (hash ^ Int64(byte)) &* fnvPrime
        }

        return hash
    }
}

extension Substring {
    public var stableHash: Int64 {
        var hash: Int64 = 1_469_598_103_934_665_603
        let fnvPrime: Int64 = 1_099_511_628_211

        for byte in utf8 {
            hash = (hash ^ Int64(byte)) &* fnvPrime
        }

        return hash
    }
}
