import SwiftUI

/// Themed color picker with preset swatches and custom selection.
public struct PrismColorWell: View {
    @Environment(\.prismTheme) private var theme

    @Binding private var selection: Color
    private let label: LocalizedStringKey?
    private let presets: [Color]
    private let showCustomPicker: Bool

    public init(
        _ label: LocalizedStringKey? = nil,
        selection: Binding<Color>,
        presets: [Color] = Self.defaultPresets,
        showCustomPicker: Bool = true
    ) {
        self.label = label
        self._selection = selection
        self.presets = presets
        self.showCustomPicker = showCustomPicker
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
            if let label {
                Text(label)
                    .font(TypographyToken.caption.font(weight: .medium))
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }

            HStack(spacing: SpacingToken.sm.rawValue) {
                presetSwatches

                if showCustomPicker {
                    Divider()
                        .frame(height: 32)

                    ColorPicker("", selection: $selection, supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 32, height: 32)
                        .accessibilityLabel(PrismStrings.customColor)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label ?? "Color picker")
    }

    private var presetSwatches: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            ForEach(Array(presets.enumerated()), id: \.offset) { _, color in
                swatchButton(color)
            }
        }
    }

    private func swatchButton(_ color: Color) -> some View {
        Button {
            selection = color
        } label: {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(theme.color(.border), lineWidth: 1)
                )
                .overlay {
                    if isSelected(color) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(radius: 1)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(PrismStrings.colorSwatch)
        .accessibilityAddTraits(isSelected(color) ? .isSelected : [])
    }

    private func isSelected(_ color: Color) -> Bool {
        color.description == selection.description
    }

    public static var defaultPresets: [Color] {
        [.red, .orange, .yellow, .green, .mint, .cyan, .blue, .indigo, .purple, .pink]
    }
}
