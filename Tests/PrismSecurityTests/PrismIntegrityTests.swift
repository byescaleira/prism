import CryptoKit
import Foundation
import Testing

@testable import PrismSecurity

@Suite("IntPolicy")
struct PrismIntegrityPolicyTests {
    @Test("All actions available")
    func allActions() {
        #expect(PrismIntegrityAction.allCases.count == 3)
    }

    @Test("All violation kinds available")
    func allKinds() {
        #expect(PrismIntegrityViolationKind.allCases.count == 6)
    }

    @Test("Default policy has log action")
    func defaultPolicy() {
        let policy = PrismIntegrityPolicy.default
        #expect(policy.actions == [.log])
    }

    @Test("Strict policy has all actions")
    func strictPolicy() {
        let policy = PrismIntegrityPolicy.strict
        #expect(policy.actions.count == 3)
    }

    @Test("Violation equality")
    func violationEquality() {
        let v1 = PrismIntegrityViolation(kind: .jailbreak, detail: "test")
        let v2 = PrismIntegrityViolation(kind: .jailbreak, detail: "test")
        #expect(v1.kind == v2.kind)
        #expect(v1.detail == v2.detail)
    }
}

@Suite("IntCheck")
struct PrismIntegrityCheckerTests {
    let checker = PrismIntegrityChecker()

    @Test("Checker returns results")
    func checkAll() {
        let violations = checker.checkAll()
        #expect(violations is [PrismIntegrityViolation])
    }

    @Test("Simulator detection works")
    func simulator() {
        #if targetEnvironment(simulator)
            #expect(checker.isSimulator())
        #else
            #expect(!checker.isSimulator())
        #endif
    }

    @Test("Not jailbroken in test environment")
    func jailbreak() {
        #if targetEnvironment(simulator)
            #expect(!checker.isJailbroken())
        #endif
    }
}

@Suite("DataSeal")
struct PrismDataSealTests {
    let key = SymmetricKey(size: .bits256)

    @Test("Seal and unseal Codable")
    func roundTrip() throws {
        struct Secret: Codable, Sendable, Equatable {
            let value: String
        }
        let seal = PrismDataSeal(key: key)
        let original = Secret(value: "confidential")
        let sealed = try seal.seal(original)
        let unsealed = try seal.unseal(Secret.self, from: sealed)
        #expect(unsealed == original)
    }

    @Test("Seal and verify data")
    func verifyData() {
        let seal = PrismDataSeal(key: key)
        let data = Data("important data".utf8)
        let sealed = seal.sealData(data)
        #expect(seal.verify(sealed))
    }

    @Test("Tampered data fails verification")
    func tamperedData() {
        let seal = PrismDataSeal(key: key)
        let data = Data("original".utf8)
        let sealed = seal.sealData(data)

        var tampered = sealed
        tampered = PrismDataSeal.SealedData(
            payload: Data("tampered".utf8),
            mac: sealed.mac,
            sealedAt: sealed.sealedAt
        )
        #expect(!seal.verify(tampered))
    }

    @Test("Wrong key fails verification")
    func wrongKey() {
        let seal1 = PrismDataSeal(key: SymmetricKey(size: .bits256))
        let seal2 = PrismDataSeal(key: SymmetricKey(size: .bits256))
        let sealed = seal1.sealData(Data("test".utf8))
        #expect(!seal2.verify(sealed))
    }

    @Test("Unseal tampered data throws")
    func unsealTampered() throws {
        struct Value: Codable, Sendable { let x: Int }
        let seal = PrismDataSeal(key: key)
        let sealed = try seal.seal(Value(x: 1))
        let tampered = PrismDataSeal.SealedData(
            payload: Data("bad".utf8),
            mac: sealed.mac,
            sealedAt: sealed.sealedAt
        )
        #expect(throws: PrismSecurityError.self) {
            try seal.unseal(Value.self, from: tampered)
        }
    }

    @Test("Raw data verify")
    func rawVerify() {
        let seal = PrismDataSeal(key: key)
        let data = Data("msg".utf8)
        let mac = Data(HMAC<SHA256>.authenticationCode(for: data, using: key))
        #expect(seal.verify(data: data, mac: mac))
    }
}
