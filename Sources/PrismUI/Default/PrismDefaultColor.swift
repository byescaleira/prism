//
//  PrismDefaultColor.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import SwiftUI

public struct PrismDefaultColor: PrismColorProtocol {

    // MARK: - Static Asset Helper

    @usableFromInline
    static func asset(_ name: String) -> Color {
        Color(name, bundle: .module)
    }

    // MARK: - Brand Colors

    public var primary: Color
    public var secondary: Color
    public var accent: Color

    // MARK: - Background Colors

    public var background: Color
    public var backgroundSecondary: Color
    public var surface: Color

    // MARK: - Text Colors

    public var text: Color
    public var textSecondary: Color
    public var textTertiary: Color
    public var textInverse: Color

    // MARK: - Border Colors

    public var border: Color
    public var borderSubtle: Color
    public var borderStrong: Color

    // MARK: - State Colors

    public var disabled: Color
    public var hover: Color
    public var pressed: Color
    public var selected: Color

    // MARK: - Feedback Colors

    public var error: Color
    public var success: Color
    public var warning: Color
    public var info: Color

    // MARK: - Utility Colors

    public var shadow: Color
    public var white: Color
    public var black: Color

    // MARK: - Initialization

    public init(
        // Brand
        primary: Color = Self.asset("Primary"),
        secondary: Color = Self.asset("Secondary"),
        accent: Color = Self.asset("Accent"),
        // Background
        background: Color = Self.asset("Background"),
        backgroundSecondary: Color = Self.asset("BackgroundSecondary"),
        surface: Color = Self.asset("Surface"),
        // Text
        text: Color = .primary,
        textSecondary: Color = .secondary,
        textTertiary: Color = .gray,
        textInverse: Color = .white,
        // Border
        border: Color = Self.asset("Border"),
        borderSubtle: Color = Self.asset("Border").opacity(0.5),
        borderStrong: Color = Self.asset("Border").opacity(0.8),
        // State
        disabled: Color = Self.asset("Disabled"),
        hover: Color = Self.asset("Hover"),
        pressed: Color = Self.asset("Pressed"),
        selected: Color = Self.asset("Primary").opacity(0.2),
        // Feedback
        error: Color = Self.asset("Error"),
        success: Color = Self.asset("Success"),
        warning: Color = Self.asset("Warning"),
        info: Color = Self.asset("Info"),
        // Utility
        shadow: Color = Self.asset("Shadow"),
        white: Color = .white,
        black: Color = .black
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
        self.backgroundSecondary = backgroundSecondary
        self.surface = surface
        self.text = text
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textInverse = textInverse
        self.border = border
        self.borderSubtle = borderSubtle
        self.borderStrong = borderStrong
        self.disabled = disabled
        self.hover = hover
        self.pressed = pressed
        self.selected = selected
        self.error = error
        self.success = success
        self.warning = warning
        self.info = info
        self.shadow = shadow
        self.white = white
        self.black = black
    }

    // MARK: - Dark Theme

    public static var dark: PrismDefaultColor {
        PrismDefaultColor(
            primary: Color(red: 0.4, green: 0.6, blue: 1.0),
            secondary: Color(red: 0.5, green: 0.5, blue: 0.6),
            accent: Color(red: 0.5, green: 0.7, blue: 1.0),
            background: Color(red: 0.05, green: 0.05, blue: 0.08),
            backgroundSecondary: Color(red: 0.1, green: 0.1, blue: 0.15),
            surface: Color(red: 0.12, green: 0.12, blue: 0.18),
            text: .white,
            textSecondary: Color.gray.opacity(0.8),
            textTertiary: Color.gray.opacity(0.6),
            textInverse: .black,
            border: Color.gray.opacity(0.3),
            borderSubtle: Color.gray.opacity(0.15),
            borderStrong: Color.gray.opacity(0.5),
            disabled: Color.gray.opacity(0.4),
            hover: Color.white.opacity(0.1),
            pressed: Color.white.opacity(0.15),
            selected: Color.blue.opacity(0.3),
            error: Color(red: 1.0, green: 0.4, blue: 0.4),
            success: Color(red: 0.4, green: 1.0, blue: 0.5),
            warning: Color(red: 1.0, green: 0.7, blue: 0.3),
            info: Color(red: 0.3, green: 0.8, blue: 1.0),
            shadow: .black,
            white: .white,
            black: .black
        )
    }

    // MARK: - High Contrast Theme

    public static var highContrast: PrismDefaultColor {
        PrismDefaultColor(
            primary: .yellow,
            secondary: .gray,
            accent: .cyan,
            background: .black,
            backgroundSecondary: Color.gray.opacity(0.2),
            surface: Color.gray.opacity(0.3),
            text: .white,
            textSecondary: .white.opacity(0.9),
            textTertiary: .white.opacity(0.7),
            textInverse: .black,
            border: .white,
            borderSubtle: .white.opacity(0.5),
            borderStrong: .white,
            disabled: .gray.opacity(0.5),
            hover: .white.opacity(0.2),
            pressed: .white.opacity(0.3),
            selected: .purple.opacity(0.4),
            error: .red,
            success: .green,
            warning: .yellow,
            info: .cyan,
            shadow: .black,
            white: .white,
            black: .black
        )
    }
}
