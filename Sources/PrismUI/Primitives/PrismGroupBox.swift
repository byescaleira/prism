import SwiftUI

/// Themed group box with optional label.
///
/// ```swift
/// PrismGroupBox("Settings") {
///     Toggle("Notifications", isOn: $enabled)
/// }
/// ```
public struct PrismGroupBox<Label: View, Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let label: Label
    private let content: Content

    public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        GroupBox {
            content
        } label: {
            label
                .foregroundStyle(theme.color(.onBackground))
        }
        .backgroundStyle(theme.color(.surfaceSecondary))
    }
}

extension PrismGroupBox where Label == Text {

    public init(
        _ title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) {
        self.label = Text(title)
            .font(TypographyToken.headline.font)
        self.content = content()
    }
}

extension PrismGroupBox where Label == EmptyView {

    public init(@ViewBuilder content: () -> Content) {
        self.label = EmptyView()
        self.content = content()
    }
}
