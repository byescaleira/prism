import SwiftUI

/// Themed text field with validation, error display, and accessibility.
public struct PrismTextField: View {
    @Environment(\.prismTheme) private var theme
    @FocusState private var isFocused: Bool

    @Binding private var text: String
    private let title: LocalizedStringKey
    private let validation: Validation?
    private let axis: Axis

    @State private var errorMessage: LocalizedStringKey?

    /// Creates a themed text field with a title, text binding, axis, and optional validation.
    public init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        axis: Axis = .horizontal,
        validation: Validation? = nil
    ) {
        self.title = title
        self._text = text
        self.axis = axis
        self.validation = validation
    }

    /// The content and behavior of the text field.
    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            textField
                .focused($isFocused)
                .onChange(of: isFocused) { _, focused in
                    if !focused { validate() }
                }

            if let errorMessage {
                Text(errorMessage)
                    .font(TypographyToken.caption.font)
                    .foregroundStyle(theme.color(.error))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var textField: some View {
        TextField(title, text: $text, axis: axis)
            .font(TypographyToken.body.font)
            .foregroundStyle(theme.color(.onSurface))
            .padding(.horizontal, SpacingToken.lg.rawValue)
            .padding(.vertical, SpacingToken.md.rawValue)
            .frame(minHeight: 44)
            .background(theme.color(.surfaceSecondary), in: RadiusToken.md.shape)
            .overlay(
                RadiusToken.md.shape
                    .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
            )
            .accessibilityLabel(title)
    }

    private var borderColor: Color {
        if errorMessage != nil {
            return theme.color(.error)
        }
        return isFocused ? theme.color(.interactive) : theme.color(.borderSubtle)
    }

    private func validate() {
        guard let validation else {
            errorMessage = nil
            return
        }

        switch validation {
        case .required(let message):
            errorMessage = text.isEmpty ? message : nil

        case .minLength(let count, let message):
            errorMessage = text.count < count ? message : nil

        case .maxLength(let count, let message):
            errorMessage = text.count > count ? message : nil

        case .pattern(let regex, let message):
            let match = text.range(of: regex, options: .regularExpression) != nil
            errorMessage = match ? nil : message

        case .custom(let validator):
            errorMessage = validator(text)
        }
    }
}

// MARK: - Validation

extension PrismTextField {

    /// Validation rules for text field input.
    public enum Validation {
        /// Requires a non-empty value.
        case required(LocalizedStringKey)
        /// Requires a minimum character count.
        case minLength(Int, LocalizedStringKey)
        /// Requires a maximum character count.
        case maxLength(Int, LocalizedStringKey)
        /// Requires the text to match a regex pattern.
        case pattern(String, LocalizedStringKey)
        /// Applies a custom validation closure returning an error message or nil.
        case custom((String) -> LocalizedStringKey?)
    }
}
