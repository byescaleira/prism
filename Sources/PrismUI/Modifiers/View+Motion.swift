import SwiftUI

extension View {

    /// Applies an animation that respects the "Reduce Motion" accessibility setting.
    public func prismAnimation(
        _ token: MotionToken,
        value: some Equatable
    ) -> some View {
        modifier(ReduceMotionAnimationModifier(token: token, value: value))
    }

    /// Wraps content in a transition that respects "Reduce Motion".
    public func prismTransition(_ transition: AnyTransition, motion: MotionToken = .normal) -> some View {
        self.transition(transition)
            .animation(motion.animation, value: UUID())
    }
}

private struct ReduceMotionAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let token: MotionToken
    let value: V

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.animation(token.animation, value: value)
        }
    }
}
