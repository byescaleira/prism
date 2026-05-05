import SwiftUI

/// Enhanced skeleton/redacted styles beyond basic shimmer.
public enum PrismRedactedStyle: Sendable {
    /// Represents a shimmer animation over redacted content.
    case shimmer
    /// Represents a pulsing opacity animation over redacted content.
    case pulse
    /// Represents a blur effect over redacted content.
    case blur
}

private struct PrismShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .redacted(reason: .placeholder)
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content.redacted(reason: .placeholder))
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

private struct PrismPulseRedactedModifier: ViewModifier {
    @State private var opacity: Double = 0.4

    func body(content: Content) -> some View {
        content
            .redacted(reason: .placeholder)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    opacity = 0.8
                }
            }
    }
}

private struct PrismBlurRedactedModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .redacted(reason: .placeholder)
            .blur(radius: 4)
    }
}

extension View {

    /// Applies enhanced redacted/skeleton style.
    public func prismRedacted(_ style: PrismRedactedStyle = .shimmer, isLoading: Bool) -> some View {
        Group {
            if isLoading {
                switch style {
                case .shimmer:
                    modifier(PrismShimmerModifier())
                case .pulse:
                    modifier(PrismPulseRedactedModifier())
                case .blur:
                    modifier(PrismBlurRedactedModifier())
                }
            } else {
                self
            }
        }
    }
}
