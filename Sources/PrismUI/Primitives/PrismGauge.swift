import SwiftUI

/// Themed gauge with semantic color styling.
///
/// ```swift
/// PrismGauge(value: 0.7, label: "Battery")
/// PrismGauge(value: progress, in: 0...100, label: "Upload") {
///     Image(systemName: "arrow.up.circle")
/// }
/// ```
public struct PrismGauge<CurrentValueLabel: View>: View {
    @Environment(\.prismTheme) private var theme

    private let value: Double
    private let bounds: ClosedRange<Double>
    private let label: LocalizedStringKey
    private let currentValueLabel: CurrentValueLabel

    public init(
        value: Double,
        in bounds: ClosedRange<Double> = 0...1,
        label: LocalizedStringKey,
        @ViewBuilder currentValueLabel: () -> CurrentValueLabel
    ) {
        self.value = value
        self.bounds = bounds
        self.label = label
        self.currentValueLabel = currentValueLabel()
    }

    public var body: some View {
        Gauge(value: value, in: bounds) {
            Text(label)
                .foregroundStyle(theme.color(.onBackground))
        } currentValueLabel: {
            currentValueLabel
        }
        .tint(gaugeColor)
    }

    private var gaugeColor: Color {
        let normalized = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        if normalized < 0.3 {
            return theme.color(.error)
        } else if normalized < 0.7 {
            return theme.color(.warning)
        } else {
            return theme.color(.success)
        }
    }
}

extension PrismGauge where CurrentValueLabel == EmptyView {

    public init(
        value: Double,
        in bounds: ClosedRange<Double> = 0...1,
        label: LocalizedStringKey
    ) {
        self.value = value
        self.bounds = bounds
        self.label = label
        self.currentValueLabel = EmptyView()
    }
}
