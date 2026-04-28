import SwiftUI

/// A stage in a funnel chart.
public struct PrismFunnelStage: Sendable, Hashable, Identifiable {
    /// Stable identity for SwiftUI.
    public var id: String { label }
    /// Display label for this stage.
    public let label: String
    /// Numeric value for this stage.
    public let value: Double
    /// Optional color override.
    public let color: Color?

    /// Creates a funnel stage.
    public init(label: String, value: Double, color: Color? = nil) {
        self.label = label
        self.value = value
        self.color = color
    }
}

/// A funnel chart with tapered trapezoid stages and conversion rate labels.
@MainActor
public struct PrismFunnelChart: View {
    @Environment(\.prismTheme) private var theme

    private let stages: [PrismFunnelStage]
    private let palette: [Color]

    /// Creates a funnel chart from an array of stages.
    public init(
        stages: [PrismFunnelStage],
        palette: [Color]? = nil
    ) {
        self.stages = stages
        self.palette = palette ?? [.blue, .cyan, .teal, .green, .mint, .orange, .purple]
    }

    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let stageCount = stages.count

            if stageCount > 0 {
                let maxValue = stages.map(\.value).max() ?? 1
                let stageHeight = geo.size.height / CGFloat(stageCount)

                VStack(spacing: 0) {
                    ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                    let currentWidth = maxValue > 0 ? width * (stage.value / maxValue) : 0
                    let nextWidth: CGFloat = {
                        if index + 1 < stageCount {
                            return maxValue > 0 ? width * (stages[index + 1].value / maxValue) : 0
                        }
                        return currentWidth * 0.6
                    }()
                    let fillColor = stage.color ?? palette[index % palette.count]
                    let conversionRate: Double? = {
                        if index + 1 < stageCount, stage.value > 0 {
                            return stages[index + 1].value / stage.value * 100
                        }
                        return nil
                    }()

                    ZStack {
                        trapezoid(topWidth: currentWidth, bottomWidth: nextWidth, containerWidth: width, height: stageHeight)
                            .fill(fillColor.opacity(0.85))
                        trapezoid(topWidth: currentWidth, bottomWidth: nextWidth, containerWidth: width, height: stageHeight)
                            .stroke(fillColor, lineWidth: 1)

                        VStack(spacing: 2) {
                            Text(stage.label)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                            Text("\(stage.value, specifier: "%.0f")")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.8))
                            if let rate = conversionRate {
                                Text("\(rate, specifier: "%.1f")%")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                    .frame(height: stageHeight)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(stage.label): \(stage.value, specifier: "%.0f")\(conversionRate.map { ", conversion \($0, specifier: "%.1f")%" } ?? "")")
                }
                }
            }
        }
    }

    private func trapezoid(topWidth: CGFloat, bottomWidth: CGFloat, containerWidth: CGFloat, height: CGFloat) -> Path {
        Path { path in
            let topInset = (containerWidth - topWidth) / 2
            let bottomInset = (containerWidth - bottomWidth) / 2

            path.move(to: CGPoint(x: topInset, y: 0))
            path.addLine(to: CGPoint(x: topInset + topWidth, y: 0))
            path.addLine(to: CGPoint(x: bottomInset + bottomWidth, y: height))
            path.addLine(to: CGPoint(x: bottomInset, y: height))
            path.closeSubpath()
        }
    }
}
