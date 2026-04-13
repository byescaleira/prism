//
//  PrismNetworkString.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/03/25.
//

import Foundation
import PrismFoundation
import SwiftUI

enum PrismNetworkString: String, PrismResourceString, Sendable {
    case invalidURLDescription
    case invalidURLErrorDescription
    case invalidURLFailureReason
    case invalidURLRecoverySuggestion

    case invalidResponseDescription
    case invalidResponseErrorDescription
    case invalidResponseFailureReason
    case invalidResponseRecoverySuggestion

    case noConnectivityDescription
    case noConnectivityErrorDescription
    case noConnectivityFailureReason
    case noConnectivityRecoverySuggestion

    case badRequestDescription
    case badRequestErrorDescription
    case badRequestFailureReason
    case badRequestRecoverySuggestion

    case serverErrorDescription
    case serverErrorErrorDescription
    case serverErrorFailureReason
    case serverErrorRecoverySuggestion

    case unauthorizedDescription
    case unauthorizedErrorDescription
    case unauthorizedFailureReason
    case unauthorizedRecoverySuggestion

    case forbiddenDescription
    case forbiddenErrorDescription
    case forbiddenFailureReason
    case forbiddenRecoverySuggestion

    case noCacheDescription
    case noCacheErrorDescription
    case noCacheFailureReason
    case noCacheRecoverySuggestion

    case cacheInvertvalKey

    var localized: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }

    var value: String {
        String(
            localized: .init(rawValue),
            table: "PrismNetworkString",
            bundle: .module,
            locale: PrismLocale.current.rawValue
        )
    }
}
