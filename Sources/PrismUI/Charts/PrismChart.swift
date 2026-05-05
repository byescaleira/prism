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

        /// Creates a bar chart from data with key paths for the x label and y value.
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

        /// The bar chart view body with themed axis styling.
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("Bar chart with \(data.count) items"))
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

        /// Creates a line chart from data with key paths for x and y, and optional area fill.
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

        /// The line chart view body with optional gradient area fill.
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("Line chart with \(data.count) data points"))
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

        /// Creates a donut chart from data with key paths for label and value.
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

        /// The donut chart view body with golden-ratio inner radius.
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("Donut chart with \(data.count) segments"))
        }
    }
#endif
