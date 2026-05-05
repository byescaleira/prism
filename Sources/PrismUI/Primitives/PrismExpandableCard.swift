import SwiftUI

/// Card that expands to reveal additional content on tap.
///
/// ```swift
/// PrismExpandableCard {
///     Text("Summary")
/// } expanded: {
///     Text("Full details here...")
/// }
/// ```
@MainActor
public struct PrismExpandableCard<Header: View, Detail: View>: View {
    @Environment(\.prismTheme) private var theme
    @State private var isExpanded = false

    private let surface: ColorToken
    private let radius: RadiusToken
    private let elevation: ElevationToken
    private let header: Header
    private let detail: Detail

    /// Creates an expandable card with a header and collapsible detail section.
    public init(
        surface: ColorToken = .surface,
        radius: RadiusToken = .lg,
        elevation: ElevationToken = .low,
        @ViewBuilder header: () -> Header,
        @ViewBuilder expanded detail: () -> Detail
    ) {
        self.surface = surface
        self.radius = radius
        self.elevation = elevation
        self.header = header()
        self.detail = detail()
    }

    /// The content and behavior of the expandable card.
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    header
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(SpacingToken.lg.rawValue)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                PrismDivider()
                detail
                    .padding(SpacingToken.lg.rawValue)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(theme.color(surface), in: radius.shape)
        .prismElevation(elevation)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand")
    }
}
