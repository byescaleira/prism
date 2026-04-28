import SwiftUI

/// A themed button with variant styles, loading state, haptic feedback, and built-in accessibility.
public struct PrismButton<Label: View>: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let action: () async -> Void
    private let label: Label
    private let variant: PrismButtonVariant
    private let role: ButtonRole?
    private let haptic: PrismButtonHaptic

    @State private var isLoading = false
    @State private var isPressed = false

    public init(
        _ title: LocalizedStringKey,
        variant: PrismButtonVariant = .filled,
        role: ButtonRole? = nil,
        haptic: PrismButtonHaptic = .light,
        action: @escaping () async -> Void
    ) where Label == Text {
        self.label = Text(title)
        self.variant = variant
        self.role = role
        self.haptic = haptic
        self.action = action
    }

    public init(
        variant: PrismButtonVariant = .filled,
        role: ButtonRole? = nil,
        haptic: PrismButtonHaptic = .light,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.variant = variant
        self.role = role
        self.haptic = haptic
        self.action = action
    }

    public var body: some View {
        let button = Button(role: role) {
            guard !isLoading else { return }
            triggerHaptic()
            isLoading = true
            Task {
                await action()
                isLoading = false
            }
        } label: {
            buttonContent
        }
        .disabled(!isEnabled || isLoading)

        switch variant {
        case .glass:
            button.buttonStyle(.glass)
        case .glassProminent:
            button.buttonStyle(.glassProminent)
        default:
            button.buttonStyle(PrismButtonStyle(
                variant: variant,
                theme: theme,
                isLoading: isLoading,
                reduceMotion: reduceMotion
            ))
        }
    }

    @ViewBuilder
    private var buttonContent: some View {
        if isLoading {
            ProgressView()
                .controlSize(.small)
                .tint(labelColor)
        } else {
            label
        }
    }

    private var labelColor: Color {
        switch variant {
        case .filled: theme.color(.onBrand)
        case .glass, .glassProminent: theme.color(.onBackground)
        case .tinted: theme.color(.interactive)
        case .bordered, .plain: theme.color(.interactive)
        }
    }

    private func triggerHaptic() {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        switch haptic {
        case .none: break
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        #endif
    }
}

// MARK: - Types

public enum PrismButtonVariant: Sendable {
    case filled
    case tinted
    case bordered
    case plain
    case glass
    case glassProminent
}

public enum PrismButtonHaptic: Sendable {
    case none
    case light
    case medium
    case heavy
}

// MARK: - Button Style

private struct PrismButtonStyle: SwiftUI.ButtonStyle {
    let variant: PrismButtonVariant
    @MainActor let theme: any PrismTheme
    let isLoading: Bool
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        configuration.label
            .font(TypographyToken.headline.font)
            .foregroundStyle(foregroundColor(pressed: pressed))
            .padding(.horizontal, SpacingToken.xl.rawValue)
            .padding(.vertical, SpacingToken.md.rawValue)
            .frame(minHeight: 44)
            .background(backgroundView(pressed: pressed))
            .clipShape(Capsule())
            .overlay(borderOverlay)
            .opacity(isLoading ? 0.8 : 1)
            .scaleEffect(pressed && !reduceMotion ? 0.97 : 1)
            .animation(
                reduceMotion ? nil : MotionToken.fast.animation,
                value: pressed
            )
    }

    private func foregroundColor(pressed: Bool) -> Color {
        switch variant {
        case .filled:
            theme.color(.onBrand)
        case .tinted:
            theme.color(.interactive)
        case .bordered, .plain:
            pressed ? theme.color(.interactivePressed) : theme.color(.interactive)
        case .glass, .glassProminent:
            theme.color(.onBackground)
        }
    }

    @ViewBuilder
    private func backgroundView(pressed: Bool) -> some View {
        switch variant {
        case .filled:
            theme.color(pressed ? .interactivePressed : .interactive)
        case .tinted:
            theme.color(.interactive).opacity(pressed ? 0.2 : 0.12)
        case .bordered, .plain:
            Color.clear
        case .glass, .glassProminent:
            Color.clear
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if variant == .bordered {
            Capsule()
                .stroke(theme.color(.border), lineWidth: 1)
        }
    }
}
