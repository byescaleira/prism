import SwiftUI

/// Validation rule for form fields.
public struct PrismValidationRule: Sendable {
    /// Closure that returns true when the input string is valid.
    public let validate: @Sendable (String) -> Bool
    /// Error message shown when validation fails.
    public let message: String

    /// Creates a validation rule with a predicate and error message.
    public init(validate: @Sendable @escaping (String) -> Bool, message: String) {
        self.validate = validate
        self.message = message
    }
}

// MARK: - Built-in Rules

extension PrismValidationRule {

    /// Validates that the field is not empty or whitespace-only.
    public static let required = PrismValidationRule(
        validate: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
        message: "This field is required"
    )

    /// Validates that the input has at least the given number of characters.
    public static func minLength(_ length: Int) -> PrismValidationRule {
        PrismValidationRule(
            validate: { $0.count >= length },
            message: "Must be at least \(length) characters"
        )
    }

    /// Validates that the input has at most the given number of characters.
    public static func maxLength(_ length: Int) -> PrismValidationRule {
        PrismValidationRule(
            validate: { $0.count <= length },
            message: "Must be at most \(length) characters"
        )
    }

    /// Validates that the input matches a standard email address pattern.
    public static let email = PrismValidationRule(
        validate: { value in
            let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            return value.range(of: pattern, options: .regularExpression) != nil
        },
        message: "Enter a valid email address"
    )

    /// Validates that the input matches the given regular expression pattern.
    public static func regex(_ pattern: String, message: String) -> PrismValidationRule {
        PrismValidationRule(
            validate: { $0.range(of: pattern, options: .regularExpression) != nil },
            message: message
        )
    }

    /// Validates that the numeric input falls within the given closed range.
    public static func range(_ range: ClosedRange<Int>) -> PrismValidationRule {
        PrismValidationRule(
            validate: {
                guard let num = Int($0) else { return false }
                return range.contains(num)
            },
            message: "Must be between \(range.lowerBound) and \(range.upperBound)"
        )
    }
}

// MARK: - Validated Field

/// Text field with inline validation error display.
///
/// ```swift
/// PrismValidatedField("Email", text: $email, rules: [.required, .email])
/// ```
public struct PrismValidatedField: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    @Binding private var text: String
    private let rules: [PrismValidationRule]
    @State private var errorMessage: String?
    @State private var hasInteracted = false
    @FocusState private var isFocused: Bool

    /// Creates a validated field with the given title, text binding, and validation rules.
    public init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        rules: [PrismValidationRule]
    ) {
        self.title = title
        self._text = text
        self.rules = rules
    }

    /// The validated field view body with inline error display.
    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            TextField(title, text: $text)
                .focused($isFocused)
                .textFieldStyle(.roundedBorder)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            errorMessage != nil && hasInteracted
                                ? theme.color(.error)
                                : Color.clear,
                            lineWidth: 1.5
                        )
                )
                .onChange(of: isFocused) { _, focused in
                    if !focused {
                        hasInteracted = true
                        validate()
                    }
                }
                .onChange(of: text) { _, _ in
                    if hasInteracted { validate() }
                }

            if let errorMessage, hasInteracted {
                Text(errorMessage)
                    .font(TypographyToken.caption.font)
                    .foregroundStyle(theme.color(.error))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: errorMessage)
    }

    private func validate() {
        for rule in rules {
            if !rule.validate(text) {
                errorMessage = rule.message
                return
            }
        }
        errorMessage = nil
    }

    /// Returns whether the current value passes all rules.
    public var isValid: Bool {
        rules.allSatisfy { $0.validate(text) }
    }
}
