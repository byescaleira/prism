import SwiftUI

extension View {

    /// Applies a Liquid Glass effect on iOS 26+, falling back to thin material.
    public func prismGlass(in shape: some Shape = Capsule()) -> some View {
        modifier(GlassModifier(shape: AnyShape(shape)))
    }
}

private struct GlassModifier: ViewModifier {
    let shape: AnyShape

    func body(content: Content) -> some View {
        content.glassEffect(.regular, in: shape)
    }
}
