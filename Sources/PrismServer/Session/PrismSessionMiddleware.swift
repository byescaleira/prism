import Foundation

#if canImport(CryptoKit)
    import CryptoKit
#endif

/// Middleware that manages server-side sessions with signed cookies.
public struct PrismSessionMiddleware: PrismMiddleware {
    private let store: any PrismSessionStore
    private let cookieName: String
    private let ttl: TimeInterval
    private let secret: String

    /// Creates a new `PrismSessionMiddleware` with the specified configuration.
    public init(
        store: any PrismSessionStore = PrismMemorySessionStore(),
        cookieName: String = "prism_session",
        ttl: TimeInterval = 3600,
        secret: String = UUID().uuidString
    ) {
        self.store = store
        self.cookieName = cookieName
        self.ttl = ttl
        self.secret = secret
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        let sessionID: String
        var isNew = false

        if let cookieValue = request.cookies[cookieName], verifySignature(cookieValue) {
            sessionID = extractID(from: cookieValue)
        } else {
            sessionID = UUID().uuidString
            isNew = true
        }

        var session = await store.load(id: sessionID) ?? PrismSession(id: sessionID, ttl: ttl)

        var req = request
        req.userInfo["sessionID"] = session.id

        var response = try await next(req)

        session.expiresAt = Date.now.addingTimeInterval(ttl)
        await store.save(session)

        if isNew {
            let signedValue = sign(sessionID)
            let cookie = PrismCookie(
                name: cookieName,
                value: signedValue,
                maxAge: Int(ttl),
                secure: true,
                httpOnly: true,
                sameSite: .lax
            )
            response.setCookie(cookie)
        }

        return response
    }

    #if canImport(CryptoKit)
        private func sign(_ id: String) -> String {
            let key = SymmetricKey(data: Data(secret.utf8))
            let mac = HMAC<SHA256>.authenticationCode(for: Data(id.utf8), using: key)
            let signature = Data(mac).base64EncodedString()
            return "\(id).\(signature)"
        }

        private func verifySignature(_ value: String) -> Bool {
            let parts = value.split(separator: ".", maxSplits: 1)
            guard parts.count == 2 else { return false }
            let id = String(parts[0])
            let expected = sign(id)
            return value == expected
        }
    #else
        private func sign(_ id: String) -> String { id }
        private func verifySignature(_ value: String) -> Bool { true }
    #endif

    private func extractID(from value: String) -> String {
        String(value.split(separator: ".", maxSplits: 1).first ?? "")
    }
}
