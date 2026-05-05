import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Data Visualization V2")
struct DataVisualizationV2Tests {

    // MARK: - Heatmap

    @Suite("Heatmap")
    struct HeatmapTests {

        @Test("PrismHeatmapCell stores row, column, and value")
        func cellStoresValues() {
            let cell = PrismHeatmapCell(row: 2, column: 3, value: 0.75)
            #expect(cell.row == 2)
            #expect(cell.column == 3)
            #expect(cell.value == 0.75)
        }

        @Test("PrismHeatmapCell is Hashable")
        func cellIsHashable() {
            let a = PrismHeatmapCell(row: 0, column: 0, value: 1.0)
            let b = PrismHeatmapCell(row: 0, column: 0, value: 1.0)
            #expect(a == b)
        }

        @Test("PrismHeatmapCell is Sendable")
        func cellIsSendable() {
            let cell = PrismHeatmapCell(row: 1, column: 1, value: 0.5)
            let sendable: any Sendable = cell
            #expect(sendable is PrismHeatmapCell)
        }

        @Test("PrismHeatmap from grid is a View")
        @MainActor func heatmapGridIsView() {
            let grid: [[Double]] = [[1, 2], [3, 4]]
            let view = PrismHeatmap(grid: grid)
            _ = view.body
        }

        @Test("PrismHeatmap from cells is a View")
        @MainActor func heatmapCellsIsView() {
            let cells = [
                PrismHeatmapCell(row: 0, column: 0, value: 1),
                PrismHeatmapCell(row: 0, column: 1, value: 2),
            ]
            let view = PrismHeatmap(cells: cells, rows: 1, columns: 2)
            _ = view.body
        }

        @Test("PrismHeatmap supports row and column labels")
        @MainActor func heatmapWithLabels() {
            let view = PrismHeatmap(
                grid: [[10, 20], [30, 40]],
                rowLabels: ["A", "B"],
                columnLabels: ["X", "Y"]
            )
            _ = view.body
        }
    }

    // MARK: - Treemap

    @Suite("Treemap")
    struct TreemapTests {

        @Test("PrismTreemapItem stores label, value, and children")
        func itemStoresProperties() {
            let child = PrismTreemapItem(id: "c1", label: "Child", value: 10)
            let parent = PrismTreemapItem(id: "p1", label: "Parent", value: 50, children: [child])
            #expect(parent.label == "Parent")
            #expect(parent.value == 50)
            #expect(parent.children.count == 1)
            #expect(parent.children.first?.label == "Child")
        }

        @Test("PrismTreemapItem is Identifiable by id")
        func itemIsIdentifiable() {
            let item = PrismTreemapItem(id: "test", label: "Test", value: 1)
            #expect(item.id == "test")
        }

        @Test("PrismTreemapItem is Sendable")
        func itemIsSendable() {
            let item = PrismTreemapItem(id: "s", label: "S", value: 5)
            let sendable: any Sendable = item
            #expect(sendable is PrismTreemapItem)
        }

        @Test("PrismTreemap is a View")
        @MainActor func treemapIsView() {
            let items = [
                PrismTreemapItem(id: "a", label: "A", value: 30),
                PrismTreemapItem(id: "b", label: "B", value: 20),
            ]
            let view = PrismTreemap(items: items)
            _ = view.body
        }
    }

    // MARK: - Radar Chart

    @Suite("Radar Chart")
    struct RadarChartTests {

        @Test("PrismRadarAxis stores label and maxValue")
        func axisStoresProperties() {
            let axis = PrismRadarAxis(label: "Speed", maxValue: 100)
            #expect(axis.label == "Speed")
            #expect(axis.maxValue == 100)
        }

        @Test("PrismRadarAxis is Sendable and Hashable")
        func axisConformances() {
            let a = PrismRadarAxis(label: "X", maxValue: 10)
            let b = PrismRadarAxis(label: "X", maxValue: 10)
            #expect(a == b)
            let sendable: any Sendable = a
            #expect(sendable is PrismRadarAxis)
        }

        @Test("PrismRadarDataSet stores values, color, and label")
        func dataSetStoresProperties() {
            let ds = PrismRadarDataSet(values: [1, 2, 3], color: .blue, label: "Series A")
            #expect(ds.values.count == 3)
            #expect(ds.label == "Series A")
        }

        @Test("PrismRadarDataSet is Sendable")
        func dataSetIsSendable() {
            let ds = PrismRadarDataSet(values: [5], color: .red, label: "S")
            let sendable: any Sendable = ds
            #expect(sendable is PrismRadarDataSet)
        }

