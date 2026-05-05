import SwiftUI

/// Inline row combining a label, value, and sparkline chart.
public struct PrismSparklineRow: View {
    @Environment(\.prismTheme) private var theme

    private let label: String
    private let value: String
    private let data: [Double]
    private let trend: PrismTrend?
    private let subtitle: String?

    /// Creates a sparkline row with label, value, data points, and optional trend.
    public init(
        label: String,
        value: String,
        data: [Double],
        trend: PrismTrend? = nil,
        subtitle: String? = nil
    ) {
        self.label = label
        self.value = value
        self.data = data
        self.trend = trend
        self.subtitle = subtitle
    }

    /// The sparkline row view body with label, value, trend arrow, and inline chart.
    public var body: some View {
        HStack(spacing: SpacingToken.md.rawValue) {
            VStack(alignment: .leading, spacing: SpacingToken.xxs.rawValue) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
                HStack(spacing: SpacingToken.xs.rawValue) {
                    Text(value)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.color(.onBackground))
                    if let trend {
                        Image(systemName: trend.systemImage)
                            .font(.caption2)
                            .foregroundStyle(theme.color(trend.colorToken))
                    }
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(theme.color(.onBackgroundTertiary))
                }
            }
            Spacer()
            if !data.isEmpty {
                PrismSparkline(data: data, trendColoring: trend != nil)
                    .frame(width: 80, height: 28)
            }
        }
        .padding(.vertical, SpacingToken.xs.rawValue)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
