import SwiftUI

/// Themed slider with value label and optional range display.
public struct PrismSlider: View {
    @Environment(\.prismTheme) private var theme

    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double?
    private let title: LocalizedStringKey
    private let showValue: Bool
    private let format: (Double) -> String

    public init(
        _ title: LocalizedStringKey,
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        step: Double? = nil,
        showValue: Bool = true,
        format: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.showValue = showValue
        self.format = format
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            HStack {
                Text(title)
                    .font(TypographyToken.body.font)
                    .foregroundStyle(theme.color(.onSurface))

                Spacer()

                if showValue {
                    Text(format(value))
                        .font(TypographyToken.body.font(weight: .medium))
                        .foregroundStyle(theme.color(.interactive))
                        .monospacedDigit()
                }
            }

            if let step {
                Slider(value: $value, in: range, step: step)
                    .tint(theme.color(.interactive))
            } else {
                Slider(value: $value, in: range)
                    .tint(theme.color(.interactive))
            }
        }
        .padding(.vertical, SpacingToken.xs.rawValue)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(Text(format(value)))
    }
}
