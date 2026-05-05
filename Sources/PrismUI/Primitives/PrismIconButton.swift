import SwiftUI

/// Compact circular icon button with theme-aware styling.
///
/// ```swift
/// PrismIconButton("heart.fill", variant: .filled) {
///     toggleFavorite()
/// }
/// ```
public struct PrismIconButton: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private let systemName: String
    private let variant: PrismButtonVariant
    private let size: Size
    private let role: ButtonRole?
    private let action: () -> Void

    /// Creates an icon button with a system image, variant, size, and action.
    public init(
        _ systemName: String,
        variant: PrismButtonVariant = .tinted,
        size: Size = .regular,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.variant = variant
        self.size = size
        self.role = role
        self.action = action
    }

    /// The content and behavior of the icon button.
    public var body: some View {
        Button(role: role, action: action) {
            Image(systemName: systemName)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundStyle(foregroundColor)
                .frame(width: size.frameSize, height: size.frameSize)
                .background(backgroundColor, in: Circle())
                .overlay(borderOverlay)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(Text(systemName))
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if variant == .bordered {
            Circle().stroke(theme.color(.border), lineWidth: 1)
        }
    }

    private var foregroundColor: Color {
        let color: Color = role == .destructive ? theme.color(.error) : theme.color(.interactive)
        return isEnabled ? color : color.opacity(0.4)
    }

    private var backgroundColor: Color {
        switch variant {
        case .filled:
            return role == .destructive ? theme.color(.error) : theme.color(.interactive)
        case .tinted:
            return (role == .destructive ? theme.color(.error) : theme.color(.interactive)).opacity(0.12)
        default:
            return .clear
        }
    }
}

extension PrismIconButton {
    /// Predefined icon button sizes.
    public enum Size: Sendable {
        /// Represents a compact 32pt icon button.
        case small
        /// Represents a standard 40pt icon button.
        case regular
        /// Represents a large 52pt icon button.
        case large

        var iconSize: CGFloat {
            switch self {
            case .small: 14
            case .regular: 18
            case .large: 22
            }
        }

        var frameSize: CGFloat {
            switch self {
            case .small: 32
            case .regular: 40
            case .large: 52
            }
        }
    }
}
