//
//  RyzePlaygroundTheme.swift
//  RyzePlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import RyzeFoundation
import RyzeUI
import SwiftUI

/// Design System customizado para o RyzePlayground
///
/// Este tema demonstra como criar uma identidade visual única
/// usando o sistema de tokens do RyzeUI como base.
struct RyzePlaygroundTheme: RyzeThemeProtocol {
    let tokens: RyzeDesignTokens
    let locale: RyzeLocale = .portugueseBR
    let feedback: SensoryFeedback = .success
    let colorScheme: ColorScheme? = nil

    init() {
        self.tokens = RyzeDesignTokens(
            spacing: [
                .none: 0,
                .extraSmall: 4,
                .small: 8,
                .medium: 16,
                .large: 24,
                .extraLarge: 32,
                .ultraLarge: 48,
                .section: 64
            ],
            radius: [
                .none: 0,
                .small: 8,
                .medium: 12,
                .large: 16,
                .extraLarge: 24,
                .circle: .infinity
            ],
            fontSizes: [
                .caption2: 11,
                .caption: 12,
                .footnote: 13,
                .body: 16,
                .title3: 18,
                .title2: 20,
                .title: 24,
                .largeTitle: 32
            ]
        )
    }

    var color: any RyzeColorProtocol {
        RyzePlaygroundColors()
    }

    var spacing: any RyzeSpacingProtocol {
        RyzePlaygroundSpacing()
    }

    var radius: any RyzeRadiusProtocol {
        RyzePlaygroundRadius()
    }

    var size: any RyzeSizeProtocol {
        RyzePlaygroundSize()
    }

    var animation: Animation? {
        .smooth(duration: 0.35)
    }
}

// MARK: - Cores do Playground

private struct RyzePlaygroundColors: RyzeColorProtocol {
    // Cores primárias com identidade própria
    var primary: Color
    var secondary: Color
    var accent: Color

    // Backgrounds
    var background: Color
    var backgroundSecondary: Color
    var surface: Color

    // Textos
    var text: Color
    var textSecondary: Color
    var textTertiary: Color
    var textInverse: Color

    // Borders
    var border: Color
    var borderStrong: Color
    var borderSubtle: Color

    // States
    var disabled: Color
    var hover: Color
    var pressed: Color
    var selected: Color

    // Semânticas
    var error: Color
    var warning: Color
    var success: Color
    var info: Color

    // Utility
    var shadow: Color
    var white: Color
    var black: Color

    // Gradients
    var gradient: RyzeGradient { .primary }
    var gradientSecondary: RyzeGradient { .secondary }
    var gradientDestructive: RyzeGradient { .destructive }
    var gradientSuccess: RyzeGradient { .success }

    init() {
        self.primary = .init(red: 0.2, green: 0.4, blue: 0.9)
        self.secondary = .init(red: 0.6, green: 0.3, blue: 0.8)
        self.accent = .init(red: 0.9, green: 0.3, blue: 0.5)

        self.background = Color.black.opacity(0.02)
        self.backgroundSecondary = Color.white
        self.surface = Color.white

        self.text = .init(red: 0.1, green: 0.1, blue: 0.15)
        self.textSecondary = .init(red: 0.4, green: 0.4, blue: 0.45)
        self.textTertiary = .init(red: 0.6, green: 0.6, blue: 0.65)
        self.textInverse = .white

        self.border = Color.black.opacity(0.1)
        self.borderStrong = Color.black.opacity(0.2)
        self.borderSubtle = Color.black.opacity(0.05)

        self.disabled = Color.black.opacity(0.3)
        self.hover = .init(red: 0.2, green: 0.4, blue: 0.9).opacity(0.08)
        self.pressed = .init(red: 0.2, green: 0.4, blue: 0.9).opacity(0.2)
        self.selected = .init(red: 0.2, green: 0.4, blue: 0.9).opacity(0.15)

        self.error = .init(red: 0.9, green: 0.2, blue: 0.3)
        self.warning = .init(red: 1.0, green: 0.6, blue: 0.0)
        self.success = .init(red: 0.1, green: 0.7, blue: 0.4)
        self.info = .init(red: 0.0, green: 0.5, blue: 0.9)

        self.shadow = Color.black.opacity(0.2)
        self.white = .white
        self.black = .black
    }
}

// MARK: - Spacing Protocol

private struct RyzePlaygroundSpacing: RyzeSpacingProtocol {
    var none: CGFloat { 0 }
    var extraSmall: CGFloat { 4 }
    var small: CGFloat { 8 }
    var medium: CGFloat { 16 }
    var large: CGFloat { 24 }
    var extraLarge: CGFloat { 32 }
    var ultraLarge: CGFloat { 48 }
    var section: CGFloat { 64 }
}

// MARK: - Radius Protocol

private struct RyzePlaygroundRadius: RyzeRadiusProtocol {
    var none: CGFloat { 0 }
    var small: CGFloat { 8 }
    var medium: CGFloat { 12 }
    var large: CGFloat { 16 }
    var extraLarge: CGFloat { 24 }
    var circle: CGFloat { .infinity }
}

// MARK: - Size Protocol

private struct RyzePlaygroundSize: RyzeSizeProtocol {
    var ultraSmall: CGFloat { 24 }
    var ultraSmall2: CGFloat { 28 }
    var extraSmall: CGFloat { 32 }
    var extraSmall2: CGFloat { 36 }
    var small: CGFloat { 40 }
    var small2: CGFloat { 44 }
    var medium: CGFloat { 48 }
    var medium2: CGFloat { 52 }
    var large: CGFloat { 56 }
    var large2: CGFloat { 64 }
    var extraLarge: CGFloat { 72 }
    var extraLarge2: CGFloat { 80 }
    var ultraLarge: CGFloat { 96 }
    var max: CGFloat { .infinity }
}
