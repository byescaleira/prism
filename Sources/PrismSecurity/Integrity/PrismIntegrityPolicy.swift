import Foundation

/// Action to take when an integrity violation is detected.
public enum PrismIntegrityAction: String, Sendable, Hashable, CaseIterable {
    /// Log the violation and continue.
    case log
    /// Wipe all secure storage data.
    case wipeSecureStore
    /// Log and notify via callback.
    case notify
}

/// Policy governing how integrity violations are handled.
public struct PrismIntegrityPolicy: Sendable {
    /// Actions to execute on violation.
    public let actions: [PrismIntegrityAction]
    /// Optional callback for violations.
    public let onViolation: (@Sendable (PrismIntegrityViolation) -> Void)?

    public static let `default` = PrismIntegrityPolicy(actions: [.log])

    public static let strict = PrismIntegrityPolicy(actions: [.log, .wipeSecureStore, .notify])

    public init(
        actions: [PrismIntegrityAction] = [.log],
        onViolation: (@Sendable (PrismIntegrityViolation) -> Void)? = nil
    ) {
        self.actions = actions
        self.onViolation = onViolation
    }
}

/// Describes an integrity violation.
public struct PrismIntegrityViolation: Sendable, Equatable {
    public let kind: PrismIntegrityViolationKind
    public let detail: String
    public let detectedAt: Date

    public init(kind: PrismIntegrityViolationKind, detail: String, detectedAt: Date = .now) {
        self.kind = kind
        self.detail = detail
        self.detectedAt = detectedAt
    }
}

/// Types of integrity violations.
public enum PrismIntegrityViolationKind: String, Sendable, Hashable, CaseIterable {
    case jailbreak
    case debuggerAttached
    case simulator
    case dataTampered
    case fileTampered
    case reverseEngineering
}
