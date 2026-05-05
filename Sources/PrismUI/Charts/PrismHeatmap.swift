import SwiftUI

/// A single cell in a heatmap grid.
public struct PrismHeatmapCell: Sendable, Hashable {
    /// Row index of the cell.
    public let row: Int
    /// Column index of the cell.
    public let column: Int
    /// Numeric value driving the cell color.
    public let value: Double

    /// Creates a heatmap cell at a given position.
    public init(row: Int, column: Int, value: Double) {
        self.row = row
        self.column = column
        self.value = value
    }
}

/// A heatmap chart that renders a colored grid from numeric data.
@MainActor
public struct PrismHeatmap: View {
    @Environment(\.prismTheme) private var theme

    private let cells: [PrismHeatmapCell]
    private let rows: Int
    private let columns: Int
    private let rowLabels: [String]?
    private let columnLabels: [String]?
    private let lowColor: Color?
    private let highColor: Color?

    /// Creates a heatmap from a flat array of cells.
    public init(
        cells: [PrismHeatmapCell],
        rows: Int,
        columns: Int,
        rowLabels: [String]? = nil,
        columnLabels: [String]? = nil,
        lowColor: Color? = nil,
        highColor: Color? = nil
    ) {
        self.cells = cells
        self.rows = rows
        self.columns = columns
        self.rowLabels = rowLabels
        self.columnLabels = columnLabels
        self.lowColor = lowColor
        self.highColor = highColor
    }

    /// Creates a heatmap from a 2D grid of doubles.
    public init(
        grid: [[Double]],
        rowLabels: [String]? = nil,
        columnLabels: [String]? = nil,
        lowColor: Color? = nil,
        highColor: Color? = nil
    ) {
        let rowCount = grid.count
        let colCount = grid.first?.count ?? 0
        var built: [PrismHeatmapCell] = []
        for r in 0..<rowCount {
            for c in 0..<min(grid[r].count, colCount) {
                built.append(PrismHeatmapCell(row: r, column: c, value: grid[r][c]))
            }
        }
        self.cells = built
        self.rows = rowCount
        self.columns = colCount
        self.rowLabels = rowLabels
        self.columnLabels = columnLabels
        self.lowColor = lowColor
        self.highColor = highColor
    }

    /// The heatmap view body with color-interpolated grid cells.
    public var body: some View {
        let minValue = cells.map(\.value).min() ?? 0
        let maxValue = cells.map(\.value).max() ?? 1
        let range = maxValue - minValue
        let low = lowColor ?? theme.color(.info)
        let high = highColor ?? theme.color(.error)

        VStack(spacing: 1) {
            if let columnLabels {
                HStack(spacing: 1) {
                    if rowLabels != nil {
                        Text("")
                            .frame(width: 40)
                    }
                    ForEach(Array(columnLabels.prefix(columns).enumerated()), id: \.offset) { _, label in
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(theme.color(.onBackgroundSecondary))
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 1) {
                    if let rowLabels, row < rowLabels.count {
                        Text(rowLabels[row])
                            .font(.caption2)
                            .foregroundStyle(theme.color(.onBackgroundSecondary))
                            .frame(width: 40, alignment: .trailing)
                    }
                    ForEach(0..<columns, id: \.self) { col in
                        let cell = cells.first { $0.row == row && $0.column == col }
                        let normalized = range > 0 ? ((cell?.value ?? 0) - minValue) / range : 0.5
                        Rectangle()
                            .fill(interpolateColor(from: low, to: high, fraction: normalized))
                            .aspectRatio(1, contentMode: .fit)
                            .accessibilityLabel(
                                "Row \(row), Column \(col), Value \(cell?.value ?? 0, specifier: "%.1f")")
                    }
                }
            }
        }
    }

    /// Linearly interpolates between two colors.
    private func interpolateColor(from: Color, to: Color, fraction: Double) -> Color {
        let f = min(max(fraction, 0), 1)
        let fromResolved = from.resolve(in: EnvironmentValues())
        let toResolved = to.resolve(in: EnvironmentValues())
        let r = Double(fromResolved.red) + (Double(toResolved.red) - Double(fromResolved.red)) * f
        let g = Double(fromResolved.green) + (Double(toResolved.green) - Double(fromResolved.green)) * f
        let b = Double(fromResolved.blue) + (Double(toResolved.blue) - Double(fromResolved.blue)) * f
        return Color(red: r, green: g, blue: b)
    }
}
