import SwiftUI

/// Pre-built animation presets using MotionToken values.
public enum PrismAnimationPreset: Sendable {
    /// Represents a spring bounce scale effect.
    case bounce
    /// Represents a rotational wiggle effect.
    case wiggle
    /// Represents a pulsing opacity effect.
    case pulse
    /// Represents a horizontal shake effect.
    case shake
    /// Represents a fade-in opacity transition.
    case fadeIn
    /// Represents an upward slide with fade.
    case slideUp
    /// Represents a scale-in with fade transition.
    case scaleIn
    /// Represents a spring-driven scale-in with fade.
    case springIn
}

/// Trigger modifier that runs a preset animation on value change.
private struct PrismAnimationTriggerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let preset: PrismAnimationPreset
    let isActive: Bool

    @State private var animationState: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(AnimationEffect(preset: preset, phase: animationState))
            .onChange(of: isActive) { _, active in
                guard !reduceMotion else { return }
                if active {
                    switch preset {
                    case .wiggle, .shake:
                        withAnimation(.easeInOut(duration: 0.08).repeatCount(4, autoreverses: true)) {
                            animationState = 1
                        } completion: {
                            animationState = 0
                        }
                    case .bounce:
                        withAnimation(.spring(duration: 0.4, bounce: 0.5)) {
                            animationState = 1
                        } completion: {
                            animationState = 0
                        }
                    case .pulse:
                        withAnimation(.easeInOut(duration: 0.3).repeatCount(2, autoreverses: true)) {
                            animationState = 1
                        } completion: {
                            animationState = 0
                        }
                    default:
                        withAnimation(.spring(duration: 0.35)) {
                            animationState = 1
                        }
                    }
                } else {
                    withAnimation(.spring(duration: 0.25)) {
                        animationState = 0
                    }
                }
            }
    }
}

private struct AnimationEffect: ViewModifier, @preconcurrency Animatable {
    let preset: PrismAnimationPreset
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func body(content: Content) -> some View {
        switch preset {
        case .bounce:
            content.scaleEffect(1 + phase * 0.15)
        case .wiggle:
            content.rotationEffect(.degrees(phase * 3))
        case .pulse:
            content.opacity(1 - phase * 0.3)
        case .shake:
            content.offset(x: phase * 6)
        case .fadeIn:
            content.opacity(phase)
        case .slideUp:
            content.offset(y: (1 - phase) * 20).opacity(phase)
        case .scaleIn:
            content.scaleEffect(0.8 + phase * 0.2).opacity(phase)
        case .springIn:
            content.scaleEffect(0.5 + phase * 0.5).opacity(phase)
        }
    }
}

/// Continuous animation modifier.
private struct PrismContinuousAnimationModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    let preset: PrismAnimationPreset

    func body(content: Content) -> some View {
        content
            .modifier(AnimationEffect(preset: preset, phase: isAnimating ? 1 : 0))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

extension View {

    /// Triggers a preset animation when the condition changes to true.
    public func prismAnimate(
        _ preset: PrismAnimationPreset,
        trigger: Bool
    ) -> some View {
        modifier(PrismAnimationTriggerModifier(preset: preset, isActive: trigger))
    }

    /// Applies a continuous looping animation. Respects Reduce Motion.
    public func prismPulse(_ preset: PrismAnimationPreset = .pulse) -> some View {
        modifier(PrismContinuousAnimationModifier(preset: preset))
    }
}