        @Test("PrismRadarChart is a View with multiple data sets")
        @MainActor func radarChartIsView() {
            let axes = [
                PrismRadarAxis(label: "A", maxValue: 10),
                PrismRadarAxis(label: "B", maxValue: 10),
                PrismRadarAxis(label: "C", maxValue: 10),
            ]
            let sets = [
                PrismRadarDataSet(values: [8, 6, 9], color: .blue, label: "Team 1"),
                PrismRadarDataSet(values: [5, 7, 4], color: .red, label: "Team 2"),
            ]
            let view = PrismRadarChart(axes: axes, dataSets: sets)
            _ = view.body
        }
    }

    // MARK: - Sparkline

    @Suite("Sparkline")
    struct SparklineTests {

        @Test("PrismSparkline line style is a View")
        @MainActor func sparklineLineIsView() {
            let view = PrismSparkline(data: [1, 3, 2, 5, 4], style: .line)
            _ = view.body
        }

        @Test("PrismSparkline area style is a View")
        @MainActor func sparklineAreaIsView() {
            let view = PrismSparkline(data: [10, 20, 15, 25], style: .area)
            _ = view.body
        }

        @Test("PrismSparkline bar style is a View")
        @MainActor func sparklineBarIsView() {
            let view = PrismSparkline(data: [5, 10, 3, 8], style: .bar)
            _ = view.body
        }

        @Test("PrismSparklineStyle has all cases")
        func sparklineStyleCases() {
            let cases = PrismSparklineStyle.allCases
            #expect(cases.count == 3)
            #expect(cases.contains(.line))
            #expect(cases.contains(.area))
            #expect(cases.contains(.bar))
        }

        @Test("PrismSparkline supports min/max markers and trend color")
        @MainActor func sparklineWithMarkers() {
            let view = PrismSparkline(
                data: [1, 5, 2, 8, 3],
                style: .line,
                showMinMaxMarkers: true,
                trendColoring: true
            )
            _ = view.body
        }
    }

    // MARK: - Funnel Chart

    @Suite("Funnel Chart")
    struct FunnelChartTests {

        @Test("PrismFunnelStage stores label and value")
        func stageStoresProperties() {
            let stage = PrismFunnelStage(label: "Visitors", value: 1000)
            #expect(stage.label == "Visitors")
            #expect(stage.value == 1000)
        }

        @Test("PrismFunnelStage supports optional color")
        func stageOptionalColor() {
            let noColor = PrismFunnelStage(label: "A", value: 10)
            #expect(noColor.color == nil)
            let withColor = PrismFunnelStage(label: "B", value: 20, color: .red)
            #expect(withColor.color != nil)
        }

        @Test("PrismFunnelStage is Sendable and Hashable")
        func stageConformances() {
            let a = PrismFunnelStage(label: "X", value: 50)
            let b = PrismFunnelStage(label: "X", value: 50)
            #expect(a == b)
        }

        @Test("PrismFunnelChart is a View")
        @MainActor func funnelChartIsView() {
            let stages = [
                PrismFunnelStage(label: "Visitors", value: 1000),
                PrismFunnelStage(label: "Leads", value: 500),
                PrismFunnelStage(label: "Customers", value: 100),
            ]
            let view = PrismFunnelChart(stages: stages)
            _ = view.body
        }
    }

    // MARK: - Candlestick Chart

    @Suite("Candlestick Chart")
    struct CandlestickTests {

        @Test("PrismCandlestick stores OHLC values")
        func candlestickStoresOHLC() {
            let date = Date()
            let candle = PrismCandlestick(date: date, open: 100, high: 110, low: 95, close: 105)
            #expect(candle.open == 100)
            #expect(candle.high == 110)
            #expect(candle.low == 95)
            #expect(candle.close == 105)
            #expect(candle.date == date)
        }

        @Test("PrismCandlestick detects bullish vs bearish")
        func candlestickBullishBearish() {
            let bullish = PrismCandlestick(date: Date(), open: 100, high: 110, low: 95, close: 105)
            #expect(bullish.isBullish == true)
            let bearish = PrismCandlestick(date: Date(), open: 105, high: 110, low: 95, close: 100)
            #expect(bearish.isBullish == false)
        }

        @Test("PrismCandlestick is Sendable and Hashable")
        func candlestickConformances() {
            let date = Date()
            let a = PrismCandlestick(date: date, open: 1, high: 2, low: 0, close: 1.5)
            let b = PrismCandlestick(date: date, open: 1, high: 2, low: 0, close: 1.5)
            #expect(a == b)
        }

        @Test("PrismCandlestickChart is a View")
        @MainActor func candlestickChartIsView() {
            let now = Date()
            let candles = [
                PrismCandlestick(date: now, open: 100, high: 110, low: 95, close: 105),
                PrismCandlestick(date: now.addingTimeInterval(86400), open: 105, high: 115, low: 100, close: 108),
            ]
            let view = PrismCandlestickChart(candles: candles)
            _ = view.body
        }
    }
}
