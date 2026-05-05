#if canImport(CryptoKit)
    import Testing
    import Foundation
    @testable import PrismServer

    @Suite("PrismJWTSigner Tests")
    struct PrismJWTSignerTests {

        let signer = PrismJWTSigner(secret: "test-secret-key-at-least-32-bytes!", algorithm: .hs256)

        @Test("Sign and verify roundtrip")
        func signAndVerify() throws {
            let claims = PrismJWTClaims(
                iss: "prism",
                sub: "user123",
                exp: Date.now.addingTimeInterval(3600)
            )
            let token = try signer.sign(claims)
            let verified = try signer.verify(token)
            #expect(verified.iss == "prism")
            #expect(verified.sub == "user123")
        }

        @Test("Token has three dot-separated parts")
        func tokenFormat() throws {
            let claims = PrismJWTClaims(sub: "user")
            let token = try signer.sign(claims)
            let parts = token.split(separator: ".")
            #expect(parts.count == 3)
        }

        @Test("Expired token rejected")
        func expiredToken() throws {
            let claims = PrismJWTClaims(
                sub: "user",
                exp: Date.now.addingTimeInterval(-60)
            )
            let token = try signer.sign(claims)
            #expect(throws: PrismJWTError.expired) {
                _ = try signer.verify(token)
            }
        }

        @Test("Not-yet-valid token rejected")
        func notYetValid() throws {
            let claims = PrismJWTClaims(
                sub: "user",
                exp: Date.now.addingTimeInterval(7200),
                nbf: Date.now.addingTimeInterval(3600)
            )
            let token = try signer.sign(claims)
            #expect(throws: PrismJWTError.notYetValid) {
                _ = try signer.verify(token)
            }
        }

        @Test("Invalid signature rejected")
        func invalidSignature() throws {
            let claims = PrismJWTClaims(sub: "user", exp: Date.now.addingTimeInterval(3600))
            let token = try signer.sign(claims)

            let parts = token.split(separator: ".")
            let tampered = "\(parts[0]).\(parts[1]).invalidsignature"

            #expect(throws: PrismJWTError.invalidSignature) {
                _ = try signer.verify(tampered)
            }
        }

        @Test("Invalid token format rejected")
        func invalidFormat() {
            #expect(throws: PrismJWTError.invalidToken) {
                _ = try signer.verify("not.a.valid.jwt.token")
            }
            #expect(throws: PrismJWTError.invalidToken) {
                _ = try signer.verify("onlyonepart")
            }
        }

        @Test("Custom claims preserved")
        func customClaims() throws {
            let claims = PrismJWTClaims(
                sub: "user",
                exp: Date.now.addingTimeInterval(3600),
                customFields: ["role": "admin", "org": "acme"]
            )
            let token = try signer.sign(claims)
            let verified = try signer.verify(token)
            #expect(verified.customFields?["role"] == "admin")
            #expect(verified.customFields?["org"] == "acme")
        }

        @Test("Wrong secret key rejects token")
        func wrongKey() throws {
            let claims = PrismJWTClaims(sub: "user", exp: Date.now.addingTimeInterval(3600))
            let token = try signer.sign(claims)

            let otherSigner = PrismJWTSigner(secret: "different-secret-key-32-bytes!!!")
            #expect(throws: PrismJWTError.invalidSignature) {
                _ = try otherSigner.verify(token)
            }
        }

        @Test("Decode returns token structure without verification")
        func decodeToken() throws {
            let claims = PrismJWTClaims(iss: "prism", sub: "user42")
            let compact = try signer.sign(claims)
            let token = try signer.decode(compact)
            #expect(token.header.alg == "HS256")
            #expect(token.header.typ == "JWT")
            #expect(token.claims.sub == "user42")
            #expect(token.compact == compact)
        }
    }

    @Suite("PrismJWTAlgorithm Tests")
    struct PrismJWTAlgorithmTests {

        @Test("HS256 algorithm")
        func hs256() throws {
            let signer = PrismJWTSigner(secret: "secret-key-must-be-long-enough!!", algorithm: .hs256)
            let claims = PrismJWTClaims(sub: "user", exp: Date.now.addingTimeInterval(3600))
            let token = try signer.sign(claims)
            let verified = try signer.verify(token)
            #expect(verified.sub == "user")
        }

        @Test("HS384 algorithm")
        func hs384() throws {
            let signer = PrismJWTSigner(secret: "secret-key-must-be-long-enough!!", algorithm: .hs384)
            let claims = PrismJWTClaims(sub: "user", exp: Date.now.addingTimeInterval(3600))
            let token = try signer.sign(claims)
            let verified = try signer.verify(token)
            #expect(verified.sub == "user")
        }

        @Test("HS512 algorithm")
        func hs512() throws {
            let signer = PrismJWTSigner(secret: "secret-key-must-be-long-enough!!", algorithm: .hs512)
            let claims = PrismJWTClaims(sub: "user", exp: Date.now.addingTimeInterval(3600))
            let token = try signer.sign(claims)
            let verified = try signer.verify(token)
            #expect(verified.sub == "user")
        }

        @Test("Algorithm mismatch rejected")
        func algorithmMismatch() throws {
            let signer256 = PrismJWTSigner(secret: "shared-secret-long-enough-here!!", algorithm: .hs256)
            let signer512 = PrismJWTSigner(secret: "shared-secret-long-enough-here!!", algorithm: .hs512)
            let claims = PrismJWTClaims(sub: "user", exp: Date.now.addingTimeInterval(3600))
            let token = try signer256.sign(claims)
            #expect(throws: PrismJWTError.unsupportedAlgorithm) {
                _ = try signer512.verify(token)
            }
        }
    }

    @Suite("PrismJWTClaims Tests")
    struct PrismJWTClaimsTests {

        @Test("Date helpers return correct values")
        func dateHelpers() {
            let now = Date.now
            let claims = PrismJWTClaims(
                exp: now.addingTimeInterval(3600),
                nbf: now,
                iat: now
            )
            #expect(claims.expirationDate != nil)
            #expect(claims.notBeforeDate != nil)
            #expect(claims.issuedAtDate != nil)
        }

        @Test("Nil dates return nil helpers")
        func nilDates() {
            let claims = PrismJWTClaims(iat: nil)
            #expect(claims.expirationDate == nil)
            #expect(claims.notBeforeDate == nil)
            #expect(claims.issuedAtDate == nil)
        }

        @Test("All standard claims round-trip")
        func allStandardClaims() throws {
            let signer = PrismJWTSigner(secret: "secret-key-must-be-long-enough!!")
            let claims = PrismJWTClaims(
                iss: "issuer",
                sub: "subject",
                aud: "audience",
                exp: Date.now.addingTimeInterval(3600),
                nbf: Date.now.addingTimeInterval(-60),
                iat: .now,
                jti: "unique-id-123"
            )
            let token = try signer.sign(claims)
            let verified = try signer.verify(token)
            #expect(verified.iss == "issuer")
            #expect(verified.sub == "subject")
            #expect(verified.aud == "audience")
            #expect(verified.jti == "unique-id-123")
            #expect(verified.exp != nil)
            #expect(verified.nbf != nil)
            #expect(verified.iat != nil)
        }
    }

    @Suite("PrismJWTMiddleware Tests")
    struct PrismJWTMiddlewareTests {

        let signer = PrismJWTSigner(secret: "middleware-test-secret-32-bytes!", algorithm: .hs256)

        @Test("Middleware extracts claims to userInfo")
        func extractsClaims() async throws {
            let middleware = PrismJWTMiddleware(signer: signer)
            let claims = PrismJWTClaims(
                iss: "prism",
                sub: "user42",
                aud: "api",
                exp: Date.now.addingTimeInterval(3600),
                jti: "req-1",
                customFields: ["role": "admin"]
            )
            let token = try signer.sign(claims)

            var request = PrismHTTPRequest(method: .GET, uri: "/protected")
            request.headers.set(name: "Authorization", value: "Bearer \(token)")

            let response = try await middleware.handle(request) { req in
                #expect(req.userInfo["jwt_sub"] == "user42")
                #expect(req.userInfo["jwt_iss"] == "prism")
                #expect(req.userInfo["jwt_aud"] == "api")
                #expect(req.userInfo["jwt_jti"] == "req-1")
                #expect(req.userInfo["jwt_role"] == "admin")
                #expect(req.userInfo["jwt_token"] != nil)
                return .text("ok")
            }
            #expect(response.status == .ok)
        }

        @Test("Middleware rejects missing Authorization header")
        func missingHeader() async throws {
            let middleware = PrismJWTMiddleware(signer: signer)
            let request = PrismHTTPRequest(method: .GET, uri: "/protected")

            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.status == .unauthorized)
        }

        @Test("Middleware rejects non-Bearer scheme")
        func wrongScheme() async throws {
            let middleware = PrismJWTMiddleware(signer: signer)
            var request = PrismHTTPRequest(method: .GET, uri: "/protected")
            request.headers.set(name: "Authorization", value: "Basic dXNlcjpwYXNz")

            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.status == .unauthorized)
        }

        @Test("Middleware rejects expired token")
        func expiredToken() async throws {
            let middleware = PrismJWTMiddleware(signer: signer)
            let claims = PrismJWTClaims(sub: "user", exp: Date.now.addingTimeInterval(-60))
            let token = try signer.sign(claims)

            var request = PrismHTTPRequest(method: .GET, uri: "/protected")
            request.headers.set(name: "Authorization", value: "Bearer \(token)")

            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.status == .unauthorized)
        }

        @Test("Middleware rejects tampered token")
        func tamperedToken() async throws {
            let middleware = PrismJWTMiddleware(signer: signer)

            var request = PrismHTTPRequest(method: .GET, uri: "/protected")
            request.headers.set(name: "Authorization", value: "Bearer aaa.bbb.ccc")

            let response = try await middleware.handle(request) { _ in .text("ok") }
            #expect(response.status == .unauthorized)
        }
    }

    @Suite("Base64URL Tests")
    struct Base64URLTests {

        @Test("Encode and decode roundtrip")
        func roundtrip() {
            let original = Data("Hello, JWT World! Special chars: +/=".utf8)
            let encoded = base64URLEncode(original)
            let decoded = base64URLDecode(encoded)
            #expect(decoded == original)
        }

        @Test("No padding characters in output")
        func noPadding() {
            let data = Data("ab".utf8)
            let encoded = base64URLEncode(data)
            #expect(!encoded.contains("="))
        }

        @Test("No plus or slash in output")
        func noStandardBase64Chars() {
            let data = Data([0xFF, 0xFE, 0xFD, 0xFC, 0xFB, 0xFA])
            let encoded = base64URLEncode(data)
            #expect(!encoded.contains("+"))
            #expect(!encoded.contains("/"))
        }
    }
#endif
