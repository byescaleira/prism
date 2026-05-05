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

    /// Creates a group box with custom content and label views.
    public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.content = content()
    }

    /// The content and behavior of the group box.
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

    /// Creates a group box with a text title and content.
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

    /// Creates a group box with content only, omitting the label.
    public init(@ViewBuilder content: () -> Content) {
        self.label = EmptyView()
        self.content = content()
    }
}
