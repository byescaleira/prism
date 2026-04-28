import SwiftUI

#if canImport(TipKit)
import TipKit

/// Themed TipKit integration.
///
/// ```swift
/// PrismTipView(MyFeatureTip())
/// ```
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct PrismTipView<T: Tip>: View {
    @Environment(\.prismTheme) private var theme

    private let tip: T

    public init(_ tip: T) {
        self.tip = tip
    }

    public var body: some View {
        TipView(tip)
            .tipBackground(theme.color(.surface))
            .tint(theme.color(.interactive))
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct PrismPopoverTipModifier<T: Tip>: ViewModifier {
    @Environment(\.prismTheme) private var theme
    let tip: T
    let arrowEdge: Edge

    func body(content: Content) -> some View {
        content
            .popoverTip(tip, arrowEdge: arrowEdge)
            .tint(theme.color(.interactive))
    }
}

extension View {

    /// Attaches a themed popover tip.
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public func prismPopoverTip<T: Tip>(
        _ tip: T,
        arrowEdge: Edge = .top
    ) -> some View {
        modifier(PrismPopoverTipModifier(tip: tip, arrowEdge: arrowEdge))
    }
}
#endif
