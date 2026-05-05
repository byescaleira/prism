import Foundation
import Testing

@testable import PrismSecurity

@Suite("AccToken")
struct PrismAccessTokenTests {
    static func makeJWT(
        sub: String = "user123",
        iss: String = "prism",
        exp: Int = Int(Date.now.addingTimeInterval(3600).timeIntervalSince1970),
        iat: Int = Int(Date.now.timeIntervalSince1970)
    ) -> String {
        let header = #"{"alg":"HS256","typ":"JWT"}"#
        let payload = #"{"sub":"\#(sub)","iss":"\#(iss)","exp":\#(exp),"iat":\#(iat)}"#

        func base64URL(_ string: String) -> String {
            Data(string.utf8).base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
        }

        return "\(base64URL(header)).\(base64URL(payload)).fakesignature"
    }

    @Test("Decode valid JWT")
    func decode() throws {
        let jwt = Self.makeJWT()
        let token = try PrismAccessToken.decode(jwt)
        #expect(token.subject == "user123")
        #expect(token.issuer == "prism")
        #expect(token.rawToken == jwt)
    }

    @Test("Token not expired when future exp")
    func notExpired() throws {
        let jwt = Self.makeJWT(exp: Int(Date.now.addingTimeInterval(3600).timeIntervalSince1970))
        let token = try PrismAccessToken.decode(jwt)
        #expect(!token.isExpired)
    }

    @Test("Token expired when past exp")
    func expired() throws {
        let jwt = Self.makeJWT(exp: Int(Date.now.addingTimeInterval(-100).timeIntervalSince1970))
        let token = try PrismAccessToken.decode(jwt)
        #expect(token.isExpired)
    }

    @Test("ExpiresWithin detects soon-to-expire")
    func expiresWithin() throws {
        let jwt = Self.makeJWT(exp: Int(Date.now.addingTimeInterval(60).timeIntervalSince1970))
        let token = try PrismAccessToken.decode(jwt)
        #expect(token.expiresWithin(120))
        #expect(!token.expiresWithin(30))
    }

    @Test("Invalid JWT throws")
    func invalidJWT() {
        #expect(throws: PrismSecurityError.invalidData) {
            try PrismAccessToken.decode("not.a.valid.jwt.string")
        }
    }

    @Test("Two-part JWT throws")
    func twoPart() {
        #expect(throws: PrismSecurityError.invalidData) {
            try PrismAccessToken.decode("only.two")
        }
    }

    @Test("Claim extraction")
    func claims() throws {
        let jwt = Self.makeJWT(sub: "test-user")
        let token = try PrismAccessToken.decode(jwt)
        let sub: String? = token.claim("sub")
        #expect(sub == "test-user")
    }

    @Test("Token equality by raw string")
    func equality() throws {
        let jwt = Self.makeJWT()
        let t1 = try PrismAccessToken.decode(jwt)
        let t2 = try PrismAccessToken.decode(jwt)
        #expect(t1 == t2)
    }
}

@Suite("TokConfig")
struct PrismTokenConfigurationTests {
    @Test("Default configuration")
    func defaults() {
        let config = PrismTokenConfiguration.default
        #expect(config.service == "PrismTokenManager")
        #expect(config.refreshThreshold == 300)
        #expect(config.refreshStrategy == .proactive)
    }

    @Test("All strategies available")
    func strategies() {
        #expect(PrismTokenRefreshStrategy.allCases.count == 3)
    }

    @Test("Custom configuration")
    func custom() {
        let config = PrismTokenConfiguration(
            service: "CustomAuth",
            refreshThreshold: 60,
            refreshStrategy: .reactive
        )
        #expect(config.service == "CustomAuth")
        #expect(config.refreshThreshold == 60)
        #expect(config.refreshStrategy == .reactive)
    }
}

@Suite("TokPair")
struct PrismTokenPairTests {
    @Test("Token pair equality")
    func equality() {
        let p1 = PrismTokenPair(accessToken: "a", refreshToken: "r")
        let p2 = PrismTokenPair(accessToken: "a", refreshToken: "r")
        #expect(p1 == p2)
    }

    @Test("Token pair without refresh")
    func noRefresh() {
        let pair = PrismTokenPair(accessToken: "token")
        #expect(pair.refreshToken == nil)
    }
}
