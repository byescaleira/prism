import SwiftUI

#if canImport(Charts)
import Charts

/// Themed bar chart with PrismUI token styling.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PrismBarChart<Data: RandomAccessCollection>: View where Data.Element: Identifiable {
    @Environment(\.prismTheme) private var theme

    private let data: Data
    private let xLabel: KeyPath<Data.Element, String>
    private let yValue: KeyPath<Data.Element, Double>
    private let barColor: ColorToken

    public init(
        _ data: Data,
        x: KeyPath<Data.Element, String>,
        y: KeyPath<Data.Element, Double>,
        barColor: ColorToken = .interactive
    ) {
        self.data = data
        self.xLabel = x
        self.yValue = y
        self.barColor = barColor
    }

    public var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Category", item[keyPath: xLabel]),
                y: .value("Value", item[keyPath: yValue])
            )
            .foregroundStyle(theme.color(barColor))
            .cornerRadius(RadiusToken.xs.rawValue)
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                    .foregroundStyle(theme.color(.separator))
                AxisValueLabel()
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }
        }
    }
}

/// Themed line chart with PrismUI token styling.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PrismLineChart<Data: RandomAccessCollection>: View where Data.Element: Identifiable {
    @Environment(\.prismTheme) private var theme

    private let data: Data
    private let xValue: KeyPath<Data.Element, String>
    private let yValue: KeyPath<Data.Element, Double>
    private let lineColor: ColorToken
    private let showArea: Bool

    public init(
        _ data: Data,
        x: KeyPath<Data.Element, String>,
        y: KeyPath<Data.Element, Double>,
        lineColor: ColorToken = .interactive,
        showArea: Bool = false
    ) {
        self.data = data
        self.xValue = x
        self.yValue = y
        self.lineColor = lineColor
        self.showArea = showArea
    }

    public var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("X", item[keyPath: xValue]),
                y: .value("Y", item[keyPath: yValue])
            )
            .foregroundStyle(theme.color(lineColor))
            .interpolationMethod(.catmullRom)

            if showArea {
                AreaMark(
                    x: .value("X", item[keyPath: xValue]),
                    y: .value("Y", item[keyPath: yValue])
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [theme.color(lineColor).opacity(0.3), theme.color(lineColor).opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                    .foregroundStyle(theme.color(.separator))
                AxisValueLabel()
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }
        }
    }
}

/// Themed donut/pie chart.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct PrismDonutChart<Data: RandomAccessCollection>: View where Data.Element: Identifiable {
    @Environment(\.prismTheme) private var theme

    private let data: Data
    private let label: KeyPath<Data.Element, String>
    private let value: KeyPath<Data.Element, Double>
    private let colors: [ColorToken]

    public init(
        _ data: Data,
        label: KeyPath<Data.Element, String>,
        value: KeyPath<Data.Element, Double>,
        colors: [ColorToken] = [.interactive, .success, .warning, .error, .info, .brand]
    ) {
        self.data = data
        self.label = label
        self.value = value
        self.colors = colors
    }

    public var body: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("Value", item[keyPath: value]),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .foregroundStyle(by: .value("Category", item[keyPath: label]))
            .cornerRadius(RadiusToken.xs.rawValue)
        }
        .chartForegroundStyleScale(range: colors.prefix(data.count).map { theme.color($0) })
    }
}
#endif
