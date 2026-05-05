import Foundation

/// Unified privacy guard combining redaction, screen protection, and clipboard management.
///
/// ```swift
/// let privacy = PrismPrivacyGuard()
///
/// // Redact PII
/// let safe = privacy.redact("Email: john@example.com")
///
/// // Classify field sensitivity
/// let level = privacy.classify("email")  // .sensitive
///
/// // Secure clipboard
/// privacy.copySecurely("secret-token")
/// ```
public struct PrismPrivacyGuard: Sendable {
    private let redactor: PrismRedactor
    private let clipboardGuard: PrismClipboardGuard
    private let fieldClassifications: [String: PrismPrivacyLevel]

    /// Creates a privacy guard with default configurations.
    public init(
        redactionStyle: PrismRedactor.Style = .mask,
        clipboardTimeout: TimeInterval = 30,
        fieldClassifications: [String: PrismPrivacyLevel] = Self.defaultClassifications
    ) {
        self.redactor = PrismRedactor(style: redactionStyle)
        self.clipboardGuard = PrismClipboardGuard(clearAfter: clipboardTimeout)
        self.fieldClassifications = fieldClassifications
    }

    /// Redacts PII from a string.
    public func redact(_ string: String) -> String {
        redactor.redact(string)
    }

    /// Redacts a specific value.
    public func redactValue(_ value: String, type: PrismPIIType) -> String {
        redactor.redactValue(value, type: type)
    }

    /// Classifies a field name by privacy level.
    public func classify(_ fieldName: String) -> PrismPrivacyLevel {
        let lower = fieldName.lowercased()
        if let level = fieldClassifications[lower] { return level }

        let restrictedPatterns = ["password", "secret", "private_key", "ssn", "social_security"]
        if restrictedPatterns.contains(where: { lower.contains($0) }) { return .restricted }

        let sensitivePatterns = ["email", "phone", "address", "birth", "credit_card", "token", "api_key"]
        if sensitivePatterns.contains(where: { lower.contains($0) }) { return .sensitive }

        let internalPatterns = ["user_id", "account", "ip", "device_id"]
        if internalPatterns.contains(where: { lower.contains($0) }) { return .internal }

        return .public
    }

    /// Copies to clipboard with auto-clear.
    public func copySecurely(_ string: String) {
        clipboardGuard.copySecurely(string)
    }

    /// Clears clipboard immediately.
    public func clearClipboard() {
        clipboardGuard.clearNow()
    }

    /// Applies redaction to a value based on its field classification.
    public func protect(field: String, value: String) -> String {
        let level = classify(field)
        switch level {
        case .public:
            return value
        case .internal:
            return value
        case .sensitive:
            return redactor.redact(value)
        case .restricted:
            return "[RESTRICTED]"
        }
    }

    /// Default field name → privacy level mappings.
    public static let defaultClassifications: [String: PrismPrivacyLevel] = [
        "password": .restricted,
        "secret": .restricted,
        "private_key": .restricted,
        "ssn": .restricted,
        "email": .sensitive,
        "phone": .sensitive,
        "address": .sensitive,
        "credit_card": .sensitive,
        "date_of_birth": .sensitive,
        "user_id": .internal,
        "ip_address": .internal,
        "device_id": .internal,
        "name": .public,
        "username": .public,
    ]
}
