//
//  Encodable+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import Foundation

extension Encodable {
    public var json: String {
        get throws {
            return try data().string
        }
    }

    public func data(with formatter: DateFormatter) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .formatted(formatter)
        return try encoder.encode(self)
    }

    public func data(with dateStyle: DateFormatter.Style = .long) throws -> Data {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateStyle = dateStyle
        return try data(with: dateFormatter)
    }
}
