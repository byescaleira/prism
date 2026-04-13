//
//  String+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/04/25.
//

import Foundation

extension String {
    static func localized(for key: PrismNetworkString) -> Self {
        key.value
    }

    static func localized(
        for key: PrismNetworkString,
        with arguments: CVarArg...
    ) -> Self {
        String(
            format: key.value,
            arguments: arguments
        )
    }
}
