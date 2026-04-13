//
//  String+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 25/04/25.
//

import PrismFoundation
import SwiftUI

extension String {
    public static var prismPreviewTitle: String {
        PrismUIString.prismPreviewTitle.value
    }

    public static var prismPreviewDescription: String {
        PrismUIString.prismPreviewDescription.value
    }

    public static func prismPreviewDisplayName<T>(
        _ type: T.Type,
        scheme: ColorScheme,
        locale: PrismLocale
    ) -> String {
        let className = String(describing: type)
        let schemeName = scheme == .light ? "☀️ Light" : "🌒 Dark"
        let localeName = locale.description
        return "\(className) • \(schemeName) • \(localeName)"
    }

    public func formatted(with format: String) -> String {
        String(format: format, self)
    }
}
