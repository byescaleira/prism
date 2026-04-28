import SwiftUI

/// A node in a treemap hierarchy.
public struct PrismTreemapItem: Sendable, Identifiable, Hashable {
    /// Unique identifier for this item.
    public let id: String
    /// Display label for the node.
    public let label: String
    /// Numeric weight driving the area allocation.
    public let value: Double
    /// Optional override color for this node.
    public let color: Color?
    /// Child nodes for drill-down navigation.
    public let children: [PrismTreemapItem]

    /// Creates a treemap node.
    public init(
        id: String,
        label: String,
        value: Double,
        color: Color? = nil,
        children: [PrismTreemapItem] = []
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.color = color
        self.children = children
    }

    public static func == (lhs: PrismTreemapItem, rhs: PrismTreemapItem) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// A treemap chart using a squarified layout algorithm with drill-down.
@MainActor
public struct PrismTreemap: View {
    @Environment(\.prismTheme) private var theme
    @State private var breadcrumb: [PrismTreemapItem] = []

    private let rootItems: [PrismTreemapItem]
    private let palette: [Color]

    /// Creates a treemap from a list of hierarchical items.
    public init(
        items: [PrismTreemapItem],
        palette: [Color]? = nil
    ) {
        self.rootItems = items
        self.palette = palette ?? [.blue, .green, .orange, .purple, .pink, .teal, .indigo, .mint]
    }

    private var currentItems: [PrismTreemapItem] {
        breadcrumb.last?.children.isEmpty == false ? breadcrumb.last!.children : (breadcrumb.isEmpty ? rootItems : [])
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
            if !breadcrumb.isEmpty {
                breadcrumbBar
            }
            GeometryReader { geo in
                treemapLayout(items: currentItems.isEmpty ? rootItems : currentItems, rect: geo.frame(in: .local))
            }
        }
    }

    @ViewBuilder
    private var breadcrumbBar: some View {
        HStack(spacing: SpacingToken.xs.rawValue) {
            Button {
                breadcrumb.removeAll()
            } label: {
                Text("Root")
                    .font(.caption)
                    .foregroundStyle(theme.color(.interactive))
            }
            .buttonStyle(.plain)

            ForEach(Array(breadcrumb.enumerated()), id: \.element.id) { index, crumb in
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))

                Button {
                    breadcrumb = Array(breadcrumb.prefix(index + 1))
                } label: {
                    Text(crumb.label)
                        .font(.caption)
                        .foregroundStyle(index == breadcrumb.count - 1 ? theme.color(.onBackground) : theme.color(.interactive))
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Breadcrumb: \(breadcrumb.map(\.label).joined(separator: ", "))")
    }

    @ViewBuilder
    private func treemapLayout(items: [PrismTreemapItem], rect: CGRect) -> some View {
        let rects = squarify(items: items, in: rect)
        ZStack(alignment: .topLeading) {
            ForEach(Array(rects.enumerated()), id: \.element.0.id) { index, pair in
                let (item, frame) = pair
                let fillColor = item.color ?? palette[index % palette.count]

                RoundedRectangle(cornerRadius: RadiusToken.xs.rawValue)
                    .fill(fillColor.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: RadiusToken.xs.rawValue)
                            .strokeBorder(theme.color(.background).opacity(0.5), lineWidth: 1)
                    )
                    .overlay(
                        Text(item.label)
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .padding(2)
                    )
                    .frame(width: max(frame.width - 1, 0), height: max(frame.height - 1, 0))
                    .offset(x: frame.minX, y: frame.minY)
                    .onTapGesture {
                        if !item.children.isEmpty {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                breadcrumb.append(item)
                            }
                        }
                    }
                    .accessibilityLabel("\(item.label): \(item.value, specifier: "%.1f")")
                    .accessibilityAddTraits(item.children.isEmpty ? [] : .isButton)
            }
        }
    }

    /// Squarified treemap layout producing positioned rects for each item.
    private func squarify(items: [PrismTreemapItem], in rect: CGRect) -> [(PrismTreemapItem, CGRect)] {
        let totalValue = items.reduce(0) { $0 + max($1.value, 0) }
        guard totalValue > 0, !items.isEmpty else { return [] }

        var results: [(PrismTreemapItem, CGRect)] = []
        var remaining = items.sorted { $0.value > $1.value }
        var currentRect = rect

        while !remaining.isEmpty {
            let isWide = currentRect.width >= currentRect.height
            let sideLength = isWide ? currentRect.height : currentRect.width
            let remainingTotal = remaining.reduce(0.0) { $0 + max($1.value, 0) }
            let areaScale = (currentRect.width * currentRect.height) / remainingTotal

            var row: [PrismTreemapItem] = []
            var rowArea: Double = 0

            for item in remaining {
                let testRow = row + [item]
                let testArea = rowArea + max(item.value, 0) * areaScale
                let testRatio = worstAspectRatio(areas: testRow.map { max($0.value, 0) * areaScale }, side: sideLength, totalArea: testArea)
                let currentRatio = row.isEmpty ? Double.infinity : worstAspectRatio(areas: row.map { max($0.value, 0) * areaScale }, side: sideLength, totalArea: rowArea)

                if testRatio <= currentRatio || row.isEmpty {
                    row.append(item)
                    rowArea = testArea
                } else {
                    break
                }
            }

            remaining.removeFirst(row.count)

            let rowLength = sideLength > 0 ? rowArea / sideLength : 0
            var offset: CGFloat = 0

            for item in row {
                let itemArea = max(item.value, 0) * areaScale
                let itemLength = rowLength > 0 ? itemArea / rowLength : 0

                let itemRect: CGRect
                if isWide {
                    itemRect = CGRect(x: currentRect.minX, y: currentRect.minY + offset, width: rowLength, height: itemLength)
                } else {
                    itemRect = CGRect(x: currentRect.minX + offset, y: currentRect.minY, width: itemLength, height: rowLength)
                }
                results.append((item, itemRect))
                offset += itemLength
            }

            if isWide {
                currentRect = CGRect(x: currentRect.minX + rowLength, y: currentRect.minY, width: currentRect.width - rowLength, height: currentRect.height)
            } else {
                currentRect = CGRect(x: currentRect.minX, y: currentRect.minY + rowLength, width: currentRect.width, height: currentRect.height - rowLength)
            }
        }

        return results
    }

    private func worstAspectRatio(areas: [Double], side: CGFloat, totalArea: Double) -> Double {
        let sideD = Double(side)
        guard sideD > 0, totalArea > 0 else { return .infinity }
        let rowLength = totalArea / sideD
        guard rowLength > 0 else { return .infinity }
        return areas.reduce(0.0) { worst, area in
            let w = area / rowLength
            let ratio = w > 0 ? max(rowLength / w, w / rowLength) : .infinity
            return max(worst, ratio)
        }
    }
}
