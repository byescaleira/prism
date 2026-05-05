import Foundation

/// Types of security events tracked in the audit log.
public enum PrismSecurityEventKind: String, Codable, Sendable, Hashable, CaseIterable {
    case biometricSuccess
    case biometricFailure
    case keychainRead
    case keychainWrite
    case keychainDelete
    case encryptionPerformed
    case decryptionPerformed
    case permissionRequested
    case permissionGranted
    case permissionDenied
    case integrityViolation
    case pinningViolation
    case tokenRefreshed
    case tokenExpired
    case secureStoreAccess
    case channelEstablished
    case envelopeSealed
    case envelopeOpened
    case dataSealed
    case dataSealVerified
    case dataSealFailed
    case privacyRedaction
    case screenshotBlocked
    case clipboardCleared
}

/// A single security event for the audit log.
public struct PrismSecurityEvent: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let kind: PrismSecurityEventKind
    public let detail: String
    public let metadata: [String: String]
    public let timestamp: Date

    public init(
        kind: PrismSecurityEventKind,
        detail: String,
        metadata: [String: String] = [:],
        timestamp: Date = .now
    ) {
        self.id = UUID().uuidString
        self.kind = kind
        self.detail = detail
        self.metadata = metadata
        self.timestamp = timestamp
    }
}
