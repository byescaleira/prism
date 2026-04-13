//
//  PrismSemanticColors.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

// MARK: - PrismSemanticColors

public struct PrismSemanticColors: Sendable {
    // MARK: - State Colors

    public var active: Color
    public var inactive: Color
    public var selected: Color
    public var focused: Color

    // MARK: - Feedback Colors

    public var positive: Color
    public var negative: Color
    public var caution: Color
    public var informational: Color

    // MARK: - Depth Colors

    public var elevated: Color
    public var submerged: Color
    public var overlay: Color

    // MARK: - Border Colors

    public var borderDefault: Color
    public var borderSubtle: Color
    public var borderStrong: Color

    // MARK: - Text Hierarchy

    public var textPrimary: Color
    public var textSecondary: Color
    public var textTertiary: Color
    public var textDisabled: Color
    public var textInverse: Color
    public var textLink: Color

    // MARK: - Initialization

    public init(
        active: Color = .blue,
        inactive: Color = .gray,
        selected: Color = .blue.opacity(0.2),
        focused: Color = .blue.opacity(0.3),
        positive: Color = .green,
        negative: Color = .red,
        caution: Color = .orange,
        informational: Color = .cyan,
        elevated: Color = .white,
        submerged: Color = .black.opacity(0.02),
        overlay: Color = .black.opacity(0.4),
        borderDefault: Color = .gray.opacity(0.3),
        borderSubtle: Color = .gray.opacity(0.1),
        borderStrong: Color = .gray.opacity(0.6),
        textPrimary: Color = .primary,
        textSecondary: Color = .secondary,
        textTertiary: Color = .gray,
        textDisabled: Color = .gray.opacity(0.5),
        textInverse: Color = .white,
        textLink: Color = .blue
    ) {
        self.active = active
        self.inactive = inactive
        self.selected = selected
        self.focused = focused
        self.positive = positive
        self.negative = negative
        self.caution = caution
        self.informational = informational
        self.elevated = elevated
        self.submerged = submerged
        self.overlay = overlay
        self.borderDefault = borderDefault
        self.borderSubtle = borderSubtle
        self.borderStrong = borderStrong
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textDisabled = textDisabled
        self.textInverse = textInverse
        self.textLink = textLink
    }

    // MARK: - Dark Mode Variant

    public static var dark: PrismSemanticColors {
        PrismSemanticColors(
            active: .blue.opacity(0.8),
            inactive: .gray.opacity(0.5),
            selected: .blue.opacity(0.3),
            focused: .blue.opacity(0.4),
            positive: .green.opacity(0.8),
            negative: .red.opacity(0.8),
            caution: .orange.opacity(0.8),
            informational: .cyan.opacity(0.8),
            elevated: .white.opacity(0.1),
            submerged: .black.opacity(0.3),
            overlay: .black.opacity(0.6),
            borderDefault: .gray.opacity(0.4),
            borderSubtle: .gray.opacity(0.2),
            borderStrong: .gray.opacity(0.7),
            textPrimary: .white,
            textSecondary: .gray.opacity(0.8),
            textTertiary: .gray.opacity(0.6),
            textDisabled: .gray.opacity(0.4),
            textInverse: .black,
            textLink: .blue.opacity(0.8)
        )
    }

    // MARK: - High Contrast Variant

    public static var highContrast: PrismSemanticColors {
        PrismSemanticColors(
            active: .yellow,
            inactive: .gray,
            selected: .purple.opacity(0.3),
            focused: .yellow.opacity(0.4),
            positive: .green,
            negative: .red,
            caution: .yellow,
            informational: .cyan,
            elevated: .white,
            submerged: .black.opacity(0.1),
            overlay: .black.opacity(0.8),
            borderDefault: .white,
            borderSubtle: .gray.opacity(0.5),
            borderStrong: .white,
            textPrimary: .white,
            textSecondary: .gray,
            textTertiary: .gray.opacity(0.7),
            textDisabled: .gray.opacity(0.3),
            textInverse: .black,
            textLink: .yellow
        )
    }
}

// MARK: - PrismColorProtocol Extension

extension PrismColorProtocol {
    public var semanticDark: PrismSemanticColors {
        .dark
    }

    public var semanticHighContrast: PrismSemanticColors {
        .highContrast
    }
}
