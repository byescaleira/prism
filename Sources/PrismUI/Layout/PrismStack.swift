import SwiftUI

/// Adaptive stack that switches between VStack and HStack based on size class.
public struct PrismAdaptiveStack<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let spacing: SpacingToken
    private let threshold: UserInterfaceSizeClass
    private let alignment: Alignment
    private let content: Content

    /// Creates an adaptive stack that switches layout based on size class threshold.
    public init(
        spacing: SpacingToken = .md,
        threshold: UserInterfaceSizeClass = .regular,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.threshold = threshold
        self.alignment = alignment
        self.content = content()
    }

    /// The content and behavior of the adaptive stack.
    public var body: some View {
        if sizeClass == threshold {
            HStack(alignment: alignment.vertical, spacing: spacing.rawValue) {
                content
            }
        } else {
            VStack(alignment: alignment.horizontal, spacing: spacing.rawValue) {
                content
            }
        }
    }
}
