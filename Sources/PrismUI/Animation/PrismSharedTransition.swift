import SwiftUI

/// Shared element transition using matchedGeometryEffect.
///
/// ```swift
/// @Namespace var ns
/// PrismSharedElement(id: "hero", namespace: ns) {
///     Image("photo")
/// }
/// ```
@MainActor
public struct PrismSharedElement<Content: View>: View {
    let id: String
    let namespace: Namespace.ID
    let anchor: UnitPoint
    let isSource: Bool
    let content: Content

    /// Creates a shared element with the given ID, namespace, and anchor point.
    public init(
        id: String,
        namespace: Namespace.ID,
        anchor: UnitPoint = .center,
        isSource: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.namespace = namespace
        self.anchor = anchor
        self.isSource = isSource
        self.content = content()
    }

    /// The shared element view body with matched geometry applied.
    public var body: some View {
        content
            .matchedGeometryEffect(id: id, in: namespace, anchor: anchor, isSource: isSource)
    }
}

/// Modifier for matched geometry with Prism spring.
private struct PrismMatchedGeometryModifier: ViewModifier {
    let id: String
    let namespace: Namespace.ID
    let anchor: UnitPoint
    let isSource: Bool

    func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(id: id, in: namespace, anchor: anchor, isSource: isSource)
    }
}

extension View {

    /// Marks view for shared element transition with Prism naming.
    public func prismMatchedGeometry(
        id: String,
        in namespace: Namespace.ID,
        anchor: UnitPoint = .center,
        isSource: Bool = true
    ) -> some View {
        modifier(PrismMatchedGeometryModifier(id: id, namespace: namespace, anchor: anchor, isSource: isSource))
    }
}

/// Hero transition container — animates between two states with matched geometry.
@MainActor
public struct PrismHeroTransition<Source: View, Destination: View>: View {
    @Namespace private var heroNamespace
    @Binding var isExpanded: Bool

    let heroID: String
    let spring: PrismSpringConfig
    let source: Source
    let destination: Destination

    /// Creates a hero transition between source and destination views with a shared geometry ID.
    public init(
        isExpanded: Binding<Bool>,
        heroID: String = "hero",
        spring: PrismSpringConfig = .dramatic,
        @ViewBuilder source: () -> Source,
        @ViewBuilder destination: () -> Destination
    ) {
        self._isExpanded = isExpanded
        self.heroID = heroID
        self.spring = spring
        self.source = source()
        self.destination = destination()
    }

    /// The hero transition view body toggling between source and destination.
    public var body: some View {
        Group {
            if isExpanded {
                destination
                    .matchedGeometryEffect(id: heroID, in: heroNamespace)
                    .onTapGesture {
                        withAnimation(spring.animation) {
                            isExpanded = false
                        }
                    }
            } else {
                source
                    .matchedGeometryEffect(id: heroID, in: heroNamespace)
                    .onTapGesture {
                        withAnimation(spring.animation) {
                            isExpanded = true
                        }
                    }
            }
        }
    }
}
