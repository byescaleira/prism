import Foundation

/// An HTTP cookie with security attributes.
public struct PrismCookie: Sendable, Equatable {
    public let name: String
    public let value: String
    public var path: String
    public var domain: String?
    public var maxAge: Int?
    public var secure: Bool
    public var httpOnly: Bool
    public var sameSite: SameSite

    public enum SameSite: String, Sendable {
        case strict = "Strict"
        case lax = "Lax"
        case none = "None"
    }

    public init(
        name: String,
        value: String,
        path: String = "/",
        domain: String? = nil,
        maxAge: Int? = nil,
        secure: Bool = true,
        httpOnly: Bool = true,
        sameSite: SameSite = .lax
    ) {
        self.name = name
        self.value = value
        self.path = path
        self.domain = domain
        self.maxAge = maxAge
        self.secure = secure
        self.httpOnly = httpOnly
        self.sameSite = sameSite
    }

    /// Serializes to Set-Cookie header value.
    public var headerValue: String {
        var parts = ["\(name)=\(value)"]
        parts.append("Path=\(path)")
        if let domain { parts.append("Domain=\(domain)") }
        if let maxAge { parts.append("Max-Age=\(maxAge)") }
        if secure { parts.append("Secure") }
        if httpOnly { parts.append("HttpOnly") }
        parts.append("SameSite=\(sameSite.rawValue)")
        return parts.joined(separator: "; ")
    }
}

extension PrismHTTPRequest {
    /// Parses cookies from the Cookie header.
    public var cookies: [String: String] {
        guard let header = headers.value(for: PrismHTTPHeaders.cookie) else { return [:] }
        var result: [String: String] = [:]
        for pair in header.split(separator: ";") {
            let trimmed = pair.trimmingCharacters(in: .whitespaces)
            let kv = trimmed.split(separator: "=", maxSplits: 1)
            if kv.count == 2 {
                result[String(kv[0])] = String(kv[1])
            }
        }
        return result
    }
}

extension PrismHTTPResponse {
    /// Adds a Set-Cookie header.
    public mutating func setCookie(_ cookie: PrismCookie) {
        headers.add(name: PrismHTTPHeaders.setCookie, value: cookie.headerValue)
    }
}
