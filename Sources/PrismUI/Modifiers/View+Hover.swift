import SwiftUI

/// Cross-platform hover effect that works on macOS, visionOS, and iPadOS with pointer.
private struct PrismHoverModifier: ViewModifier {
    @Environment(\.prismTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let scaleEffect: CGFloat
    let highlightColor: ColorToken?

    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovering && !reduceMotion ? scaleEffect : 1.0)
            .background(
                isHovering && highlightColor != nil
                    ? theme.color(highlightColor!).opacity(0.08)
                    : Color.clear
            )
            .animation(
                reduceMotion ? nil : MotionToken.fast.animation,
                value: isHovering
            )
            #if os(macOS) || os(visionOS) || targetEnvironment(macCatalyst)
            .onHover { hovering in
                isHovering = hovering
            }
            #endif
            #if os(visionOS)
            .hoverEffect(.highlight)
            #endif
    }
}

extension View {

    /// Adds platform-appropriate hover effects.
    ///
    /// - macOS/visionOS: responds to pointer hover
    /// - visionOS: also applies `.hoverEffect(.highlight)` for gaze interaction
    /// - iOS: no-op (no pointer by default)
    public func prismHover(
        scale: CGFloat = 1.02,
        highlight: ColorToken? = .interactive
    ) -> some View {
        modifier(PrismHoverModifier(scaleEffect: scale, highlightColor: highlight))
    }
}
