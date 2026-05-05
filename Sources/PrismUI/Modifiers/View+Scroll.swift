import SwiftUI

/// Scroll behavior presets following Apple HIG.
public enum PrismScrollBehavior: Sendable {
    /// Represents view-aligned scroll snapping behavior.
    case viewAligned
    /// Represents page-based scroll snapping behavior.
    case paging
    /// Represents automatic (no custom snapping) scroll behavior.
    case automatic
}

// MARK: - Scroll Target

private struct PrismScrollTargetModifier: ViewModifier {
    let behavior: PrismScrollBehavior

    func body(content: Content) -> some View {
        switch behavior {
        case .viewAligned:
            content
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
        case .paging:
            content
                .scrollTargetLayout()
                .scrollTargetBehavior(.paging)
        case .automatic:
            content
        }
    }
}

extension View {

    /// Applies scroll snapping behavior.
    public func prismScrollTarget(_ behavior: PrismScrollBehavior = .viewAligned) -> some View {
        modifier(PrismScrollTargetModifier(behavior: behavior))
    }

    /// Hides scroll indicators.
    public func prismScrollIndicators(_ visibility: ScrollIndicatorVisibility = .hidden) -> some View {
        self.scrollIndicators(visibility)
    }

    /// Disables scroll clipping for effects that extend beyond bounds.
    public func prismScrollClipDisabled(_ disabled: Bool = true) -> some View {
        self.scrollClipDisabled(disabled)
    }

    /// Applies toolbar background visibility.
    public func prismToolbarBackground(
        _ visibility: Visibility = .hidden,
        for bars: ToolbarPlacement = .automatic
    ) -> some View {
        self.toolbarBackgroundVisibility(visibility, for: bars)
    }
}
