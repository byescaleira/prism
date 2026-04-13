//
//  PrismSize.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/07/25.
//

import SwiftUI

public indirect enum PrismSize {
    case none
    case ultraSmall
    case ultraSmall2
    case extraSmall
    case extraSmall2
    case small
    case small2
    case medium
    case medium2
    case large
    case large2
    case extraLarge
    case extraLarge2
    case ultraLarge
    case max

    func rawValue(for theme: PrismSizeProtocol) -> CGFloat? {
        switch self {
        case .none: return nil
        case .ultraSmall: return theme.ultraSmall
        case .ultraSmall2: return theme.ultraSmall2
        case .extraSmall: return theme.extraSmall
        case .extraSmall2: return theme.extraSmall2
        case .small: return theme.small
        case .small2: return theme.small2
        case .medium: return theme.medium
        case .medium2: return theme.medium2
        case .large: return theme.large
        case .large2: return theme.large2
        case .extraLarge: return theme.extraLarge
        case .extraLarge2: return theme.extraLarge2
        case .ultraLarge: return theme.ultraLarge
        case .max: return theme.max
        }
    }
}
