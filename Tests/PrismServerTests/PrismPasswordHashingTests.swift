#if canImport(CommonCrypto)
import Testing
import Foundation
@testable import PrismServer

@Suite("PrismPBKDF2Hasher Tests")
struct PrismPBKDF2HasherTests {

    @Test("Hash produces non-empty string")
    func hashProducesNonEmpty() throws {
        let hasher = PrismPBKDF2Hasher()
        let result = try hasher.hash("password123")
        #expect(!result.isEmpty)
    }

    @Test("Hash format starts with algorithm prefix")
    func hashFormatPrefix() throws {
        let hasher = PrismPBKDF2Hasher()
        let result = try hasher.hash("password123")
        #expect(result.hasPrefix("$pbkdf2-sha256$"))
    }

    @Test("Hash format has four dollar-delimited parts")
    func hashFormatParts() throws {
        let hasher = PrismPBKDF2Hasher()
        let result = try hasher.hash("password123")
        let parts = result.split(separator: "$", omittingEmptySubsequences: true)
        #expect(parts.count == 4)
    }

    @Test("Verify returns true for correct password")
    func verifyCorrectPassword() throws {
        let hasher = PrismPBKDF2Hasher()
        let hash = try hasher.hash("mySecret!")
        let valid = try hasher.verify("mySecret!", against: hash)
        #expect(valid)
    }

    @Test("Verify returns false for wrong password")
    func verifyWrongPassword() throws {
        let hasher = PrismPBKDF2Hasher()
        let hash = try hasher.hash("mySecret!")
        let valid = try hasher.verify("wrongPassword", against: hash)
        #expect(!valid)
    }

    @Test("Different passwords produce different hashes")
    func differentPasswordsDifferentHashes() throws {
        let hasher = PrismPBKDF2Hasher()
        let h1 = try hasher.hash("password1")
        let h2 = try hasher.hash("password2")
        #expect(h1 != h2)
    }

    @Test("Same password hashed twice produces different hashes due to salt")
    func samePasswordDifferentSalts() throws {
        let hasher = PrismPBKDF2Hasher()
        let h1 = try hasher.hash("samePassword")
        let h2 = try hasher.hash("samePassword")
        #expect(h1 != h2)
    }

    @Test("Custom iterations work and verify correctly")
    func customIterations() throws {
        let hasher = PrismPBKDF2Hasher(iterations: 1_000)
        let hash = try hasher.hash("quick")
        let valid = try hasher.verify("quick", against: hash)
        #expect(valid)
        #expect(hash.contains("$1000$"))
    }

    @Test("SHA512 algorithm variant works")
    func sha512Variant() throws {
        let hasher = PrismPBKDF2Hasher(algorithm: .sha512, iterations: 1_000)
        let hash = try hasher.hash("sha512test")
        #expect(hash.hasPrefix("$pbkdf2-sha512$"))
        let valid = try hasher.verify("sha512test", against: hash)
        #expect(valid)
    }

    @Test("Invalid format string throws invalidFormat")
    func invalidFormatThrows() throws {
        let hasher = PrismPBKDF2Hasher()
        #expect(throws: PrismPasswordHashingError.self) {
            _ = try hasher.verify("password", against: "not-a-valid-hash")
        }
    }

    @Test("Empty password can be hashed and verified")
    func emptyPassword() throws {
        let hasher = PrismPBKDF2Hasher(iterations: 1_000)
        let hash = try hasher.hash("")
        let valid = try hasher.verify("", against: hash)
        #expect(valid)
    }

    @Test("Long password can be hashed and verified")
    func longPassword() throws {
        let longPwd = String(repeating: "abcdefghij", count: 100)
        let hasher = PrismPBKDF2Hasher(iterations: 1_000)
        let hash = try hasher.hash(longPwd)
        let valid = try hasher.verify(longPwd, against: hash)
        #expect(valid)
    }
}

@Suite("PrismPasswordHashingError Tests")
struct PrismPasswordHashingErrorTests {

    @Test("Incomplete hash string throws invalidFormat")
    func incompleteHash() throws {
        let hasher = PrismPBKDF2Hasher()
        #expect(throws: PrismPasswordHashingError.self) {
            _ = try hasher.verify("pw", against: "$pbkdf2-sha256$600000$salt")
        }
    }

    @Test("Unknown algorithm throws invalidFormat")
    func unknownAlgorithm() throws {
        let hasher = PrismPBKDF2Hasher()
        #expect(throws: PrismPasswordHashingError.self) {
            _ = try hasher.verify("pw", against: "$unknown-algo$1000$c2FsdA==$aGFzaA==")
        }
    }

    @Test("Non-integer iterations throws invalidFormat")
    func nonIntegerIterations() throws {
        let hasher = PrismPBKDF2Hasher()
        #expect(throws: PrismPasswordHashingError.self) {
            _ = try hasher.verify("pw", against: "$pbkdf2-sha256$abc$c2FsdA==$aGFzaA==")
        }
    }
}
#endif
