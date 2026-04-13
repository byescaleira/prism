//
//  PrismBundle+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import Foundation
import PrismFoundation

extension PrismBundle {
    public func getSymbols() async throws(PrismUIError) -> [String] {
        guard let bundle = Bundle(identifier: "com.apple.CoreGlyphs") else {
            throw .systemSymbolNotFound
        }

        guard let resourcePath = bundle.path(forResource: "name_availability", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: resourcePath),
            let plistSymbols = plist["symbols"] as? [String: String]
        else {
            throw .systemSymbolNotFound
        }

        return plistSymbols.map(\.key).sorted(by: <)
    }
}
