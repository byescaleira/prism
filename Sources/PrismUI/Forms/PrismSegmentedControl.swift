import SwiftUI

/// Themed segmented picker with Apple HIG styling.
public struct PrismSegmentedControl<SelectionValue: Hashable>: View {
    @Environment(\.prismTheme) private var theme

    @Binding private var selection: SelectionValue
    private let label: LocalizedStringKey?
    private let content: () -> AnyView

    public init<C: View>(
        _ label: LocalizedStringKey? = nil,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: @escaping () -> C
    ) {
        self.label = label
        self._selection = selection
        self.content = { AnyView(content()) }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            if let label {
                Text(label)
                    .font(TypographyToken.caption.font(weight: .medium))
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }

            Picker(label ?? "", selection: $selection) {
                content()
            }
            .pickerStyle(.segmented)
            .accessibilityLabel(label ?? "Selection")
        }
    }
}
