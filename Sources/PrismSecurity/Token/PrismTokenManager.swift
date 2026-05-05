import Foundation

/// Manages OAuth2/JWT token lifecycle — storage, refresh, validation.
///
/// ```swift
/// let manager = PrismTokenManager { refreshToken in
///     let response = try await api.refreshToken(refreshToken)
///     return PrismTokenPair(accessToken: response.access, refreshToken: response.refresh)
/// }
///
/// try await manager.store(accessToken: jwt, refreshToken: refreshJWT)
///
/// let token = try await manager.validAccessToken()  // auto-refreshes if needed
/// ```
public actor PrismTokenManager {
    private let secureStore: PrismSecureStore
    private let configuration: PrismTokenConfiguration
    private let refreshHandler: (@Sendable (String) async throws -> PrismTokenPair)?
    private var isRefreshing = false
    private var refreshWaiters: [CheckedContinuation<String, Error>] = []

    /// Creates a token manager.
    /// - Parameters:
    ///   - configuration: Token configuration.
    ///   - refreshHandler: Async closure that exchanges a refresh token for a new token pair.
    public init(
        configuration: PrismTokenConfiguration = .default,
        refreshHandler: (@Sendable (String) async throws -> PrismTokenPair)? = nil
    ) {
        self.secureStore = PrismSecureStore(
            configuration: PrismSecureStoreConfiguration(
                service: configuration.service
            )
        )
        self.configuration = configuration
        self.refreshHandler = refreshHandler
    }

    // MARK: - Storage

    /// Stores a token pair securely.
    public func store(accessToken: String, refreshToken: String? = nil) throws {
        try secureStore.save(accessToken, forKey: configuration.accessTokenKey)
        if let refreshToken {
            try secureStore.save(refreshToken, forKey: configuration.refreshTokenKey)
        }
    }

    /// Stores a decoded token pair.
    public func store(_ pair: PrismTokenPair) throws {
        try store(accessToken: pair.accessToken, refreshToken: pair.refreshToken)
    }

    // MARK: - Retrieval

    /// Returns the current access token string (no validation).
    public func currentAccessToken() throws -> String {
        try secureStore.loadString(forKey: configuration.accessTokenKey)
    }

    /// Returns a decoded access token (no validation).
    public func currentDecodedToken() throws -> PrismAccessToken {
        let raw = try currentAccessToken()
        return try PrismAccessToken.decode(raw)
    }

    /// Returns the refresh token.
    public func currentRefreshToken() throws -> String {
        try secureStore.loadString(forKey: configuration.refreshTokenKey)
    }

    // MARK: - Validated Access

    /// Returns a valid access token, refreshing if necessary.
    /// Handles concurrent callers — only one refresh at a time.
    public func validAccessToken() async throws -> String {
        let raw = try currentAccessToken()
        let token = try PrismAccessToken.decode(raw)

        switch configuration.refreshStrategy {
        case .proactive:
            if token.expiresWithin(configuration.refreshThreshold) {
                return try await performRefresh()
            }
            return raw

        case .reactive:
            if token.isExpired {
                return try await performRefresh()
            }
            return raw

        case .manual:
            return raw
        }
    }

    /// Manually triggers a token refresh.
    public func refresh() async throws -> PrismTokenPair {
        let newToken = try await performRefresh()
        let refreshToken = try? currentRefreshToken()
        return PrismTokenPair(accessToken: newToken, refreshToken: refreshToken)
    }

    // MARK: - Lifecycle

    /// Clears all stored tokens (logout).
    public func clearTokens() throws {
        try secureStore.delete(forKey: configuration.accessTokenKey)
        try secureStore.delete(forKey: configuration.refreshTokenKey)
    }

    /// Whether tokens are currently stored.
    public var hasTokens: Bool {
        secureStore.exists(forKey: configuration.accessTokenKey)
    }

    // MARK: - Private

    private func performRefresh() async throws -> String {
        if isRefreshing {
            return try await withCheckedThrowingContinuation { continuation in
                refreshWaiters.append(continuation)
            }
        }

        isRefreshing = true
        defer {
            isRefreshing = false
        }

        do {
            guard let refreshHandler else {
                throw PrismSecurityError.invalidKey
            }
            let refreshToken = try currentRefreshToken()
            let pair = try await refreshHandler(refreshToken)
            try store(pair)

            for waiter in refreshWaiters {
                waiter.resume(returning: pair.accessToken)
            }
            refreshWaiters.removeAll()

            return pair.accessToken
        } catch {
            for waiter in refreshWaiters {
                waiter.resume(throwing: error)
            }
            refreshWaiters.removeAll()
            throw error
        }
    }
}

/// A pair of access and refresh tokens.
public struct PrismTokenPair: Sendable, Equatable {
    public let accessToken: String
    public let refreshToken: String?

    public init(accessToken: String, refreshToken: String? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
