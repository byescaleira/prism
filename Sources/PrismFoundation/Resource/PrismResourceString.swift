//
//  PrismResourceString.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

import SwiftUI

public protocol PrismResourceString {
    var localized: LocalizedStringKey { get }
    var value: String { get }
}
