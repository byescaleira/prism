//
//  PrismResourceString.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

import SwiftUI

/// A protocol for localizable strings.
public protocol PrismResourceString {
    /// The localized string key for use in SwiftUI views.
    var localized: LocalizedStringKey { get }
    /// The raw string value.
    var value: String { get }
}
