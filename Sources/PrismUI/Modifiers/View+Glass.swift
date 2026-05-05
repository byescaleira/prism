import SwiftUI

extension View {

    /// Applies a Liquid Glass effect with configurable shape.
    public func prismGlass(in shape: some Shape = Capsule()) -> some View {
        modifier(GlassModifier(shape: AnyShape(shape)))
    }

    /// Applies a Liquid Glass effect with a corner radius.
    public func prismGlass(cornerRadius: CGFloat) -> some View {
        modifier(GlassModifier(shape: AnyShape(.rect(cornerRadius: cornerRadius))))
    }

    /// Assigns a glass effect identity for coordinated glass animations.
    public func prismGlassID<ID: Hashable & Sendable>(_ id: ID, in namespace: Namespace.ID) -> some View {
        self.glassEffectID(id, in: namespace)
    }

    /// Extends background effect through safe areas (hero images, full-bleed content).
    public func prismBackgroundExtension() -> some View {
        self.backgroundExtensionEffect()
    }
}

/// Container that organizes child views with coordinated glass effects.
///
/// Wraps `GlassEffectContainer` to group glass-styled views with proper spacing.
///
/// ```swift
/// PrismGlassContainer(spacing: 8) {
///     PrismButton("Action", variant: .glass) { }
///     PrismButton("Cancel", variant: .plain) { }
/// }
/// ```
public struct PrismGlassContainer<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    /// Creates a glass effect container with the given spacing between children.
    public init(
        spacing: CGFloat = SpacingToken.sm.rawValue,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }

    /// The content and behavior of the glass container.
    public var body: some View {
        GlassEffectContainer(spacing: spacing) {
            content
        }
    }
}

private struct GlassModifier: ViewModifier {
    let shape: AnyShape

    func body(content: Content) -> some View {
        content.glassEffect(.regular, in: shape)
    }
}
