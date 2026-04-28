#if canImport(SwiftData)
import SwiftUI
import SwiftData

/// Supported field types for model form generation.
public enum FieldType: Sendable, Equatable {
    /// Single-line text input.
    case text
    /// Numeric input.
    case number
    /// Boolean toggle.
    case toggle
    /// Date picker.
    case date
    /// Selection from a list of options.
    case picker([String])
}

/// Describes a single field in a model form.
public struct PrismFormField: Sendable {
    /// Display label for the field.
    public let label: String
    /// Key path string identifying the model property.
    public let keyPath: String
    /// The type of input control to render.
    public let fieldType: FieldType

    /// Creates a form field definition.
    public init(label: String, keyPath: String, fieldType: FieldType) {
        self.label = label
        self.keyPath = keyPath
        self.fieldType = fieldType
    }
}

/// Generates form views from an array of field definitions.
@MainActor
public struct PrismModelFormBuilder: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    private let title: String
    private let fields: [PrismFormField]
    private let onSave: @MainActor ([String: Any]) -> Void
    private let onCancel: (@MainActor () -> Void)?

    @State private var textValues: [String: String] = [:]
    @State private var numberValues: [String: Double] = [:]
    @State private var toggleValues: [String: Bool] = [:]
    @State private var dateValues: [String: Date] = [:]
    @State private var pickerValues: [String: String] = [:]
    @State private var validationErrors: [String: String] = [:]

    /// Creates a form builder from field definitions.
    public init(
        title: String = "New Item",
        fields: [PrismFormField],
        onSave: @escaping @MainActor ([String: Any]) -> Void,
        onCancel: (@MainActor () -> Void)? = nil
    ) {
        self.title = title
        self.fields = fields
        self.onSave = onSave
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationStack {
            PrismModelForm {
                ForEach(fields, id: \.keyPath) { field in
                    buildField(field)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if let cancel = onCancel {
                            cancel()
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveForm()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func buildField(_ field: PrismFormField) -> some View {
        switch field.fieldType {
        case .text:
            let binding = Binding<String>(
                get: { textValues[field.keyPath, default: ""] },
                set: { textValues[field.keyPath] = $0 }
            )
            TextField(field.label, text: binding)
                .accessibilityLabel(field.label)

        case .number:
            let binding = Binding<Double>(
                get: { numberValues[field.keyPath, default: 0] },
                set: { numberValues[field.keyPath] = $0 }
            )
            LabeledContent(field.label) {
                TextField(field.label, value: binding, format: .number)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .multilineTextAlignment(.trailing)
            }
            .accessibilityLabel(field.label)

        case .toggle:
            let binding = Binding<Bool>(
                get: { toggleValues[field.keyPath, default: false] },
                set: { toggleValues[field.keyPath] = $0 }
            )
            Toggle(field.label, isOn: binding)
                .accessibilityLabel(field.label)

        case .date:
            let binding = Binding<Date>(
                get: { dateValues[field.keyPath, default: Date()] },
                set: { dateValues[field.keyPath] = $0 }
            )
            DatePicker(field.label, selection: binding, displayedComponents: [.date, .hourAndMinute])
                .accessibilityLabel(field.label)

        case .picker(let options):
            let binding = Binding<String>(
                get: { pickerValues[field.keyPath, default: options.first ?? ""] },
                set: { pickerValues[field.keyPath] = $0 }
            )
            Picker(field.label, selection: binding) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .accessibilityLabel(field.label)
        }
    }

    private func saveForm() {
        var result: [String: Any] = [:]
        for field in fields {
            switch field.fieldType {
            case .text:
                result[field.keyPath] = textValues[field.keyPath, default: ""]
            case .number:
                result[field.keyPath] = numberValues[field.keyPath, default: 0]
            case .toggle:
                result[field.keyPath] = toggleValues[field.keyPath, default: false]
            case .date:
                result[field.keyPath] = dateValues[field.keyPath, default: Date()]
            case .picker(let options):
                result[field.keyPath] = pickerValues[field.keyPath, default: options.first ?? ""]
            }
        }
        onSave(result)
        dismiss()
    }
}
#endif
