import CryptoKit
import Foundation
import Testing

@testable import PrismSecurity

@Suite("KeyAgree")
struct PrismKeyAgreementTests {
    @Test("Two parties derive same shared key")
    func sharedSecret() throws {
        let alice = PrismKeyAgreement()
        let bob = PrismKeyAgreement()

        let aliceKey = try alice.deriveSharedSecret(with: bob.publicKeyData)
        let bobKey = try bob.deriveSharedSecret(with: alice.publicKeyData)

        let aliceData = aliceKey.withUnsafeBytes { Data($0) }
        let bobData = bobKey.withUnsafeBytes { Data($0) }
        #expect(aliceData == bobData)
    }

    @Test("Public key data is exportable")
    func publicKeyExport() {
        let ka = PrismKeyAgreement()
        #expect(!ka.publicKeyData.isEmpty)
        #expect(ka.publicKeyData.count == 64) // P256 raw = 64 bytes
    }

    @Test("Different salt produces different key")
    func differentSalt() throws {
        let alice = PrismKeyAgreement()
        let bob = PrismKeyAgreement()

        let k1 = try alice.deriveSharedSecret(with: bob.publicKeyData, salt: Data("salt1".utf8))
        let k2 = try alice.deriveSharedSecret(with: bob.publicKeyData, salt: Data("salt2".utf8))

        let d1 = k1.withUnsafeBytes { Data($0) }
        let d2 = k2.withUnsafeBytes { Data($0) }
        #expect(d1 != d2)
    }

    @Test("Invalid public key throws")
    func invalidKey() {
        let ka = PrismKeyAgreement()
        #expect(throws: Error.self) {
            try ka.deriveSharedSecret(with: Data("bad".utf8))
        }
    }
}

@Suite("Envelope")
struct PrismSecureEnvelopeTests {
    @Test("Seal and open envelope")
    func roundTrip() throws {
        let senderSigning = P256.Signing.PrivateKey()
        let recipientAgreement = P256.KeyAgreement.PrivateKey()

        let plaintext = Data("Top secret message".utf8)
        let envelope = try PrismSecureEnvelope.seal(
            data: plaintext,
            recipientPublicKey: recipientAgreement.publicKey.rawRepresentation,
            senderSigningKey: senderSigning
        )

        let decrypted = try PrismSecureEnvelope.open(
            envelope,
            recipientPrivateKey: recipientAgreement,
            senderVerifyKey: senderSigning.publicKey.rawRepresentation
        )

        #expect(decrypted == plaintext)
    }

    @Test("Wrong sender key fails verification")
    func wrongSenderKey() throws {
        let sender = P256.Signing.PrivateKey()
        let imposter = P256.Signing.PrivateKey()
        let recipient = P256.KeyAgreement.PrivateKey()

        let envelope = try PrismSecureEnvelope.seal(
            data: Data("msg".utf8),
            recipientPublicKey: recipient.publicKey.rawRepresentation,
            senderSigningKey: sender
        )

        #expect(throws: PrismSecurityError.self) {
            try PrismSecureEnvelope.open(
                envelope,
                recipientPrivateKey: recipient,
                senderVerifyKey: imposter.publicKey.rawRepresentation
            )
        }
    }

    @Test("Codable round trip")
    func codableRoundTrip() throws {
        struct Message: Codable, Sendable, Equatable {
            let text: String
            let priority: Int
        }

        let sender = P256.Signing.PrivateKey()
        let recipient = P256.KeyAgreement.PrivateKey()
        let original = Message(text: "urgent", priority: 1)

        let envelope = try PrismSecureEnvelope.seal(
            original,
            recipientPublicKey: recipient.publicKey.rawRepresentation,
            senderSigningKey: sender
        )

        let decoded = try PrismSecureEnvelope.open(
            Message.self,
            from: envelope,
            recipientPrivateKey: recipient,
            senderVerifyKey: sender.publicKey.rawRepresentation
        )

        #expect(decoded == original)
    }

    @Test("Envelope has ephemeral key (forward secrecy)")
    func forwardSecrecy() throws {
        let sender = P256.Signing.PrivateKey()
        let recipient = P256.KeyAgreement.PrivateKey()

        let e1 = try PrismSecureEnvelope.seal(
            data: Data("msg1".utf8),
            recipientPublicKey: recipient.publicKey.rawRepresentation,
            senderSigningKey: sender
        )
        let e2 = try PrismSecureEnvelope.seal(
            data: Data("msg1".utf8),
            recipientPublicKey: recipient.publicKey.rawRepresentation,
            senderSigningKey: sender
        )

        #expect(e1.ephemeralPublicKey != e2.ephemeralPublicKey)
    }
}

@Suite("SecChan")
struct PrismSecureChannelTests {
    @Test("Channel encrypt/decrypt round trip")
    func roundTrip() throws {
        let alice = PrismSecureChannel()
        let bob = PrismSecureChannel()

        try alice.establish(with: bob.publicKeyData)
        try bob.establish(with: alice.publicKeyData)

        let plaintext = Data("Hello Bob!".utf8)
        let encrypted = try alice.encrypt(plaintext)
        let decrypted = try bob.decrypt(encrypted)

        #expect(decrypted == plaintext)
    }

    @Test("Channel not established throws on encrypt")
    func notEstablished() {
        let channel = PrismSecureChannel()
        #expect(throws: PrismSecurityError.invalidKey) {
            try channel.encrypt(Data("test".utf8))
        }
    }

    @Test("Channel isEstablished flag")
    func establishedFlag() throws {
        let alice = PrismSecureChannel()
        let bob = PrismSecureChannel()

        #expect(!alice.isEstablished)
        try alice.establish(with: bob.publicKeyData)
        #expect(alice.isEstablished)
    }

    @Test("Channel close zeros key")
    func close() throws {
        let alice = PrismSecureChannel()
        let bob = PrismSecureChannel()

        try alice.establish(with: bob.publicKeyData)
        alice.close()
        #expect(!alice.isEstablished)
        #expect(throws: PrismSecurityError.invalidKey) {
            try alice.encrypt(Data("test".utf8))
        }
    }

    @Test("Codable through channel")
    func codable() throws {
        struct Payload: Codable, Sendable, Equatable {
            let id: Int
            let name: String
        }

        let alice = PrismSecureChannel()
        let bob = PrismSecureChannel()

        try alice.establish(with: bob.publicKeyData)
        try bob.establish(with: alice.publicKeyData)

        let original = Payload(id: 42, name: "test")
        let encrypted = try alice.encrypt(original)
        let decrypted = try bob.decrypt(Payload.self, from: encrypted)

        #expect(decrypted == original)
    }

    @Test("ChaChaPoly algorithm")
    func chaChaPoly() throws {
        let alice = PrismSecureChannel(algorithm: .chaChaPoly)
        let bob = PrismSecureChannel(algorithm: .chaChaPoly)

        try alice.establish(with: bob.publicKeyData)
        try bob.establish(with: alice.publicKeyData)

        let data = Data("ChaCha test".utf8)
        let encrypted = try alice.encrypt(data)
        let decrypted = try bob.decrypt(encrypted)

        #expect(decrypted == data)
    }
}
