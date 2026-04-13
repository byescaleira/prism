//
//  PrismButtonStyle.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

public enum PrismButtonVariant: Sendable {
    case primary
    case secondary
}

public struct PrismButtonChromeStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    @Environment(\.layoutTier) private var layoutTier

    private let variant: PrismButtonVariant
    private let role: ButtonRole?

    public init(
        variant: PrismButtonVariant,
        role: ButtonRole? = nil
    ) {
        self.variant = variant
        self.role = role
    }

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
            .contentShape(.capsule)
            .containerShape(.capsule)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(theme.animation, value: configuration.isPressed)
    }

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

    @ViewBuilder
    private func background(isPressed: Bool) -> some View {
        switch variant {
        case .primary:
            Capsule()
                .fill(accentColor.opacity(isPressed ? 0.88 : 1))
                .shadow(
                    color: theme.color.shadow.opacity(isPressed ? 0.08 : 0.16),
                    radius: isPressed ? 4 : 10,
                    y: isPressed ? 1 : 4
                )

        case .secondary:
            Capsule()
                .fill(theme.color.surface.opacity(isPressed ? 0.92 : 0.84))
                .background(.ultraThinMaterial, in: Capsule())
        }
    }

    @ViewBuilder
    private func border(isPressed: Bool) -> some View {
        switch variant {
        case .primary:
            EmptyView()
        case .secondary:
            Capsule()
                .stroke(
                    accentColor.opacity(isPressed ? 0.45 : 0.28),
                    lineWidth: 1
                )
        }
    }
}
