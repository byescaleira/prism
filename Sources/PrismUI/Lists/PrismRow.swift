import SwiftUI

/// Standardized list row with icon, title, subtitle, and trailing accessory.
public struct PrismRow<Trailing: View>: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey?
    private let icon: String?
    private let iconColor: ColorToken
    private let trailing: Trailing

    /// Creates a row with title, optional subtitle, icon, and trailing accessory.
    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        icon: String? = nil,
        iconColor: ColorToken = .interactive,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.trailing = trailing()
    }

    /// The content and behavior of the row.
    public var body: some View {
        HStack(spacing: SpacingToken.md.rawValue) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(theme.color(iconColor))
                    .frame(width: 28)
            }

            VStack(alignment: .leading, spacing: SpacingToken.xxs.rawValue) {
                Text(title)
                    .font(TypographyToken.body.font)
                    .foregroundStyle(theme.color(.onSurface))

                if let subtitle {
                    Text(subtitle)
                        .font(TypographyToken.footnote.font)
                        .foregroundStyle(theme.color(.onSurfaceSecondary))
                }
            }

            Spacer(minLength: 0)

            trailing
        }
        .padding(.vertical, SpacingToken.sm.rawValue)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

extension PrismRow where Trailing == EmptyView {

    /// Creates a row with title, optional subtitle, and icon but no trailing accessory.
    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        icon: String? = nil,
        iconColor: ColorToken = .interactive
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.trailing = EmptyView()
    }
}

/// Row with a chevron disclosure indicator.
public struct PrismDisclosureRow: View {
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey?
    private let icon: String?
    private let iconColor: ColorToken

    /// Creates a disclosure row with title, optional subtitle, and icon.
    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        icon: String? = nil,
        iconColor: ColorToken = .interactive
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
    }

    /// The content and behavior of the disclosure row.
    public var body: some View {
        PrismRow(
            title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor
        ) {
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
    }
}
