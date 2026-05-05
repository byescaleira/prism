import Foundation

/// A single validation rule that checks a string value.
public struct PrismValidationRule: Sendable {
    private let name: String
    private let check: @Sendable (String?) -> String?

    /// Creates a new `PrismValidationRule` with the specified configuration.
    public init(name: String, check: @escaping @Sendable (String?) -> String?) {
        self.name = name
        self.check = check
    }

    func validate(_ value: String?) -> String? {
        check(value)
    }

    /// Value must be present and non-empty.
    public static let required = PrismValidationRule(name: "required") { value in
        guard let value, !value.isEmpty else { return "is required" }
        return nil
    }

    /// Value must be a valid email address.
    public static let email = PrismValidationRule(name: "email") { value in
        guard let value, !value.isEmpty else { return nil }
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard value.range(of: pattern, options: .regularExpression) != nil else {
            return "must be a valid email"
        }
        return nil
    }

    /// Value must have at least N characters.
    public static func minLength(_ n: Int) -> PrismValidationRule {
        PrismValidationRule(name: "minLength") { value in
            guard let value, !value.isEmpty else { return nil }
            guard value.count >= n else { return "must be at least \(n) characters" }
            return nil
        }
    }

    /// Value must have at most N characters.
    public static func maxLength(_ n: Int) -> PrismValidationRule {
        PrismValidationRule(name: "maxLength") { value in
            guard let value, !value.isEmpty else { return nil }
            guard value.count <= n else { return "must be at most \(n) characters" }
            return nil
        }
    }

    /// Value must be a valid integer.
    public static let integer = PrismValidationRule(name: "integer") { value in
        guard let value, !value.isEmpty else { return nil }
        guard Int(value) != nil else { return "must be an integer" }
        return nil
    }

    /// Value must be a valid number.
    public static let numeric = PrismValidationRule(name: "numeric") { value in
        guard let value, !value.isEmpty else { return nil }
        guard Double(value) != nil else { return "must be a number" }
        return nil
    }

    /// Integer value must be at least N.
    public static func min(_ n: Int) -> PrismValidationRule {
        PrismValidationRule(name: "min") { value in
            guard let value, let num = Int(value) else { return nil }
            guard num >= n else { return "must be at least \(n)" }
            return nil
        }
    }

    /// Integer value must be at most N.
    public static func max(_ n: Int) -> PrismValidationRule {
        PrismValidationRule(name: "max") { value in
            guard let value, let num = Int(value) else { return nil }
            guard num <= n else { return "must be at most \(n)" }
            return nil
        }
    }

    /// Value must match the given regex pattern.
    public static func pattern(_ regex: String, _ message: String = "has invalid format") -> PrismValidationRule {
        PrismValidationRule(name: "pattern") { value in
            guard let value, !value.isEmpty else { return nil }
            guard value.range(of: regex, options: .regularExpression) != nil else { return message }
            return nil
        }
    }

    /// Value must be one of the allowed values.
    public static func oneOf(_ allowed: [String]) -> PrismValidationRule {
        PrismValidationRule(name: "oneOf") { value in
            guard let value, !value.isEmpty else { return nil }
            guard allowed.contains(value) else { return "must be one of: \(allowed.joined(separator: ", "))" }
            return nil
        }
    }

    /// Value must be a valid URL.
    public static let url = PrismValidationRule(name: "url") { value in
        guard let value, !value.isEmpty else { return nil }
        guard URL(string: value) != nil, value.hasPrefix("http://") || value.hasPrefix("https://") else {
            return "must be a valid URL"
        }
        return nil
    }

    /// Value must be a valid UUID.
    public static let uuid = PrismValidationRule(name: "uuid") { value in
        guard let value, !value.isEmpty else { return nil }
        guard UUID(uuidString: value) != nil else { return "must be a valid UUID" }
        return nil
    }
}

/// Validates multiple fields against rules and collects errors.
public struct PrismValidator: Sendable {
    private var fieldRules: [(String, [PrismValidationRule])]

    /// Creates a new `PrismValidator`.
    public init() {
        self.fieldRules = []
    }

    /// Adds validation rules for a field.
    public mutating func field(_ name: String, _ rules: PrismValidationRule...) {
        fieldRules.append((name, rules))
    }

    /// Validates a dictionary of field values. Returns errors keyed by field name.
    public func validate(_ data: [String: String]) -> PrismValidationResult {
        var errors: [String: [String]] = [:]
        for (field, rules) in fieldRules {
            let value = data[field]
            for rule in rules {
                if let error = rule.validate(value) {
                    errors[field, default: []].append(error)
                }
            }
        }
        return PrismValidationResult(errors: errors)
    }
}

/// Result of validation containing field-level errors.
public struct PrismValidationResult: Sendable {
    /// Errors keyed by field name. Empty if validation passed.
    public let errors: [String: [String]]

    /// Whether all validations passed.
    public var isValid: Bool { errors.isEmpty }

    /// Flat list of all error messages.
    public var allErrors: [String] {
        errors.flatMap { field, messages in
            messages.map { "\(field) \($0)" }
        }
    }

    /// Returns a 422 response with validation errors if invalid, nil if valid.
    public func errorResponse() -> PrismHTTPResponse? {
        guard !isValid else { return nil }
        return PrismHTTPResponse.json(
            ["errors": errors],
            status: .unprocessableEntity
        )
    }
}

extension PrismHTTPRequest {
    /// Validates the request's form data or query parameters against a validator.
    public func validate(_ configure: (inout PrismValidator) -> Void) -> PrismValidationResult {
        var validator = PrismValidator()
        configure(&validator)
        let data = body != nil ? formData : queryParameters
        return validator.validate(data)
    }

    /// Validates JSON body fields. Decodes to [String: String] for flat objects.
    public func validateJSON(_ configure: (inout PrismValidator) -> Void) -> PrismValidationResult {
        var validator = PrismValidator()
        configure(&validator)
        guard let body,
            let dict = try? JSONSerialization.jsonObject(with: body) as? [String: Any]
        else {
            return PrismValidationResult(errors: ["_body": ["invalid JSON"]])
        }
        let stringDict = dict.mapValues { "\($0)" }
        return validator.validate(stringDict)
    }
}
