//
//  RyzeAccessibilityHint.swift
//  Ryze
//
//  Created by Rafael Escaleira on 02/07/25.
//

import RyzeFoundation
import SwiftUI

/// Protocolo antigo para acessibilidade - mantido para compatibilidade
/// Use RyzeAccessibilityProperties para novo código
public protocol RyzeAccessibilityHint: RyzeResourceString {
    var hint: RyzeResourceString { get }
    var label: RyzeResourceString { get }
    var identifier: RyzeResourceString { get }
}
