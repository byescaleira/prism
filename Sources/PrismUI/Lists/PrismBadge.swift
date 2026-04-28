import SwiftUI

/// Notification count badge overlay.
public struct PrismBadge: ViewModifier {
    @Environment(\.prismTheme) private var theme

    private let count: Int
    private let maxDisplay: Int

    public init(count: Int, maxDisplay: Int = 99) {
        self.count = count
        self.maxDisplay = maxDisplay
    }

    public func body(content: Content) -> some View {
        content.overlay(alignment: .topTrailing) {
            if count > 0 {
                Text(displayText)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(theme.color(.onBrand))
                    .padding(.horizontal, SpacingToken.xs.rawValue)
                    .frame(minWidth: 18, minHeight: 18)
                    .background(theme.color(.error), in: Capsule())
                    .offset(x: 8, y: -8)
                    .accessibilityLabel("\(count) notifications")
            }
        }
    }

    private var displayText: String {
        count > maxDisplay ? "\(maxDisplay)+" : "\(count)"
    }
}

extension View {

    /// Overlays a notification badge with count.
    public func prismBadge(_ count: Int, max: Int = 99) -> some View {
        modifier(PrismBadge(count: count, maxDisplay: max))
    }
}
