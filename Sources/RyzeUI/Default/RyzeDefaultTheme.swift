//
//  RyzeTheme.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import RyzeFoundation
import SwiftUI

public struct RyzeTheme: RyzeThemeProtocol, Sendable {
    public var color: RyzeColorProtocol
    public var spacing: RyzeSpacingProtocol
    public var radius: RyzeRadiusProtocol
    public var size: RyzeSizeProtocol
    public var locale: RyzeLocale
    public var animation: Animation?
    public var feedback: SensoryFeedback
    public var colorScheme: ColorScheme?
    public var tokens: RyzeDesignTokens

    public init(
        color: RyzeColorProtocol = RyzeDefaultColor(),
        spacing: RyzeSpacingProtocol = RyzeDefaultSpacing(),
        radius: RyzeRadiusProtocol = RyzeDefaultRadius(),
        size: RyzeSizeProtocol = RyzeDefaultSize(),
        locale: RyzeLocale = .current,
        animation: Animation? = .spring(duration: 0.35, bounce: 0.25),
        feedback: SensoryFeedback = .impact,
        colorScheme: ColorScheme? = nil,
        tokens: RyzeDesignTokens = .default
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

    public static var `default`: RyzeTheme {
        RyzeTheme()
    }

    public static var dark: RyzeTheme {
        RyzeTheme(
            color: RyzeDefaultColor.dark,
            colorScheme: .dark
        )
    }

    public static var highContrast: RyzeTheme {
        RyzeTheme(
            color: RyzeDefaultColor.highContrast,
            animation: .linear(duration: 0.2),
            feedback: .success
        )
    }

    public static var compact: RyzeTheme {
        RyzeTheme(tokens: .compact)
    }

    public static var expanded: RyzeTheme {
        RyzeTheme(tokens: .expanded)
    }

    public func with(color: RyzeColorProtocol) -> RyzeTheme {
        RyzeTheme(
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

    public func with(colorScheme: ColorScheme?) -> RyzeTheme {
        RyzeTheme(
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

    public func with(animation: Animation?) -> RyzeTheme {
        RyzeTheme(
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

    public func with(tokens: RyzeDesignTokens) -> RyzeTheme {
        RyzeTheme(
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

extension RyzeThemeProtocol {
    public func eraseToAnyTheme() -> RyzeTheme {
        RyzeTheme(
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
