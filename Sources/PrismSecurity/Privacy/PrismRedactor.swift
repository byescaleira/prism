import Foundation

/// Automatically detects and redacts PII from strings.
///
/// ```swift
/// let redactor = PrismRedactor()
/// redactor.redact("Contact john@example.com or 555-123-4567")
/// // "Contact j***@***.com or ***-***-4567"
/// ```
public struct PrismRedactor: Sendable {
    /// Redaction style.
    public enum Style: String, Sendable, Hashable {
        case mask
        case remove
        case hash
    }

    private let style: Style

    public init(style: Style = .mask) {
        self.style = style
    }

    /// Redacts all detected PII patterns in a string.
    public func redact(_ string: String) -> String {
        var result = string
        result = redactEmails(in: result)
        result = redactPhoneNumbers(in: result)
        result = redactCreditCards(in: result)
        result = redactSSNs(in: result)
        result = redactIPAddresses(in: result)
        return result
    }

    /// Redacts a specific value based on its type.
    public func redactValue(_ value: String, type: PrismPIIType) -> String {
        switch style {
        case .mask:
            return maskValue(value, type: type)
        case .remove:
            return "[REDACTED]"
        case .hash:
            let hasher = PrismHasher()
            return hasher.hashHex(value).prefix(8) + "..."
        }
    }

    // MARK: - Pattern Redaction

    private func redactEmails(in string: String) -> String {
        let pattern = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return redactPattern(pattern, in: string, type: .email)
    }

    private func redactPhoneNumbers(in string: String) -> String {
        let pattern = "\\b\\d{3}[-.]?\\d{3}[-.]?\\d{4}\\b"
        return redactPattern(pattern, in: string, type: .phone)
    }

    private func redactCreditCards(in string: String) -> String {
        let pattern = "\\b\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}\\b"
        return redactPattern(pattern, in: string, type: .creditCard)
    }

    private func redactSSNs(in string: String) -> String {
        let pattern = "\\b\\d{3}-\\d{2}-\\d{4}\\b"
        return redactPattern(pattern, in: string, type: .ssn)
    }

    private func redactIPAddresses(in string: String) -> String {
        let pattern = "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b"
        return redactPattern(pattern, in: string, type: .ipAddress)
    }

    private func redactPattern(_ pattern: String, in string: String, type: PrismPIIType) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return string }
        let range = NSRange(string.startIndex..., in: string)
        var result = string

        let matches = regex.matches(in: string, range: range).reversed()
        for match in matches {
            guard let swiftRange = Range(match.range, in: result) else { continue }
            let matched = String(result[swiftRange])
            result.replaceSubrange(swiftRange, with: redactValue(matched, type: type))
        }

        return result
    }

    private func maskValue(_ value: String, type: PrismPIIType) -> String {
        switch type {
        case .email:
            let parts = value.split(separator: "@", maxSplits: 1)
            guard parts.count == 2 else { return "***@***.***" }
            let local = parts[0]
            return "\(local.prefix(1))***@***.***"

        case .phone:
            let digits = value.filter(\.isNumber)
            guard digits.count >= 4 else { return "***" }
            return "***-***-\(digits.suffix(4))"

        case .creditCard:
            let digits = value.filter(\.isNumber)
            guard digits.count >= 4 else { return "****" }
            return "****-****-****-\(digits.suffix(4))"

        case .ssn:
            return "***-**-" + value.suffix(4)

        case .ipAddress:
            let parts = value.split(separator: ".")
            guard parts.count == 4 else { return "***.***.***.***" }
            return "***.***.***.***"

        case .custom:
            return String(repeating: "*", count: value.count)
        }
    }
}

/// Types of personally identifiable information.
public enum PrismPIIType: String, Sendable, Hashable, CaseIterable {
    case email
    case phone
    case creditCard
    case ssn
    case ipAddress
    case custom
}
