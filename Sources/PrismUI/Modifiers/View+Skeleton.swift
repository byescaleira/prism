import SwiftUI

/// Skeleton/shimmer loading placeholder modifier.
private struct SkeletonModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = 0

    let isLoading: Bool

    func body(content: Content) -> some View {
        if isLoading {
            content
                .redacted(reason: .placeholder)
                .overlay(shimmer)
                .accessibilityLabel(PrismStrings.loading)
        } else {
            content
        }
    }

    @ViewBuilder
    private var shimmer: some View {
        if !reduceMotion {
            GeometryReader { geo in
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geo.size.width * 0.6)
                .offset(x: phase * geo.size.width * 1.6 - geo.size.width * 0.3)
                .blendMode(.overlay)
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
            }
            .clipShape(Rectangle())
        }
    }
}

extension View {

    /// Applies a skeleton shimmer loading state.
    public func prismSkeleton(_ isLoading: Bool) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading))
    }
}
