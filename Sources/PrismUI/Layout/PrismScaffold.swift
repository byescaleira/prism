import SwiftUI

/// Screen-level layout template with themed background and safe area handling.
public struct PrismScaffold<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let background: ColorToken
    private let content: Content

    /// Creates a scaffold with a themed background color.
    public init(
        background: ColorToken = .background,
        @ViewBuilder content: () -> Content
    ) {
        self.background = background
        self.content = content()
    }

    /// The content and behavior of the scaffold.
    public var body: some View {
        ZStack {
            theme.color(background)
                .ignoresSafeArea()

            content
        }
    }
}
