//
//  PrismUIString.swift
//  Prism
//
//  Created by Rafael Escaleira on 25/04/25.
//

import Foundation
import PrismFoundation
import SwiftUI

enum PrismUIString: String, PrismResourceString, CaseIterable {
    case forceUnwrapTitle
    case forceUnwrapDescription
    case mergeConflictTitle
    case mergeConflictDescription
    case rubberDuckTitle
    case rubberDuckDescription
    case legacyCodeTitle
    case legacyCodeDescription
    case infiniteLoopTitle
    case infiniteLoopDescription
    case spaghettiCodeTitle
    case spaghettiCodeDescription
    case coffeeDrivenTitle
    case coffeeDrivenDescription
    case fridayDeployTitle
    case fridayDeployDescription
    case stackOverflowCopyTitle
    case stackOverflowCopyDescription
    case debugPrintTitle
    case debugPrintDescription

    case validateEmailFailureReason
    case validateEmailRecoverySuggestion

    case placeholderEmail

    var localized: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }

    var value: String {
        String(
            localized: .init(rawValue),
            bundle: .module,
            locale: PrismLocale.portugueseBR.rawValue
        )
    }

    static var prismPreviewTitle: Self {
        let cases = PrismPreviewMockQuote.allCases
        let index = Int.random(in: 0..<cases.count)
        return cases[index].title
    }

    static var prismPreviewDescription: Self {
        let cases = PrismPreviewMockQuote.allCases
        let index = Int.random(in: 0..<cases.count)
        return cases[index].description
    }
}
