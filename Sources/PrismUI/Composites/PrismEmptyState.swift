import SwiftUI

/// Full-page empty state with illustration, title, message, and call-to-action.
public struct PrismEmptyState<Action: View>: View {
    @Environment(\.prismTheme) private var theme

    private let icon: String
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let action: Action

    public init(
        icon: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        @ViewBuilder action: () -> Action
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = action()
    }

    public var body: some View {
        VStack(spacing: SpacingToken.xl.rawValue) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(theme.color(.onBackgroundTertiary))
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: SpacingToken.sm.rawValue) {
                Text(title)
                    .font(TypographyToken.title2.font(weight: .semibold))
                    .foregroundStyle(theme.color(.onBackground))
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            action
        }
        .padding(SpacingToken.xxl.rawValue)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }
}

extension PrismEmptyState where Action == EmptyView {

    public init(
        icon: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = EmptyView()
    }
}
