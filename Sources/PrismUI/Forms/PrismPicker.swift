import SwiftUI

/// Themed picker with label, supporting menu and inline styles.
public struct PrismPicker<Selection: Hashable, Content: View>: View {
    @Environment(\.prismTheme) private var theme

    @Binding private var selection: Selection
    private let title: LocalizedStringKey
    private let icon: String?
    private let content: Content

    public init(
        _ title: LocalizedStringKey,
        selection: Binding<Selection>,
        icon: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._selection = selection
        self.icon = icon
        self.content = content()
    }

    public var body: some View {
        Picker(selection: $selection) {
            content
        } label: {
            HStack(spacing: SpacingToken.md.rawValue) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(theme.color(.interactive))
                        .frame(width: 28)
                }

                Text(title)
                    .font(TypographyToken.body.font)
                    .foregroundStyle(theme.color(.onSurface))
            }
        }
        .tint(theme.color(.interactive))
    }
}
