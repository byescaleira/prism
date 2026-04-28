import SwiftUI

/// Compact leading/trailing view pair for Live Activity presentations.
///
/// Provides themed layout for Dynamic Island compact and Lock Screen presentations.
///
/// ```swift
/// PrismLiveActivityCompact(
///     leading: { PrismIcon("timer", size: .small) },
///     trailing: { Text("2:45") }
/// )
/// ```
public struct PrismLiveActivityCompact<Leading: View, Trailing: View>: View {
    private let leading: Leading
    private let trailing: Trailing

    public init(
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            leading
            Spacer(minLength: 0)
            trailing
        }
    }
}

/// Expanded Live Activity content view with themed sections.
public struct PrismLiveActivityExpanded<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    private let icon: String?
    private let content: Content

    public init(
        _ title: LocalizedStringKey,
        icon: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md.rawValue) {
            HStack(spacing: SpacingToken.sm.rawValue) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.color(.interactive))
                }
                Text(title)
                    .font(TypographyToken.headline.font)
                    .foregroundStyle(theme.color(.onBackground))
            }

            content
        }
        .padding(SpacingToken.lg.rawValue)
    }
}

/// Minimal Lock Screen presentation.
public struct PrismLiveActivityMinimal<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .frame(minWidth: 44, minHeight: 44)
    }
}
