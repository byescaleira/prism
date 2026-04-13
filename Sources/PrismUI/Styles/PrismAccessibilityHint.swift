//
//  PrismAccessibilityHint.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/07/25.
//

import PrismFoundation
import SwiftUI

/// Protocolo antigo para acessibilidade - mantido para compatibilidade
/// Use PrismAccessibilityProperties para novo código
public protocol PrismAccessibilityHint: PrismResourceString {
    var hint: PrismResourceString { get }
    var label: PrismResourceString { get }
    var identifier: PrismResourceString { get }
}
