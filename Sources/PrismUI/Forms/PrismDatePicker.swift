import SwiftUI

/// Themed date picker with label and icon support.
public struct PrismDatePicker: View {
    @Environment(\.prismTheme) private var theme

    @Binding private var selection: Date
    private let title: LocalizedStringKey
    private let icon: String?
    private let components: DatePickerComponents
    private let range: ClosedRange<Date>?

    /// Creates a date picker with title, icon, components, and optional range.
    public init(
        _ title: LocalizedStringKey,
        selection: Binding<Date>,
        icon: String? = nil,
        components: DatePickerComponents = [.date],
        in range: ClosedRange<Date>? = nil
    ) {
        self.title = title
        self._selection = selection
        self.icon = icon
        self.components = components
        self.range = range
    }

    /// The date picker view body with themed label and tint.
    public var body: some View {
        Group {
            if let range {
                DatePicker(selection: $selection, in: range, displayedComponents: components) {
                    label
                }
            } else {
                DatePicker(selection: $selection, displayedComponents: components) {
                    label
                }
            }
        }
        .tint(theme.color(.interactive))
    }

    private var label: some View {
        HStack(spacing: SpacingToken.md.rawValue) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(theme.color(.interactive))
                    .frame(width: 28)
                    .accessibilityHidden(true)
            }

            Text(title)
                .font(TypographyToken.body.font)
                .foregroundStyle(theme.color(.onSurface))
        }
        .accessibilityElement(children: .combine)
    }
}
