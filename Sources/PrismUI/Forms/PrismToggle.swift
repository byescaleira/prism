import SwiftUI

/// Themed toggle with label and optional description.
public struct PrismToggle: View {
    @Environment(\.prismTheme) private var theme

    @Binding private var isOn: Bool
    private let title: LocalizedStringKey
    private let description: LocalizedStringKey?
    private let icon: String?

    public init(
        _ title: LocalizedStringKey,
        isOn: Binding<Bool>,
        description: LocalizedStringKey? = nil,
        icon: String? = nil
    ) {
        self.title = title
        self._isOn = isOn
        self.description = description
        self.icon = icon
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: SpacingToken.md.rawValue) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(theme.color(.interactive))
                        .frame(width: 28)
                }

                VStack(alignment: .leading, spacing: SpacingToken.xxs.rawValue) {
                    Text(title)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onSurface))

                    if let description {
                        Text(description)
                            .font(TypographyToken.caption.font)
                            .foregroundStyle(theme.color(.onSurfaceSecondary))
                    }
                }
            }
        }
        .tint(theme.color(.interactive))
        .padding(.vertical, SpacingToken.xs.rawValue)
    }
}
