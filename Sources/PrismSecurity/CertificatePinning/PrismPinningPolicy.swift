import Foundation

/// Policy for how certificate pinning violations are handled.
public enum PrismPinningPolicy: String, Sendable, Hashable, CaseIterable {
    /// Block connection on pin mismatch (production).
    case strict
    /// Log violation but allow connection (staging/testing).
    case reportOnly
    /// Trust on first use — pin the first cert seen, verify subsequently.
    case trustFirstUse
}

/// Result of a pinning validation check.
public struct PrismPinningResult: Sendable, Equatable {
    public let host: String
    public let isValid: Bool
    public let matchedHash: String?
    public let serverHash: String
    public let evaluatedAt: Date

    public init(
        host: String,
        isValid: Bool,
        matchedHash: String? = nil,
        serverHash: String,
        evaluatedAt: Date = .now
    ) {
        self.host = host
        self.isValid = isValid
        self.matchedHash = matchedHash
        self.serverHash = serverHash
        self.evaluatedAt = evaluatedAt
    }
}
