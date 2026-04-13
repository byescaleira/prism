//
//  RyzeDesignTokens.swift
//  Ryze
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

// MARK: - Token Types

public enum SpacingToken: CaseIterable, Sendable {
    case none, extraSmall, small, medium, large, extraLarge, ultraLarge, section
}

public enum RadiusToken: CaseIterable, Sendable {
    case none, small, medium, large, extraLarge, circle
}

public enum FontSizeToken: CaseIterable, Sendable {
    case caption2, caption, footnote, body, title3, title2, title, largeTitle
}

public enum MotionToken: CaseIterable, Sendable {
    case instant, fast, normal, slow
}

// MARK: - Design Tokens

public struct RyzeDesignTokens: Equatable, Sendable {

    // MARK: - Spacing Scale (8pt grid system)
    public let spacing: [SpacingToken: CGFloat]

    // MARK: - Radius Scale
    public let radius: [RadiusToken: CGFloat]

    // MARK: - Font Sizes (Dynamic Type base)
    public let fontSizes: [FontSizeToken: CGFloat]

    // MARK: - Motion Durations
    public let durations: [MotionToken: TimeInterval]

    // MARK: - Breakpoints
    public let breakpoints: [Breakpoint: CGFloat]

    // MARK: - Initialization

    public init(
        spacing: [SpacingToken: CGFloat] = defaultSpacing,
        radius: [RadiusToken: CGFloat] = defaultRadius,
        fontSizes: [FontSizeToken: CGFloat] = defaultFontSizes,
        durations: [MotionToken: TimeInterval] = defaultDurations,
        breakpoints: [Breakpoint: CGFloat] = defaultBreakpoints
    ) {
        self.spacing = spacing
        self.radius = radius
        self.fontSizes = fontSizes
        self.durations = durations
        self.breakpoints = breakpoints
    }

    // MARK: - Default Values

    public static let `default` = RyzeDesignTokens()

    public static var compact: RyzeDesignTokens {
        RyzeDesignTokens(
            spacing: [
                .none: 0,
                .extraSmall: 4,
                .small: 8,
                .medium: 12,
                .large: 16,
                .extraLarge: 20,
                .ultraLarge: 24,
                .section: 32,
            ],
            radius: [
                .none: 0,
                .small: 6,
                .medium: 10,
                .large: 14,
                .extraLarge: 20,
                .circle: .infinity,
            ],
            fontSizes: [
                .caption2: 11,
                .caption: 12,
                .footnote: 13,
                .body: 15,
                .title3: 17,
                .title2: 19,
                .title: 22,
                .largeTitle: 28,
            ]
        )
    }

    public static var expanded: RyzeDesignTokens {
        RyzeDesignTokens(
            spacing: [
                .none: 0,
                .extraSmall: 6,
                .small: 12,
                .medium: 18,
                .large: 24,
                .extraLarge: 36,
                .ultraLarge: 54,
                .section: 72,
            ],
            radius: [
                .none: 0,
                .small: 8,
                .medium: 12,
                .large: 18,
                .extraLarge: 26,
                .circle: .infinity,
            ],
            fontSizes: [
                .caption2: 12,
                .caption: 14,
                .footnote: 15,
                .body: 17,
                .title3: 20,
                .title2: 24,
                .title: 28,
                .largeTitle: 36,
            ],
            durations: [
                .instant: 0.1,
                .fast: 0.25,
                .normal: 0.4,
                .slow: 0.6,
            ]
        )
    }

    // MARK: - Default Configurations

    public static let defaultSpacing: [SpacingToken: CGFloat] = [
        .none: 0,
        .extraSmall: 4,
        .small: 8,
        .medium: 16,
        .large: 24,
        .extraLarge: 32,
        .ultraLarge: 48,
        .section: 64,
    ]

    public static let defaultRadius: [RadiusToken: CGFloat] = [
        .none: 0,
        .small: 4,
        .medium: 8,
        .large: 16,
        .extraLarge: 24,
        .circle: .infinity,
    ]

    public static let defaultFontSizes: [FontSizeToken: CGFloat] = [
        .caption2: 11,
        .caption: 12,
        .footnote: 13,
        .body: 16,
        .title3: 18,
        .title2: 20,
        .title: 24,
        .largeTitle: 32,
    ]

    public static let defaultDurations: [MotionToken: TimeInterval] = [
        .instant: 0.05,
        .fast: 0.15,
        .normal: 0.3,
        .slow: 0.5,
    ]

    public static let defaultBreakpoints: [Breakpoint: CGFloat] = [
        .phoneCompact: 375,
        .phoneMax: 430,
        .tabletCompact: 768,
        .tabletMax: 1024,
        .desktop: 1440,
    ]

    // MARK: - Convenience Accessors

    public func spacing(for token: SpacingToken) -> CGFloat {
        spacing[token] ?? 0
    }

    public func radius(for token: RadiusToken) -> CGFloat {
        radius[token] ?? 0
    }

    public func fontSize(for token: FontSizeToken) -> CGFloat {
        fontSizes[token] ?? 16
    }

    public func duration(for token: MotionToken) -> TimeInterval {
        durations[token] ?? 0.3
    }

    public func animation(for token: MotionToken) -> Animation {
        .easeInOut(duration: duration(for: token))
    }

    public func breakpoint(for breakpoint: Breakpoint) -> CGFloat {
        breakpoints[breakpoint] ?? 0
    }

    public func layoutTier(for width: CGFloat) -> RyzeLayoutTier {
        let tabletCompact = breakpoint(for: .tabletCompact)
        let desktop = breakpoint(for: .desktop)

        return switch width {
        case ..<tabletCompact:
            RyzeLayoutTier.compact
        case tabletCompact..<desktop:
            RyzeLayoutTier.regular
        default:
            RyzeLayoutTier.expansive
        }
    }
}

// MARK: - Breakpoint

public enum Breakpoint: CaseIterable, Sendable {
    case phoneCompact
    case phoneMax
    case tabletCompact
    case tabletMax
    case desktop
}
