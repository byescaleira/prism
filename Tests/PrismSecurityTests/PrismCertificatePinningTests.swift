import CryptoKit
import Foundation
import os
import Testing

@testable import PrismSecurity

@Suite("CertPin")
struct PrismCertificatePinTests {
    @Test("Hash produces consistent base64 output")
    func hashConsistent() {
        let data = Data("test-public-key".utf8)
        let h1 = PrismCertificatePin.hash(publicKeyDER: data)
        let h2 = PrismCertificatePin.hash(publicKeyDER: data)
        #expect(h1 == h2)
    }

    @Test("Different data produces different hashes")
    func hashUnique() {
        let h1 = PrismCertificatePin.hash(publicKeyDER: Data("key1".utf8))
        let h2 = PrismCertificatePin.hash(publicKeyDER: Data("key2".utf8))
        #expect(h1 != h2)
    }

    @Test("Pin allHashes includes primary and backups")
    func allHashes() {
        let pin = PrismCertificatePin(
            host: "api.example.com",
            publicKeyHash: "AAAA",
            backupHashes: ["BBBB", "CCCC"]
        )
        #expect(pin.allHashes == Set(["AAAA", "BBBB", "CCCC"]))
    }

    @Test("Pin not expired when no expiry")
    func noExpiry() {
        let pin = PrismCertificatePin(host: "test.com", publicKeyHash: "hash")
        #expect(!pin.isExpired)
    }

    @Test("Pin expired when past date")
    func expired() {
        let pin = PrismCertificatePin(
            host: "test.com",
            publicKeyHash: "hash",
            expiresAt: Date.now.addingTimeInterval(-3600)
        )
        #expect(pin.isExpired)
    }

    @Test("Pin not expired when future date")
    func notExpired() {
        let pin = PrismCertificatePin(
            host: "test.com",
            publicKeyHash: "hash",
            expiresAt: Date.now.addingTimeInterval(3600)
        )
        #expect(!pin.isExpired)
    }

    @Test("Pin ID generated from host and hash")
    func pinID() {
        let pin = PrismCertificatePin(host: "example.com", publicKeyHash: "ABCDEFGH1234")
        #expect(pin.id.contains("example.com"))
    }
}

@Suite("PinPolicy")
struct PrismPinningPolicyTests {
    @Test("All policies available")
    func allPolicies() {
        #expect(PrismPinningPolicy.allCases.count == 3)
    }

    @Test("Pinning result equality")
    func resultEquality() {
        let r1 = PrismPinningResult(host: "a.com", isValid: true, serverHash: "h1")
        let r2 = PrismPinningResult(host: "a.com", isValid: true, serverHash: "h1")
        #expect(r1 == r2)
    }
}

@Suite("PinValid")
struct PrismPinningValidatorTests {
    @Test("No pins for host allows connection")
    func noPinsAllows() async {
        let validator = PrismPinningValidator(pins: [], policy: .strict)
        let result = await validator.validate(publicKeyHash: "any", forHost: "unknown.com")
        #expect(result.isValid)
    }

    @Test("Matching pin validates")
    func matchingPin() async {
        let pin = PrismCertificatePin(host: "api.com", publicKeyHash: "correctHash")
        let validator = PrismPinningValidator(pins: [pin], policy: .strict)
        let result = await validator.validate(publicKeyHash: "correctHash", forHost: "api.com")
        #expect(result.isValid)
        #expect(result.matchedHash == "correctHash")
    }

    @Test("Wrong hash fails strict validation")
    func wrongHashFails() async {
        let pin = PrismCertificatePin(host: "api.com", publicKeyHash: "correctHash")
        let validator = PrismPinningValidator(pins: [pin], policy: .strict)
        let result = await validator.validate(publicKeyHash: "wrongHash", forHost: "api.com")
        #expect(!result.isValid)
    }

    @Test("Backup hash validates")
    func backupHash() async {
        let pin = PrismCertificatePin(
            host: "api.com",
            publicKeyHash: "primary",
            backupHashes: ["backup1", "backup2"]
        )
        let validator = PrismPinningValidator(pins: [pin], policy: .strict)
        let result = await validator.validate(publicKeyHash: "backup2", forHost: "api.com")
        #expect(result.isValid)
    }

    @Test("Expired pin allows connection")
    func expiredPinAllows() async {
        let pin = PrismCertificatePin(
            host: "api.com",
            publicKeyHash: "hash",
            expiresAt: Date.now.addingTimeInterval(-100)
        )
        let validator = PrismPinningValidator(pins: [pin], policy: .strict)
        let result = await validator.validate(publicKeyHash: "wrong", forHost: "api.com")
        #expect(result.isValid)
    }

    @Test("TOFU trusts first connection")
    func tofuFirstTrust() async {
        let validator = PrismPinningValidator(policy: .trustFirstUse)
        let result = await validator.validate(publicKeyHash: "firstHash", forHost: "new.com")
        #expect(result.isValid)
    }

    @Test("TOFU rejects different hash on second connection")
    func tofuRejectsDifferent() async {
        let validator = PrismPinningValidator(policy: .trustFirstUse)
        _ = await validator.validate(publicKeyHash: "firstHash", forHost: "new.com")
        let result = await validator.validate(publicKeyHash: "differentHash", forHost: "new.com")
        #expect(!result.isValid)
    }

    @Test("TOFU accepts same hash on second connection")
    func tofuAcceptsSame() async {
        let validator = PrismPinningValidator(policy: .trustFirstUse)
        _ = await validator.validate(publicKeyHash: "sameHash", forHost: "new.com")
        let result = await validator.validate(publicKeyHash: "sameHash", forHost: "new.com")
        #expect(result.isValid)
    }

    @Test("Add and remove pins dynamically")
    func dynamicPins() async {
        let validator = PrismPinningValidator(policy: .strict)
        let pin = PrismCertificatePin(host: "dynamic.com", publicKeyHash: "hash1")

        await validator.addPin(pin)
        let r1 = await validator.validate(publicKeyHash: "hash1", forHost: "dynamic.com")
        #expect(r1.isValid)

        await validator.removePin(forHost: "dynamic.com")
        let r2 = await validator.validate(publicKeyHash: "any", forHost: "dynamic.com")
        #expect(r2.isValid)
    }

    @Test("Violation handler called on failure")
    func violationHandler() async {
        let called = OSAllocatedUnfairLock(initialState: false)
        let pin = PrismCertificatePin(host: "api.com", publicKeyHash: "correct")
        let validator = PrismPinningValidator(pins: [pin], policy: .strict) { _ in
            called.withLock { $0 = true }
        }
        _ = await validator.validate(publicKeyHash: "wrong", forHost: "api.com")
        #expect(called.withLock { $0 })
    }
}
