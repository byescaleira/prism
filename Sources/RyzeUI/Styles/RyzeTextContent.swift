//
//  RyzeTextContent.swift
//  Ryze
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

enum RyzeTextContent {
    case string(String)
    case localized(LocalizedStringKey)

    init?(_ text: String?) {
        guard let text else {
            return nil
        }

        self = .string(text)
    }

    init(_ localized: LocalizedStringKey) {
        self = .localized(localized)
    }

    func text() -> Text {
        switch self {
        case .string(let text):
            Text(text)
        case .localized(let key):
            Text(key)
        }
    }

    @ViewBuilder
    func view() -> some View {
        text()
    }
}
