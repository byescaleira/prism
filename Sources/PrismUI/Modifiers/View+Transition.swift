import SwiftUI

// MARK: - Navigation Transition

#if !os(macOS)
    private struct PrismZoomTransitionModifier<ID: Hashable>: ViewModifier {
        let sourceID: ID
        let namespace: Namespace.ID

        func body(content: Content) -> some View {
            content
                .navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        }
    }

    private struct PrismMatchedTransitionSourceModifier<ID: Hashable>: ViewModifier {
        let id: ID
        let namespace: Namespace.ID

        func body(content: Content) -> some View {
            content
                .matchedTransitionSource(id: id, in: namespace)
        }
    }
#endif

// MARK: - Scroll Transition

private struct PrismScrollTransitionScaleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollTransition(.interactive) { view, phase in
                view.scaleEffect(1.0 - 0.12 * abs(phase.value))
            }
    }
}

private struct PrismScrollTransitionFadeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollTransition(.interactive) { view, phase in
                view.opacity(1.0 - 0.4 * abs(phase.value))
            }
    }
}

// MARK: - Content Transition

private struct PrismSymbolTransitionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentTransition(.symbolEffect)
    }
}

extension View {

    #if !os(macOS)
        /// Applies a navigation zoom transition (iOS/iPadOS/visionOS).
        public func prismZoomTransition<ID: Hashable>(
            sourceID: ID,
            in namespace: Namespace.ID
        ) -> some View {
            modifier(PrismZoomTransitionModifier(sourceID: sourceID, namespace: namespace))
        }

        /// Marks view as transition source for zoom navigation.
        public func prismTransitionSource<ID: Hashable>(
            id: ID,
            in namespace: Namespace.ID
        ) -> some View {
            modifier(PrismMatchedTransitionSourceModifier(id: id, namespace: namespace))
        }
    #endif

    /// Applies scale scroll-driven transition.
    public func prismScrollTransition() -> some View {
        modifier(PrismScrollTransitionScaleModifier())
    }

    /// Applies fade scroll-driven transition.
    public func prismScrollTransitionFade() -> some View {
        modifier(PrismScrollTransitionFadeModifier())
    }

    /// Uses animated SF Symbol content transition.
    public func prismSymbolTransition() -> some View {
        modifier(PrismSymbolTransitionModifier())
    }

    /// Applies soft edge effect on scroll boundaries.
    public func prismScrollEdge() -> some View {
        self.scrollEdgeEffectStyle(.soft, for: .all)
    }
}
