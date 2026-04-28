import SwiftUI

/// An axis definition for a radar chart.
public struct PrismRadarAxis: Sendable, Hashable {
    /// Display label for the axis.
    public let label: String
    /// Maximum value on this axis.
    public let maxValue: Double

    /// Creates a radar axis.
    public init(label: String, maxValue: Double) {
        self.label = label
        self.maxValue = maxValue
    }
}

/// A data set to overlay on a radar chart.
public struct PrismRadarDataSet: Sendable, Hashable {
    /// Values for each axis in order.
    public let values: [Double]
    /// Fill and stroke color.
    public let color: Color
    /// Legend label for this data set.
    public let label: String

    /// Creates a radar data set.
    public init(values: [Double], color: Color, label: String) {
        self.values = values
        self.color = color
        self.label = label
    }
}

/// A radar (spider) chart with multiple data sets overlaid on a polygon grid.
@MainActor
public struct PrismRadarChart: View {
    @Environment(\.prismTheme) private var theme

    private let axes: [PrismRadarAxis]
    private let dataSets: [PrismRadarDataSet]
    private let gridLevels: Int

    /// Creates a radar chart.
    public init(
        axes: [PrismRadarAxis],
        dataSets: [PrismRadarDataSet],
        gridLevels: Int = 4
    ) {
        self.axes = axes
        self.dataSets = dataSets
        self.gridLevels = max(gridLevels, 1)
    }

    public var body: some View {
        VStack(spacing: SpacingToken.sm.rawValue) {
            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let radius = size * 0.38

                ZStack {
                    gridLines(center: center, radius: radius)
                    axisLines(center: center, radius: radius)
                    ForEach(Array(dataSets.enumerated()), id: \.offset) { _, dataSet in
                        dataPolygon(dataSet: dataSet, center: center, radius: radius)
                    }
                    axisLabels(center: center, radius: radius)
                }
            }
            .aspectRatio(1, contentMode: .fit)

            if dataSets.count > 1 {
                legend
            }
        }
    }

    @ViewBuilder
    private func gridLines(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(1...gridLevels, id: \.self) { level in
            let scale = CGFloat(level) / CGFloat(gridLevels)
            polygonPath(center: center, radius: radius * scale, count: axes.count)
                .stroke(theme.color(.separator).opacity(0.4), lineWidth: 0.5)
        }
    }

    @ViewBuilder
    private func axisLines(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<axes.count, id: \.self) { index in
            let angle = angleFor(index: index)
            Path { path in
                path.move(to: center)
                path.addLine(to: point(center: center, radius: radius, angle: angle))
            }
            .stroke(theme.color(.separator).opacity(0.3), lineWidth: 0.5)
        }
    }

    @ViewBuilder
    private func dataPolygon(dataSet: PrismRadarDataSet, center: CGPoint, radius: CGFloat) -> some View {
        let path = dataPath(dataSet: dataSet, center: center, radius: radius)
        path
            .fill(dataSet.color.opacity(0.15))
        path
            .stroke(dataSet.color, lineWidth: 2)
    }

    @ViewBuilder
    private func axisLabels(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<axes.count, id: \.self) { index in
            let angle = angleFor(index: index)
            let labelRadius = radius + 20
            let pos = point(center: center, radius: labelRadius, angle: angle)
            Text(axes[index].label)
                .font(.caption2)
                .foregroundStyle(theme.color(.onBackgroundSecondary))
                .position(pos)
                .accessibilityLabel("\(axes[index].label): max \(axes[index].maxValue, specifier: "%.0f")")
        }
    }

    @ViewBuilder
    private var legend: some View {
        HStack(spacing: SpacingToken.md.rawValue) {
            ForEach(Array(dataSets.enumerated()), id: \.offset) { _, dataSet in
                HStack(spacing: SpacingToken.xs.rawValue) {
                    Circle()
                        .fill(dataSet.color)
                        .frame(width: 8, height: 8)
                    Text(dataSet.label)
                        .font(.caption)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                }
            }
        }
    }

    private func angleFor(index: Int) -> Double {
        let count = axes.count
        guard count > 0 else { return 0 }
        return (Double(index) / Double(count)) * 2 * .pi - .pi / 2
    }

    private func point(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }

    private func polygonPath(center: CGPoint, radius: CGFloat, count: Int) -> Path {
        Path { path in
            guard count >= 3 else { return }
            for i in 0..<count {
                let angle = angleFor(index: i)
                let pt = point(center: center, radius: radius, angle: angle)
                if i == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
            path.closeSubpath()
        }
    }

    private func dataPath(dataSet: PrismRadarDataSet, center: CGPoint, radius: CGFloat) -> Path {
        Path { path in
            guard axes.count >= 3 else { return }
            for i in 0..<axes.count {
                let angle = angleFor(index: i)
                let value = i < dataSet.values.count ? dataSet.values[i] : 0
                let normalized = axes[i].maxValue > 0 ? min(value / axes[i].maxValue, 1) : 0
                let pt = point(center: center, radius: radius * normalized, angle: angle)
                if i == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
            path.closeSubpath()
        }
    }
}
