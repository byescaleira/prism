import SwiftUI

/// A single statistic item displayed inside a stat grid.
public struct PrismStatItem: Sendable, Identifiable {
    /// Unique identifier for this stat item.
    public let id = UUID()
    /// Display label for the stat.
    public let label: String
    /// Formatted value string.
    public let value: String
    /// Optional SF Symbol name.
    public let icon: String?
    /// Optional trend direction.
    public let trend: PrismTrend?

    /// Creates a stat item with label, formatted value, and optional icon and trend.
    public init(
        label: String,
        value: String,
        icon: String? = nil,
        trend: PrismTrend? = nil
    ) {
        self.label = label
        self.value = value
        self.icon = icon
        self.trend = trend
    }
}

/// Responsive grid of stat items that adapts columns to available width.
public struct PrismStatGrid: View {
    @Environment(\.prismTheme) private var theme

    private let items: [PrismStatItem]
    private let minimumColumnWidth: CGFloat

    /// Creates a stat grid with adaptive columns based on minimum width.
    public init(
        items: [PrismStatItem],
        minimumColumnWidth: CGFloat = 160
    ) {
        self.items = items
        self.minimumColumnWidth = minimumColumnWidth
    }

    /// The stat grid view body with adaptive column layout.
    public var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: minimumColumnWidth), spacing: SpacingToken.md.rawValue)],
            spacing: SpacingToken.md.rawValue
        ) {
            ForEach(items) { item in
                statCell(item)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Statistics grid")
    }

    private func statCell(_ item: PrismStatItem) -> some View {
        PrismCard {
            VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
                HStack {
                    if let icon = item.icon {
                        Image(systemName: icon)
                            .font(.body)
                            .foregroundStyle(theme.color(.brand))
                    }
                    Text(item.label)
                        .font(.caption)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                    Spacer()
                    if let trend = item.trend {
                        Image(systemName: trend.systemImage)
                            .font(.caption2)
                            .foregroundStyle(theme.color(trend.colorToken))
                    }
                }
                Text(item.value)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(theme.color(.onBackground))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.label): \(item.value)")
    }
}
