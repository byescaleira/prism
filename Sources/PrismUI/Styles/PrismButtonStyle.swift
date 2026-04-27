//
//  PrismButtonStyle.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

/// Button visual variant.
public enum PrismButtonVariant: Sendable {
    /// Filled, high-emphasis button for primary actions.
    case primary
    /// Outlined, low-emphasis button for secondary actions.
    case secondary
}

/// Chrome style for buttons.
///
/// The style adapts its shape and interaction feedback per platform:
/// - **iOS / watchOS / tvOS**: Capsule shape with scale-on-press.
/// - **macOS / visionOS**: Rounded rectangle using `theme.radius.large`
///   with subtler shadows and no scale effect.
public struct PrismButtonChromeStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    @Environment(\.layoutTier) private var layoutTier
    @Environment(\.platformContext) private var platformContext

    private let variant: PrismButtonVariant
    private let role: ButtonRole?

    /// Creates a chrome button style with the given variant and optional role.
    ///
    /// - Parameters:
    ///   - variant: The visual variant (primary or secondary).
    ///   - role: An optional button role such as `.destructive`. Defaults to `nil`.
    public init(
        variant: PrismButtonVariant,
        role: ButtonRole? = nil
    ) {
        self.variant = variant
        self.role = role
    }

    // MARK: - Platform-Adaptive Shape

    /// Returns a capsule on iOS/watchOS/tvOS and a rounded rectangle on macOS/visionOS.
    ///
    /// Using `AnyShape` so the same value works with both `.fill()` and `.stroke()`.
    private var adaptiveShape: AnyShape {
        switch platformContext.platform {
        case .macOS, .visionOS:
            AnyShape(RoundedRectangle(cornerRadius: theme.radius.large))
        case .iOS, .watchOS, .tvOS:
            AnyShape(Capsule())
        }
    }

    /// Whether the current platform uses a scale-down press effect.
    ///
    /// macOS and visionOS buttons feel more native without a scale animation;
    /// only iOS, watchOS, and tvOS apply it.
    private var usesScaleEffect: Bool {
        switch platformContext.platform {
        case .iOS, .watchOS, .tvOS:
            true
        case .macOS, .visionOS:
            false
        }
    }

    /// Shadow radius tuned per platform. macOS/visionOS uses subtler values.
    private func shadowRadius(isPressed: Bool) -> CGFloat {
        switch platformContext.platform {
        case .macOS, .visionOS:
            isPressed ? 2 : 6
        case .iOS, .watchOS, .tvOS:
            isPressed ? 4 : 10
        }
    }

    // MARK: - Body

    /// Creates the styled button view with theme-aware colors, padding, and press animations.
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .padding(.horizontal, layoutTier.horizontalPadding)
            .padding(.vertical, layoutTier.verticalPadding)
            .foregroundStyle(foregroundColor)
            .background {
                background(isPressed: configuration.isPressed)
            }
            .overlay {
                border(isPressed: configuration.isPressed)
            }
            .contentShape(adaptiveShape)
            .adaptiveContainerShape(
                platform: platformContext.platform,
                cornerRadius: theme.radius.large
            )
            .scaleEffect(
                usesScaleEffect && configuration.isPressed ? 0.98 : 1
            )
            .animation(theme.animation, value: configuration.isPressed)
    }

    // MARK: - Colors

    private var accentColor: Color {
        switch role {
        case .destructive:
            theme.color.error
        default:
            theme.color.primary
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:
            theme.color.textInverse
        case .secondary:
            accentColor
        }
    }

    // MARK: - Background & Border

    @ViewBuilder
    private func background(isPressed: Bool) -> some View {
        switch variant {
        case .primary:
            adaptiveShape
                .fill(accentColor.opacity(isPressed ? 0.88 : 1))
                .shadow(
                    color: theme.color.shadow.opacity(isPressed ? 0.08 : 0.16),
                    radius: shadowRadius(isPressed: isPressed),
                    y: isPressed ? 1 : 4
                )

        case .secondary:
            adaptiveShape
                .fill(theme.color.surface.opacity(isPressed ? 0.92 : 0.84))
                .background(.ultraThinMaterial, in: adaptiveShape)
        }
    }

    @ViewBuilder
    private func border(isPressed: Bool) -> some View {
        switch variant {
        case .primary:
            EmptyView()
        case .secondary:
            adaptiveShape
                .stroke(
                    accentColor.opacity(isPressed ? 0.45 : 0.28),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Adaptive Container Shape

/// `.containerShape()` requires `RoundedRectangularShape`, which `AnyShape` does not
/// satisfy. This extension applies the correct concrete type per platform so the
/// container shape propagates to child views (e.g., context menus, popovers).
extension View {
    @ViewBuilder
    fileprivate func adaptiveContainerShape(
        platform: PrismPlatform,
        cornerRadius: CGFloat
    ) -> some View {
        switch platform {
        case .macOS, .visionOS:
            self.containerShape(RoundedRectangle(cornerRadius: cornerRadius))
        case .iOS, .watchOS, .tvOS:
            self.containerShape(.capsule)
        }
    }
}
