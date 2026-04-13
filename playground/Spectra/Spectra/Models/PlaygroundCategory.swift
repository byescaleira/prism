//
//  PlaygroundCategory.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI

enum PlaygroundCategory: Hashable, CaseIterable {
    case atoms
    case molecules
    case modifiers
    case patterns

    var title: String {
        switch self {
        case .atoms: "Atoms"
        case .molecules: "Molecules"
        case .modifiers: "Modifiers"
        case .patterns: "Patterns"
        }
    }

    var icon: String {
        switch self {
        case .atoms: "atom"
        case .molecules: "cube.box.fill"
        case .modifiers: "wand.and.stars"
        case .patterns: "square.grid.3x3.fill"
        }
    }

    var color: PrismColor {
        switch self {
        case .atoms: .primary
        case .molecules: .secondary
        case .modifiers: .warning
        case .patterns: .success
        }
    }

    var componentCount: Int {
        switch self {
        case .atoms: 15
        case .molecules: 10
        case .modifiers: 12
        case .patterns: 8
        }
    }

    var description: String {
        switch self {
        case .atoms:
            "Componentes básicos e fundamentais como botões, textos e ícones."
        case .molecules:
            "Componentes compostos que combinam átomos para funcionalidades complexas."
        case .modifiers:
            "Modifiers que transformam views com efeitos, animações e comportamentos."
        case .patterns:
            "Padrões de UI reutilizáveis e soluções para problemas comuns."
        }
    }
}
