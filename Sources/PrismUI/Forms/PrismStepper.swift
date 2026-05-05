import SwiftUI

/// Themed stepper with value display and configurable range.
public struct PrismStepper: View {
    @Environment(\.prismTheme) private var theme

    @Binding private var value: Int
    private let label: LocalizedStringKey
    private let icon: String?
    private let range: ClosedRange<Int>
    private let step: Int
    private let format: ((Int) -> String)?

    /// Creates a themed stepper with label, range, step size, and optional formatting.
    public init(
        _ label: LocalizedStringKey,
        value: Binding<Int>,
        in range: ClosedRange<Int> = 0...100,
        step: Int = 1,
        icon: String? = nil,
        format: ((Int) -> String)? = nil
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.icon = icon
        self.format = format
    }

    /// The stepper view body with icon, label, and formatted value.
    public var body: some View {
        Stepper(value: $value, in: range, step: step) {
            HStack(spacing: SpacingToken.sm.rawValue) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(theme.color(.interactive))
                        .frame(width: 28)
                }

                VStack(alignment: .leading, spacing: SpacingToken.xxs.rawValue) {
                    Text(label)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onSurface))

                    Text(displayValue)
                        .font(TypographyToken.footnote.font)
                        .foregroundStyle(theme.color(.onSurfaceSecondary))
                }
            }
        }
        .accessibilityValue(displayValue)
    }

    private var displayValue: String {
        format?(value) ?? "\(value)"
    }
}
