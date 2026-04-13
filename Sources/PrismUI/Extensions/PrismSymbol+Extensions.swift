//
//  PrismSymbol+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/09/25.
//

import Foundation

extension PrismSymbol {
    public static var allSymbols: [String] {
        guard let symbols = try? PrismUIFile.symbols.data.entity(for: [String].self) else { return [] }
        return symbols
    }
}
