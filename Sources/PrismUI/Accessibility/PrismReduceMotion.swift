import SwiftUI

/// Modifier that conditionally applies content based on the "Reduce Motion" setting.
public struct PrismReduceMotion<Reduced: View, Full: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let reduced: Reduced
    private let full: Full

    /// Creates a reduce-motion view with alternative content for each motion preference.
    public init(
        @ViewBuilder reduced: () -> Reduced,
        @ViewBuilder full: () -> Full
    ) {
        self.reduced = reduced()
        self.full = full()
    }

    /// The view body that shows reduced or full content based on accessibility setting.
    public var body: some View {
        if reduceMotion {
            reduced
        } else {
            full
        }
    }
}

extension View {

    /// Applies a transform only when "Reduce Motion" is disabled.
    public func prismMotionSafe<V: View>(
        @ViewBuilder transform: @escaping (Self) -> V
    ) -> some View {
        modifier(MotionSafeModifier(base: self, transform: transform))
    }
}

private struct MotionSafeModifier<Base: View, Transformed: View>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let base: Base
    let transform: (Base) -> Transformed

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            transform(base)
        }
    }
}
