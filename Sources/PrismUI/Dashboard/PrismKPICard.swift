import SwiftUI

/// Direction of a metric trend: up, down, or flat.
public enum PrismTrend: String, Sendable, CaseIterable {
    case up
    case down
    case flat

    /// Semantic color for the trend direction.
    public var colorToken: ColorToken {
        switch self {
        case .up: .success
        case .down: .error
        case .flat: .onBackgroundSecondary
        }
    }

    /// SF Symbol arrow for the trend direction.
    public var systemImage: String {
        switch self {
        case .up: "arrow.up.right"
        case .down: "arrow.down.right"
        case .flat: "arrow.right"
        }
    }
}

/// Display size for a KPI card.
public enum PrismKPISize: Sendable {
    /// Compact horizontal layout for tight spaces.
    case compact
    /// Full vertical layout with optional sparkline.
    case expanded
}

/// Key Performance Indicator card showing a metric with optional trend and sparkline.
public struct PrismKPICard: View {
    @Environment(\.prismTheme) private var theme

    private let title: String
    private let value: String
    private let trend: PrismTrend?
    private let changePercentage: Double?
    private let icon: String?
    private let subtitle: String?
    private let sparklineData: [Double]?
    private let size: PrismKPISize

    /// Creates a KPI card with metric value, optional trend, and sparkline data.
    public init(
        title: String,
        value: String,
        trend: PrismTrend? = nil,
        changePercentage: Double? = nil,
        icon: String? = nil,
        subtitle: String? = nil,
        sparklineData: [Double]? = nil,
        size: PrismKPISize = .expanded
    ) {
        self.title = title
        self.value = value
        self.trend = trend
        self.changePercentage = changePercentage
        self.icon = icon
        self.subtitle = subtitle
        self.sparklineData = sparklineData
        self.size = size
    }

    /// The KPI card view body with compact or expanded layout.
    public var body: some View {
        PrismCard {
            switch size {
            case .compact:
                compactLayout
            case .expanded:
                expandedLayout
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Layouts

    private var compactLayout: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            if let icon {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(theme.color(.brand))
            }
            VStack(alignment: .leading, spacing: SpacingToken.xxs.rawValue) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
                Text(value)
                    .font(.headline)
                    .foregroundStyle(theme.color(.onBackground))
            }
            Spacer()
            trendBadge
        }
    }

    private var expandedLayout: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
            HStack {
                if let icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(theme.color(.brand))
                }
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
                Spacer()
                trendBadge
            }
            Text(value)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(theme.color(.onBackground))
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(theme.color(.onBackgroundTertiary))
            }
            if let sparklineData, !sparklineData.isEmpty {
                PrismKPISparkline(data: sparklineData, trend: trend)
                    .frame(height: 40)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var trendBadge: some View {
        if let trend, let changePercentage {
            HStack(spacing: SpacingToken.xxs.rawValue) {
                Image(systemName: trend.systemImage)
                    .font(.caption2)
                Text(String(format: "%.1f%%", abs(changePercentage)))
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(theme.color(trend.colorToken))
        }
    }

    private var accessibilityDescription: String {
        var parts = [title, value]
        if let trend, let changePercentage {
            parts.append("\(trend.rawValue) \(String(format: "%.1f", abs(changePercentage))) percent")
        }
        if let subtitle { parts.append(subtitle) }
        return parts.joined(separator: ", ")
    }
}

/// Inline sparkline chart drawn with a simple path.
struct PrismKPISparkline: View {
    @Environment(\.prismTheme) private var theme

    let data: [Double]
    let trend: PrismTrend?

    var body: some View {
        GeometryReader { proxy in
            let color = trend.map { theme.color($0.colorToken) } ?? theme.color(.interactive)
            sparklinePath(in: proxy.size)
                .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
        }
        .accessibilityHidden(true)
    }

    private func sparklinePath(in size: CGSize) -> Path {
        guard data.count > 1 else { return Path() }
        let minVal = data.min() ?? 0
        let maxVal = data.max() ?? 1
        let range = maxVal - minVal
        let safeRange = range == 0 ? 1.0 : range

        return Path { path in
            for (index, value) in data.enumerated() {
                let x = size.width * Double(index) / Double(data.count - 1)
                let y = size.height - (size.height * (value - minVal) / safeRange)
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
}
