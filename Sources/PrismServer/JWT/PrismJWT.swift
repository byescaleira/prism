#if canImport(CryptoKit)
import Foundation
import CryptoKit

public enum PrismJWTAlgorithm: String, Sendable, Codable {
    case hs256 = "HS256"
    case hs384 = "HS384"
    case hs512 = "HS512"
}

public struct PrismJWTHeader: Sendable, Codable {
    public let alg: String
    public let typ: String

    public init(algorithm: PrismJWTAlgorithm, typ: String = "JWT") {
        self.alg = algorithm.rawValue
        self.typ = typ
    }
}

public struct PrismJWTClaims: Sendable, Codable, Equatable {
    public var iss: String?
    public var sub: String?
    public var aud: String?
    public var exp: Double?
    public var nbf: Double?
    public var iat: Double?
    public var jti: String?
    public var customFields: [String: String]?

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

    public var expirationDate: Date? {
        exp.map { Date(timeIntervalSince1970: $0) }
    }

    public var notBeforeDate: Date? {
        nbf.map { Date(timeIntervalSince1970: $0) }
    }

    public var issuedAtDate: Date? {
        iat.map { Date(timeIntervalSince1970: $0) }
    }
}

public struct PrismJWTToken: Sendable {
    public let header: PrismJWTHeader
    public let claims: PrismJWTClaims
    public let signature: Data
    public let compact: String

    init(header: PrismJWTHeader, claims: PrismJWTClaims, signature: Data, compact: String) {
        self.header = header
        self.claims = claims
        self.signature = signature
        self.compact = compact
    }
}

public enum PrismJWTError: Error, Sendable, Equatable {
    case invalidToken
    case expired
    case notYetValid
    case invalidSignature
    case unsupportedAlgorithm
    case encodingFailed
}

public struct PrismJWTSigner: Sendable {
    private let key: SymmetricKey
    private let algorithm: PrismJWTAlgorithm

    public init(secret: String, algorithm: PrismJWTAlgorithm = .hs256) {
        self.key = SymmetricKey(data: Data(secret.utf8))
        self.algorithm = algorithm
    }

    public init(key: SymmetricKey, algorithm: PrismJWTAlgorithm = .hs256) {
        self.key = key
        self.algorithm = algorithm
    }

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

public struct PrismJWTMiddleware: PrismMiddleware {
    private let signer: PrismJWTSigner
    private let headerName: String
    private let scheme: String

    public init(
        signer: PrismJWTSigner,
        headerName: String = "Authorization",
        scheme: String = "Bearer"
    ) {
        self.signer = signer
        self.headerName = headerName
        self.scheme = scheme
    }

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
