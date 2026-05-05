import Foundation

/// Decoded JWT access token with claim inspection (no signature verification — client-side only).
public struct PrismAccessToken: Sendable, Equatable {
    /// Raw JWT string.
    public let rawToken: String
    /// Decoded header.
    public let header: [String: String]
    /// Raw payload JSON data.
    public let payloadData: Data
    /// Token expiration date (from `exp` claim).
    public let expiresAt: Date?
    /// Token issued-at date (from `iat` claim).
    public let issuedAt: Date?
    /// Subject claim.
    public let subject: String?
    /// Issuer claim.
    public let issuer: String?

    /// Whether the token has expired.
    public var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date.now >= expiresAt
    }

    /// Whether the token will expire within the given interval.
    public func expiresWithin(_ interval: TimeInterval) -> Bool {
        guard let expiresAt else { return false }
        return Date.now.addingTimeInterval(interval) >= expiresAt
    }

    /// Time remaining until expiration.
    public var timeUntilExpiry: TimeInterval? {
        guard let expiresAt else { return nil }
        return expiresAt.timeIntervalSinceNow
    }

    /// Decodes a JWT string into an access token (no signature verification).
    public static func decode(_ jwt: String) throws -> PrismAccessToken {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw PrismSecurityError.invalidData
        }

        let headerJSON = try decodeBase64URL(parts[0])
        let payloadJSON = try decodeBase64URL(parts[1])

        let headerDict = (try? JSONSerialization.jsonObject(with: headerJSON)) as? [String: String] ?? [:]
        let payloadDict = (try? JSONSerialization.jsonObject(with: payloadJSON)) as? [String: Any] ?? [:]

        let exp: Date? = (payloadDict["exp"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
            ?? (payloadDict["exp"] as? Int).map { Date(timeIntervalSince1970: TimeInterval($0)) }
        let iat: Date? = (payloadDict["iat"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
            ?? (payloadDict["iat"] as? Int).map { Date(timeIntervalSince1970: TimeInterval($0)) }
        let sub = payloadDict["sub"] as? String
        let iss = payloadDict["iss"] as? String

        return PrismAccessToken(
            rawToken: jwt,
            header: headerDict,
            payloadData: payloadJSON,
            expiresAt: exp,
            issuedAt: iat,
            subject: sub,
            issuer: iss
        )
    }

    /// Gets a typed claim value by key from the payload.
    public func claim<T>(_ key: String) -> T? {
        guard let dict = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
            return nil
        }
        return dict[key] as? T
    }

    /// All payload claims as a dictionary.
    public var claims: [String: Any] {
        (try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any]) ?? [:]
    }

    private static func decodeBase64URL(_ string: String) throws -> Data {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64.append(String(repeating: "=", count: 4 - remainder))
        }
        guard let data = Data(base64Encoded: base64) else {
            throw PrismSecurityError.invalidData
        }
        return data
    }

    public static func == (lhs: PrismAccessToken, rhs: PrismAccessToken) -> Bool {
        lhs.rawToken == rhs.rawToken
    }
}
