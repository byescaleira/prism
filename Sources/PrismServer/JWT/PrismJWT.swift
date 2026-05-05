#if canImport(CryptoKit)
import Foundation
import CryptoKit

/// Supported JWT signing algorithms.
public enum PrismJWTAlgorithm: String, Sendable, Codable {
    case hs256 = "HS256"
    case hs384 = "HS384"
    case hs512 = "HS512"
}

/// The header portion of a JSON Web Token containing algorithm and type.
public struct PrismJWTHeader: Sendable, Codable {
    /// The alg.
    public let alg: String
    /// The typ.
    public let typ: String

    /// Creates a new `PrismJWTHeader` with the specified configuration.
    public init(algorithm: PrismJWTAlgorithm, typ: String = "JWT") {
        self.alg = algorithm.rawValue
        self.typ = typ
    }
}

/// Standard and custom claims payload of a JSON Web Token.
public struct PrismJWTClaims: Sendable, Codable, Equatable {
    /// The iss.
    public var iss: String?
    /// The sub.
    public var sub: String?
    /// The aud.
    public var aud: String?
    /// The exp.
    public var exp: Double?
    /// The nbf.
    public var nbf: Double?
    /// The iat.
    public var iat: Double?
    /// The jti.
    public var jti: String?
    /// The custom fields.
    public var customFields: [String: String]?

    /// Creates a new `PrismJWTClaims` with the specified configuration.
    public init(
        iss: String? = nil,
        sub: String? = nil,
        aud: String? = nil,
        exp: Date? = nil,
        nbf: Date? = nil,
        iat: Date? = .now,
        jti: String? = nil,
        customFields: [String: String]? = nil
    ) {
        self.iss = iss
        self.sub = sub
        self.aud = aud
        self.exp = exp?.timeIntervalSince1970
        self.nbf = nbf?.timeIntervalSince1970
        self.iat = iat?.timeIntervalSince1970
        self.jti = jti
        self.customFields = customFields
    }

    /// The expiration date.
    public var expirationDate: Date? {
        exp.map { Date(timeIntervalSince1970: $0) }
    }

    /// The not before date.
    public var notBeforeDate: Date? {
        nbf.map { Date(timeIntervalSince1970: $0) }
    }

    /// The issued at date.
    public var issuedAtDate: Date? {
        iat.map { Date(timeIntervalSince1970: $0) }
    }
}

/// A parsed JSON Web Token with header, claims, and signature.
public struct PrismJWTToken: Sendable {
    /// The header.
    public let header: PrismJWTHeader
    /// The claims.
    public let claims: PrismJWTClaims
    /// The signature.
    public let signature: Data
    /// The compact.
    public let compact: String

    init(header: PrismJWTHeader, claims: PrismJWTClaims, signature: Data, compact: String) {
        self.header = header
        self.claims = claims
        self.signature = signature
        self.compact = compact
    }
}

/// Errors related to JWT operations.
public enum PrismJWTError: Error, Sendable, Equatable {
    case invalidToken
    case expired
    case notYetValid
    case invalidSignature
    case unsupportedAlgorithm
    case encodingFailed
}

/// Signs and verifies JSON Web Tokens using HMAC-SHA256.
public struct PrismJWTSigner: Sendable {
    private let key: SymmetricKey
    private let algorithm: PrismJWTAlgorithm

    /// Creates a new `PrismJWTSigner` with the specified configuration.
    public init(secret: String, algorithm: PrismJWTAlgorithm = .hs256) {
        self.key = SymmetricKey(data: Data(secret.utf8))
        self.algorithm = algorithm
    }

    /// Creates a new `PrismJWTSigner` with the specified configuration.
    public init(key: SymmetricKey, algorithm: PrismJWTAlgorithm = .hs256) {
        self.key = key
        self.algorithm = algorithm
    }

    /// Signs the claims and returns a compact JWT string.
    public func sign(_ claims: PrismJWTClaims) throws -> String {
        let header = PrismJWTHeader(algorithm: algorithm)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        guard let headerData = try? encoder.encode(header),
              let claimsData = try? encoder.encode(claims) else {
            throw PrismJWTError.encodingFailed
        }

        let headerB64 = base64URLEncode(headerData)
        let claimsB64 = base64URLEncode(claimsData)
        let signingInput = "\(headerB64).\(claimsB64)"

        let signatureData = computeHMAC(Data(signingInput.utf8))
        let signatureB64 = base64URLEncode(signatureData)

        return "\(signingInput).\(signatureB64)"
    }

