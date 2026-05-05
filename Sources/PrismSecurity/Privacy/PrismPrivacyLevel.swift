import Foundation

/// Classification levels for data sensitivity.
public enum PrismPrivacyLevel: String, Sendable, Hashable, CaseIterable, Comparable {
    /// Publicly visible data.
    case `public`
    /// Internal — visible in logs, not in UI.
    case `internal`
    /// Sensitive — redacted in logs and UI.
    case sensitive
    /// Restricted — never exposed, always encrypted.
    case restricted

    public static func < (lhs: PrismPrivacyLevel, rhs: PrismPrivacyLevel) -> Bool {
        let order: [PrismPrivacyLevel] = [.public, .internal, .sensitive, .restricted]
        let lhsIndex = order.firstIndex(of: lhs) ?? 0
        let rhsIndex = order.firstIndex(of: rhs) ?? 0
        return lhsIndex < rhsIndex
    }
}
