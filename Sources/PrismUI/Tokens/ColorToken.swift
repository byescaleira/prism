import SwiftUI

/// Semantic color tokens following Apple HIG color roles.
///
/// Each case maps to a semantic purpose, not a specific hue.
/// The theme resolves each token to a concrete `Color`.
public enum ColorToken: String, Sendable, CaseIterable {

    // MARK: - Brand

    case brand
    case brandVariant

    // MARK: - Backgrounds

    case background
    case backgroundSecondary
    case backgroundTertiary

    // MARK: - Surfaces

    case surface
    case surfaceSecondary
    case surfaceElevated

    // MARK: - Content (text & icons)

    case onBackground
    case onBackgroundSecondary
    case onBackgroundTertiary
    case onSurface
    case onSurfaceSecondary
    case onBrand

    // MARK: - Borders & Separators

    case border
    case borderSubtle
    case separator

    // MARK: - Interactive States

    case interactive
    case interactiveHover
    case interactivePressed
    case interactiveDisabled

    // MARK: - Feedback

    case success
    case warning
    case error
    case info

    // MARK: - Utility

    case shadow
    case overlay
}
