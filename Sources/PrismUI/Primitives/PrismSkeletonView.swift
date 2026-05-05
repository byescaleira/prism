import SwiftUI

/// Skeleton placeholder with shimmer animation for loading states.
///
/// ```swift
/// PrismSkeletonView(.card)
/// PrismSkeletonView(.list(rows: 5))
/// PrismSkeletonView(.custom(width: 200, height: 20, radius: .sm))
/// ```
@MainActor
public struct PrismSkeletonView: View {
    @Environment(\.prismTheme) private var theme
    @State private var shimmerPhase: CGFloat = -1

    private let layout: Layout

    /// Creates a skeleton placeholder with the specified layout.
    public init(_ layout: Layout = .text) {
        self.layout = layout
    }

    /// The content and behavior of the skeleton view.
    public var body: some View {
        skeletonContent
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmerPhase = 2
                }
            }
            .accessibilityLabel("Loading")
    }

    @ViewBuilder
    private var skeletonContent: some View {
        switch layout {
        case .text:
            VStack(alignment: .leading, spacing: 8) {
                skeletonRect(width: .infinity, height: 16, radius: .sm)
                skeletonRect(width: 200, height: 16, radius: .sm)
            }

        case .avatar:
            HStack(spacing: SpacingToken.md.rawValue) {
                skeletonCircle(size: 48)
                VStack(alignment: .leading, spacing: 6) {
                    skeletonRect(width: 120, height: 14, radius: .sm)
                    skeletonRect(width: 80, height: 12, radius: .sm)
                }
            }

        case .card:
            VStack(alignment: .leading, spacing: SpacingToken.md.rawValue) {
                skeletonRect(width: .infinity, height: 160, radius: .md)
                skeletonRect(width: .infinity, height: 18, radius: .sm)
                skeletonRect(width: 200, height: 14, radius: .sm)
            }
            .padding(SpacingToken.lg.rawValue)
            .background(theme.color(.surface), in: RadiusToken.lg.shape)

        case .list(let rows):
            VStack(spacing: SpacingToken.md.rawValue) {
                ForEach(0..<rows, id: \.self) { _ in
                    HStack(spacing: SpacingToken.md.rawValue) {
                        skeletonCircle(size: 40)
                        VStack(alignment: .leading, spacing: 6) {
                            skeletonRect(width: .infinity, height: 14, radius: .sm)
                            skeletonRect(width: 120, height: 12, radius: .sm)
                        }
                    }
                }
            }

        case .custom(let width, let height, let radius):
            skeletonRect(width: width, height: height, radius: radius)
        }
    }

    private func skeletonRect(width: CGFloat, height: CGFloat, radius: RadiusToken) -> some View {
        RoundedRectangle(cornerRadius: radius.rawValue)
            .fill(theme.color(.borderSubtle).opacity(0.3))
            .frame(maxWidth: width == .infinity ? .infinity : width, minHeight: height, maxHeight: height)
            .overlay(shimmerOverlay(radius: radius))
    }

    private func skeletonCircle(size: CGFloat) -> some View {
        Circle()
            .fill(theme.color(.borderSubtle).opacity(0.3))
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .fill(shimmerGradient)
                    .clipShape(Circle())
            )
    }

    private func shimmerOverlay(radius: RadiusToken) -> some View {
        RoundedRectangle(cornerRadius: radius.rawValue)
            .fill(shimmerGradient)
    }

    private var shimmerGradient: some ShapeStyle {
        LinearGradient(
            colors: [.clear, theme.color(.surface).opacity(0.4), .clear],
            startPoint: UnitPoint(x: shimmerPhase - 0.5, y: 0.5),
            endPoint: UnitPoint(x: shimmerPhase + 0.5, y: 0.5)
        )
    }
}

extension PrismSkeletonView {
    /// Predefined skeleton layout configurations.
    public enum Layout: Sendable {
        /// Represents a multi-line text placeholder.
        case text
        /// Represents an avatar with name placeholder.
        case avatar
        /// Represents a card with image and text placeholders.
        case card
        /// Represents a list of row placeholders.
        case list(rows: Int)
        /// Represents a custom-sized rectangular placeholder.
        case custom(width: CGFloat, height: CGFloat, radius: RadiusToken)
    }
}
