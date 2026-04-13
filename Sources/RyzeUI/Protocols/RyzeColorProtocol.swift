//
//  RyzeColorProtocol.swift
//  Ryze
//
//  Created by Rafael Escaleira on 18/04/25.
//

import SwiftUI

public protocol RyzeColorProtocol: Sendable {
    // MARK: - Brand Colors
    var primary: Color { get set }
    var secondary: Color { get set }
    var accent: Color { get set }

    // MARK: - Background Colors
    var background: Color { get set }
    var backgroundSecondary: Color { get set }
    var surface: Color { get set }

    // MARK: - Text Colors
    var text: Color { get set }
    var textSecondary: Color { get set }
    var textTertiary: Color { get set }
    var textInverse: Color { get set }

    // MARK: - Border Colors
    var border: Color { get set }
    var borderSubtle: Color { get set }
    var borderStrong: Color { get set }

    // MARK: - State Colors
    var disabled: Color { get set }
    var hover: Color { get set }
    var pressed: Color { get set }
    var selected: Color { get set }

    // MARK: - Feedback Colors
    var error: Color { get set }
    var success: Color { get set }
    var warning: Color { get set }
    var info: Color { get set }

    // MARK: - Utility Colors
    var shadow: Color { get set }
    var white: Color { get set }
    var black: Color { get set }

    // MARK: - Gradients (Default Implementations)
    var gradient: RyzeGradient { get }
    var gradientSecondary: RyzeGradient { get }
    var gradientDestructive: RyzeGradient { get }
    var gradientSuccess: RyzeGradient { get }

    // MARK: - Semantic Colors (Default Implementations)
    var semantic: RyzeSemanticColors { get }
}

// MARK: - Default Implementations

extension RyzeColorProtocol {
    public var accent: Color { primary }
    public var textTertiary: Color { disabled }
    public var textInverse: Color { white }
    public var borderSubtle: Color { border.opacity(0.5) }
    public var borderStrong: Color { border.opacity(0.8) }
    public var selected: Color { primary.opacity(0.2) }
    public var gradient: RyzeGradient { .primary }
    public var gradientSecondary: RyzeGradient { .secondary }
    public var gradientDestructive: RyzeGradient { .destructive }
    public var gradientSuccess: RyzeGradient { .success }
    public var semantic: RyzeSemanticColors {
        RyzeSemanticColors(
            borderDefault: border,
            borderSubtle: borderSubtle,
            borderStrong: borderStrong,
            textPrimary: text,
            textSecondary: textSecondary,
            textTertiary: textTertiary
        )
    }
}
