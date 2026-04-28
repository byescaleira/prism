import SwiftUI

/// Display style for a sparkline chart.
public enum PrismSparklineStyle: String, Sendable, CaseIterable {
    /// A thin line connecting data points.
    case line
    /// A filled area below the line.
    case area
    /// Vertical bars for each data point.
    case bar
}

/// An inline mini chart for displaying trends in compact spaces.
@MainActor
public struct PrismSparkline: View {
    @Environment(\.prismTheme) private var theme

    private let data: [Double]
    private let style: PrismSparklineStyle
    private let showMinMaxMarkers: Bool
    private let trendColoring: Bool
    private let overrideColor: Color?

    /// Creates a sparkline from an array of values.
    public init(
        data: [Double],
        style: PrismSparklineStyle = .line,
        showMinMaxMarkers: Bool = false,
        trendColoring: Bool = false,
        color: Color? = nil
    ) {
        self.data = data
        self.style = style
        self.showMinMaxMarkers = showMinMaxMarkers
        self.trendColoring = trendColoring
        self.overrideColor = color
    }

    private var trendColor: Color {
        if let overrideColor { return overrideColor }
        guard trendColoring, let first = data.first, let last = data.last else {
            return theme.color(.interactive)
        }
        if last > first {
            return theme.color(.success)
        } else if last < first {
            return theme.color(.error)
        }
        return theme.color(.interactive)
    }

    public var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .local)
            switch style {
            case .line:
                lineContent(in: rect)
            case .area:
                areaContent(in: rect)
            case .bar:
                barContent(in: rect)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    @ViewBuilder
    private func lineContent(in rect: CGRect) -> some View {
        ZStack {
            linePath(in: rect)
                .stroke(trendColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            if showMinMaxMarkers {
                minMaxMarkers(in: rect)
            }
        }
    }

    @ViewBuilder
    private func areaContent(in rect: CGRect) -> some View {
        ZStack {
            areaPath(in: rect)
                .fill(
                    LinearGradient(
                        colors: [trendColor.opacity(0.3), trendColor.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            linePath(in: rect)
                .stroke(trendColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            if showMinMaxMarkers {
                minMaxMarkers(in: rect)
            }
        }
    }

    @ViewBuilder
    private func barContent(in rect: CGRect) -> some View {
        let minVal = data.min() ?? 0
        let maxVal = data.max() ?? 1
        let range = maxVal - minVal
        let count = data.count

        if count > 0 {
            let barWidth = rect.width / CGFloat(count) * 0.8
            let gap = rect.width / CGFloat(count) * 0.2

            HStack(alignment: .bottom, spacing: gap) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, value in
                    let normalized = range > 0 ? (value - minVal) / range : 0.5
                    let barHeight = max(rect.height * normalized, 1)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(trendColor)
                        .frame(width: barWidth, height: barHeight)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    @ViewBuilder
    private func minMaxMarkers(in rect: CGRect) -> some View {
        if let minIndex = data.indices.min(by: { data[$0] < data[$1] }),
           let maxIndex = data.indices.max(by: { data[$0] < data[$1] }) {
            let minPt = pointFor(index: minIndex, in: rect)
            let maxPt = pointFor(index: maxIndex, in: rect)

            Circle()
                .fill(theme.color(.error))
                .frame(width: 4, height: 4)
                .position(minPt)

            Circle()
                .fill(theme.color(.success))
                .frame(width: 4, height: 4)
                .position(maxPt)
        }
    }

    private func linePath(in rect: CGRect) -> Path {
        Path { path in
            guard data.count >= 2 else { return }
            for (index, _) in data.enumerated() {
                let pt = pointFor(index: index, in: rect)
                if index == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
        }
    }

    private func areaPath(in rect: CGRect) -> Path {
        Path { path in
            guard data.count >= 2 else { return }
            for (index, _) in data.enumerated() {
                let pt = pointFor(index: index, in: rect)
                if index == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }

    private func pointFor(index: Int, in rect: CGRect) -> CGPoint {
        let minVal = data.min() ?? 0
        let maxVal = data.max() ?? 1
        let range = maxVal - minVal
        let normalized = range > 0 ? (data[index] - minVal) / range : 0.5
        let x = data.count > 1 ? rect.minX + rect.width * CGFloat(index) / CGFloat(data.count - 1) : rect.midX
        let y = rect.maxY - rect.height * normalized
        return CGPoint(x: x, y: y)
    }

    private var accessibilityDescription: String {
        guard let first = data.first, let last = data.last else { return "Empty sparkline" }
        let trend = last > first ? "upward" : (last < first ? "downward" : "flat")
        return "Sparkline, \(data.count) points, \(trend) trend"
    }
}
