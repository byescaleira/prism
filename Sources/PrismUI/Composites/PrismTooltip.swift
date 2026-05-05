import SwiftUI

/// Popover-style hint that appears on long press or hover.
private struct PrismTooltipModifier: ViewModifier {
    @Environment(\.prismTheme) private var theme
    @State private var isShowing = false

    let text: LocalizedStringKey
    let edge: Edge

    func body(content: Content) -> some View {
        content
            .onLongPressGesture(minimumDuration: 0.5) {
                isShowing = true
            }
            #if os(macOS) || os(visionOS)
                .onHover { hovering in
                    isShowing = hovering
                }
            #endif
            .popover(isPresented: $isShowing, arrowEdge: edge) {
                Text(text)
                    .font(TypographyToken.caption.font)
                    .foregroundStyle(theme.color(.onSurface))
                    .padding(.horizontal, SpacingToken.md.rawValue)
                    .padding(.vertical, SpacingToken.sm.rawValue)
                    .fixedSize()
                    .presentationCompactAdaptation(.popover)
            }
    }
}

extension View {

    /// Adds a tooltip that shows on long press (iOS/tvOS/watchOS) or hover (macOS/visionOS).
    public func prismTooltip(
        _ text: LocalizedStringKey,
        edge: Edge = .top
    ) -> some View {
        modifier(PrismTooltipModifier(text: text, edge: edge))
    }
}
