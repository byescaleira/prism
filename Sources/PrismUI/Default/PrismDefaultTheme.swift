//
//  PrismTheme.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import PrismFoundation
import SwiftUI

public struct PrismTheme: PrismThemeProtocol, Sendable {
    public var color: PrismColorProtocol
    public var spacing: PrismSpacingProtocol
    public var radius: PrismRadiusProtocol
    public var size: PrismSizeProtocol
    public var locale: PrismLocale
    public var animation: Animation?
    public var feedback: SensoryFeedback
    public var colorScheme: ColorScheme?
    public var tokens: PrismDesignTokens

    public init(
        color: PrismColorProtocol = PrismDefaultColor(),
        spacing: PrismSpacingProtocol = PrismDefaultSpacing(),
        radius: PrismRadiusProtocol = PrismDefaultRadius(),
        size: PrismSizeProtocol = PrismDefaultSize(),
        locale: PrismLocale = .current,
        animation: Animation? = .spring(duration: 0.35, bounce: 0.25),
        feedback: SensoryFeedback = .impact,
        colorScheme: ColorScheme? = nil,
        tokens: PrismDesignTokens = .default
    ) {
        self.color = color
        self.spacing = spacing
        self.radius = radius
        self.size = size
        self.locale = locale
        self.animation = animation
        self.feedback = feedback
        self.colorScheme = colorScheme
        self.tokens = tokens
    }

    public static var `default`: PrismTheme {
        PrismTheme()
    }

    public static var dark: PrismTheme {
        PrismTheme(
            color: PrismDefaultColor.dark,
            colorScheme: .dark
        )
    }

    public static var highContrast: PrismTheme {
        PrismTheme(
            color: PrismDefaultColor.highContrast,
            animation: .linear(duration: 0.2),
            feedback: .success
        )
    }

    public static var compact: PrismTheme {
        PrismTheme(tokens: .compact)
    }

    public static var expanded: PrismTheme {
        PrismTheme(tokens: .expanded)
    }

    public func with(color: PrismColorProtocol) -> PrismTheme {
        PrismTheme(
            color: color,
            spacing: spacing,
            radius: radius,
            size: size,
            locale: locale,
            animation: animation,
            feedback: feedback,
            colorScheme: colorScheme,
            tokens: tokens
        )
    }

    public func with(colorScheme: ColorScheme?) -> PrismTheme {
        PrismTheme(
            color: color,
            spacing: spacing,
            radius: radius,
            size: size,
            locale: locale,
            animation: animation,
            feedback: feedback,
            colorScheme: colorScheme,
            tokens: tokens
        )
    }

    public func with(animation: Animation?) -> PrismTheme {
        PrismTheme(
            color: color,
            spacing: spacing,
            radius: radius,
            size: size,
            locale: locale,
            animation: animation,
            feedback: feedback,
            colorScheme: colorScheme,
            tokens: tokens
        )
    }

    public func with(tokens: PrismDesignTokens) -> PrismTheme {
        PrismTheme(
            color: color,
            spacing: spacing,
            radius: radius,
            size: size,
            locale: locale,
            animation: animation,
            feedback: feedback,
            colorScheme: colorScheme,
            tokens: tokens
        )
    }
}

extension PrismThemeProtocol {
    public func eraseToAnyTheme() -> PrismTheme {
        PrismTheme(
            color: color,
            spacing: spacing,
            radius: radius,
            size: size,
            locale: locale,
            animation: animation,
            feedback: feedback,
            colorScheme: colorScheme,
            tokens: tokens
        )
    }
}
