//
//  PrismTextInputAutocapitalization.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/06/25.
//

import SwiftUI

public enum PrismTextInputAutocapitalization {
    case never
    case words
    case sentences
    case characters

    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        public var rawValue: TextInputAutocapitalization {
            switch self {
            case .never: return .never
            case .words: return .words
            case .sentences: return .sentences
            case .characters: return .characters
            }
        }
    #endif
}
