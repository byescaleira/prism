//
//  PrismSpacing.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/07/25.
//

import SwiftUI

public indirect enum PrismSpacing {
    case zero
    case extraSmall
    case small
    case medium
    case large
    case extraLarge
    case ultraLarge
    case section
    case negative(PrismSpacing)
    case custom(CGFloat)

    func rawValue(for theme: PrismSpacingProtocol) -> CGFloat {
        switch self {
        case .zero: return theme.none
        case .extraSmall: return theme.extraSmall
        case .small: return theme.small
        case .medium: return theme.medium
        case .large: return theme.large
        case .extraLarge: return theme.extraLarge
        case .ultraLarge: return theme.ultraLarge
        case .section: return theme.section
        case .negative(let spacing): return -spacing.rawValue(for: theme)
        case .custom(let spacing): return spacing
        }
    }
}
