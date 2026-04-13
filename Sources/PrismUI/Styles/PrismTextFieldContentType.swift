//
//  PrismTextFieldContentType.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/06/25.
//

import SwiftUI

public enum PrismTextFieldContentType {
    case `default`
    case asciiCapable
    case numbersAndPunctuation
    case URL
    case numberPad
    case phonePad
    case namePhonePad
    case emailAddress
    case decimalPad
    case twitter
    case webSearch
    case asciiCapableNumberPad
    case alphabet

    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        public var rawValue: UIKeyboardType {
            switch self {
            case .default: return .default
            case .asciiCapable: return .asciiCapable
            case .numbersAndPunctuation: return .numbersAndPunctuation
            case .URL: return .URL
            case .numberPad: return .numberPad
            case .phonePad: return .phonePad
            case .namePhonePad: return .namePhonePad
            case .emailAddress: return .emailAddress
            case .decimalPad: return .decimalPad
            case .twitter: return .twitter
            case .webSearch: return .webSearch
            case .asciiCapableNumberPad: return .asciiCapableNumberPad
            case .alphabet: return .alphabet
            }
        }
    #endif
}