    /// Verifies the token signature and claims validity, returning the decoded claims.
    public func verify(_ token: String) throws -> PrismJWTClaims {
        let parts = token.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { throw PrismJWTError.invalidToken }

        let headerB64 = String(parts[0])
        let claimsB64 = String(parts[1])
        let signatureB64 = String(parts[2])

        guard let headerData = base64URLDecode(headerB64) else {
            throw PrismJWTError.invalidToken
        }

        let decoder = JSONDecoder()
        guard let header = try? decoder.decode(PrismJWTHeader.self, from: headerData) else {
            throw PrismJWTError.invalidToken
        }

        guard header.alg == algorithm.rawValue else {
            throw PrismJWTError.unsupportedAlgorithm
        }

        let signingInput = "\(headerB64).\(claimsB64)"
        let expectedSignature = computeHMAC(Data(signingInput.utf8))
        let expectedB64 = base64URLEncode(expectedSignature)

        guard constantTimeEqual(signatureB64, expectedB64) else {
            throw PrismJWTError.invalidSignature
        }

        guard let claimsData = base64URLDecode(claimsB64) else {
            throw PrismJWTError.invalidToken
        }

        guard let claims = try? decoder.decode(PrismJWTClaims.self, from: claimsData) else {
            throw PrismJWTError.invalidToken
        }

        let now = Date.now.timeIntervalSince1970

        if let exp = claims.exp, now > exp {
            throw PrismJWTError.expired
        }

        if let nbf = claims.nbf, now < nbf {
            throw PrismJWTError.notYetValid
        }

        return claims
    }

    /// Decodes a JWT token without verifying its signature.
    public func decode(_ token: String) throws -> PrismJWTToken {
        let parts = token.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { throw PrismJWTError.invalidToken }

        let decoder = JSONDecoder()

        guard let headerData = base64URLDecode(String(parts[0])),
              let header = try? decoder.decode(PrismJWTHeader.self, from: headerData) else {
            throw PrismJWTError.invalidToken
        }

        guard let claimsData = base64URLDecode(String(parts[1])),
              let claims = try? decoder.decode(PrismJWTClaims.self, from: claimsData) else {
            throw PrismJWTError.invalidToken
        }

        guard let signature = base64URLDecode(String(parts[2])) else {
            throw PrismJWTError.invalidToken
        }

        return PrismJWTToken(header: header, claims: claims, signature: signature, compact: token)
    }

    private func computeHMAC(_ data: Data) -> Data {
        switch algorithm {
        case .hs256:
            Data(HMAC<SHA256>.authenticationCode(for: data, using: key))
        case .hs384:
            Data(HMAC<SHA384>.authenticationCode(for: data, using: key))
        case .hs512:
            Data(HMAC<SHA512>.authenticationCode(for: data, using: key))
        }
    }

    private func constantTimeEqual(_ a: String, _ b: String) -> Bool {
        guard a.count == b.count else { return false }
        let aBytes = Array(a.utf8)
        let bBytes = Array(b.utf8)
        var result: UInt8 = 0
        for i in 0..<aBytes.count {
            result |= aBytes[i] ^ bBytes[i]
        }
        return result == 0
    }
}

/// Middleware that validates JWT bearer tokens on incoming requests.
public struct PrismJWTMiddleware: PrismMiddleware {
    private let signer: PrismJWTSigner
    private let headerName: String
    private let scheme: String

    /// Creates a new `PrismJWTMiddleware` with the specified configuration.
    public init(
        signer: PrismJWTSigner,
        headerName: String = "Authorization",
        scheme: String = "Bearer"
    ) {
        self.signer = signer
        self.headerName = headerName
        self.scheme = scheme
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        guard let authHeader = request.headers.value(for: headerName) else {
            return PrismHTTPResponse(status: .unauthorized, body: .text("Missing authorization header"))
        }

        let prefix = scheme + " "
        guard authHeader.hasPrefix(prefix) else {
            return PrismHTTPResponse(status: .unauthorized, body: .text("Invalid authorization scheme"))
        }

        let token = String(authHeader.dropFirst(prefix.count))

        let claims: PrismJWTClaims
        do {
            claims = try signer.verify(token)
        } catch {
            return PrismHTTPResponse(status: .unauthorized, body: .text("Invalid token"))
        }

        var req = request
        req.userInfo["jwt_token"] = token
        if let sub = claims.sub { req.userInfo["jwt_sub"] = sub }
        if let iss = claims.iss { req.userInfo["jwt_iss"] = iss }
        if let aud = claims.aud { req.userInfo["jwt_aud"] = aud }
        if let exp = claims.exp { req.userInfo["jwt_exp"] = String(Int(exp)) }
        if let jti = claims.jti { req.userInfo["jwt_jti"] = jti }
        if let custom = claims.customFields {
            for (key, value) in custom {
                req.userInfo["jwt_\(key)"] = value
            }
        }

        return try await next(req)
    }
}

// MARK: - Base64URL Utilities

func base64URLEncode(_ data: Data) -> String {
    data.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

func base64URLDecode(_ string: String) -> Data? {
    var base64 = string
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    let remainder = base64.count % 4
    if remainder > 0 {
        base64 += String(repeating: "=", count: 4 - remainder)
    }
    return Data(base64Encoded: base64)
}
#endif
