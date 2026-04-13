//
//  PrismLayoutTier.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

public enum PrismLayoutTier: String, CaseIterable, Equatable, Sendable {
    case compact
    case regular
    case expansive

    public var controlSize: ControlSize {
        switch self {
        case .compact:
            .regular
        case .regular:
            .large
        case .expansive:
            .extraLarge
        }
    }

    public var horizontalPadding: CGFloat {
        switch self {
        case .compact:
            16
        case .regular:
            20
        case .expansive:
            24
        }
    }

    public var verticalPadding: CGFloat {
        switch self {
        case .compact:
            10
        case .regular:
            12
        case .expansive:
            14
        }
    }
}
