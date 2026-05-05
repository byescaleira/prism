import Foundation

/// Configuration for token management.
public struct PrismTokenConfiguration: Sendable {
    /// Keychain service for token storage.
    public let service: String
    /// Key for access token in secure store.
    public let accessTokenKey: String
    /// Key for refresh token in secure store.
    public let refreshTokenKey: String
    /// Seconds before expiry to trigger proactive refresh.
    public let refreshThreshold: TimeInterval
    /// Token refresh strategy.
    public let refreshStrategy: PrismTokenRefreshStrategy

    public static let `default` = PrismTokenConfiguration(
        service: "PrismTokenManager",
        accessTokenKey: "access_token",
        refreshTokenKey: "refresh_token",
        refreshThreshold: 300,
        refreshStrategy: .proactive
    )

    public init(
        service: String = "PrismTokenManager",
        accessTokenKey: String = "access_token",
        refreshTokenKey: String = "refresh_token",
        refreshThreshold: TimeInterval = 300,
        refreshStrategy: PrismTokenRefreshStrategy = .proactive
    ) {
        self.service = service
        self.accessTokenKey = accessTokenKey
        self.refreshTokenKey = refreshTokenKey
        self.refreshThreshold = refreshThreshold
        self.refreshStrategy = refreshStrategy
    }
}

/// Strategy for when to refresh tokens.
public enum PrismTokenRefreshStrategy: String, Sendable, Hashable, CaseIterable {
    /// Refresh before token expires (based on refreshThreshold).
    case proactive
    /// Refresh only when a request fails with 401.
    case reactive
    /// Manual refresh only.
    case manual
}
