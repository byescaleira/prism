import CryptoKit
import Foundation
import Testing

@testable import PrismSecurity

@Suite("Encryptor")
struct PrismEncryptorTests {
    @Test("AES-GCM encrypt/decrypt round trip")
    func aesRoundTrip() throws {
        let encryptor = PrismEncryptor(algorithm: .aesGCM)
        let key = encryptor.generateKey()
        let plaintext = Data("Hello, PrismSecurity!".utf8)

        let encrypted = try encryptor.encrypt(plaintext, using: key)
        let decrypted = try encryptor.decrypt(encrypted, using: key)

        #expect(decrypted == plaintext)
        #expect(encrypted != plaintext)
    }

    @Test("ChaChaPoly encrypt/decrypt round trip")
    func chachaRoundTrip() throws {
        let encryptor = PrismEncryptor(algorithm: .chaChaPoly)
        let key = encryptor.generateKey()
        let plaintext = Data("ChaCha20-Poly1305 test".utf8)

        let encrypted = try encryptor.encrypt(plaintext, using: key)
        let decrypted = try encryptor.decrypt(encrypted, using: key)

        #expect(decrypted == plaintext)
    }

    @Test("Wrong key fails decryption")
    func wrongKey() throws {
        let encryptor = PrismEncryptor()
        let key1 = encryptor.generateKey()
        let key2 = encryptor.generateKey()
        let plaintext = Data("secret".utf8)

        let encrypted = try encryptor.encrypt(plaintext, using: key1)
        #expect(throws: PrismSecurityError.self) {
            try encryptor.decrypt(encrypted, using: key2)
        }
    }

    @Test("Codable encrypt/decrypt")
    func codableRoundTrip() throws {
        struct Secret: Codable, Sendable, Equatable {
            let token: String
            let count: Int
        }

        let encryptor = PrismEncryptor()
        let key = encryptor.generateKey()
        let value = Secret(token: "abc123", count: 42)

        let encrypted = try encryptor.encrypt(value, using: key)
        let decrypted = try encryptor.decrypt(Secret.self, from: encrypted, using: key)

        #expect(decrypted == value)
    }

    @Test("Key export/import round trip")
    func keyExportImport() throws {
        let encryptor = PrismEncryptor()
        let original = encryptor.generateKey()
        let exported = encryptor.exportKey(original)
        let imported = encryptor.importKey(exported)

        let plaintext = Data("key round trip".utf8)
        let encrypted = try encryptor.encrypt(plaintext, using: original)
        let decrypted = try encryptor.decrypt(encrypted, using: imported)

        #expect(decrypted == plaintext)
    }

    @Test("Empty data encrypts/decrypts")
    func emptyData() throws {
        let encryptor = PrismEncryptor()
        let key = encryptor.generateKey()
        let empty = Data()

        let encrypted = try encryptor.encrypt(empty, using: key)
        let decrypted = try encryptor.decrypt(encrypted, using: key)

        #expect(decrypted == empty)
    }

    @Test("Large data encrypts/decrypts")
    func largeData() throws {
        let encryptor = PrismEncryptor()
        let key = encryptor.generateKey()
        let large = Data(repeating: 0xAB, count: 1_000_000)

        let encrypted = try encryptor.encrypt(large, using: key)
        let decrypted = try encryptor.decrypt(encrypted, using: key)

        #expect(decrypted == large)
    }

    @Test("Both algorithms available")
    func algorithms() {
        #expect(PrismEncryptor.Algorithm.allCases.count == 2)
    }
}

@Suite("Hasher")
struct PrismHasherTests {
    @Test("SHA256 produces 32 bytes")
    func sha256Size() {
        let hasher = PrismHasher(algorithm: .sha256)
        let hash = hasher.hash("test")
        #expect(hash.count == 32)
    }

    @Test("SHA384 produces 48 bytes")
    func sha384Size() {
        let hasher = PrismHasher(algorithm: .sha384)
        let hash = hasher.hash("test")
        #expect(hash.count == 48)
    }

    @Test("SHA512 produces 64 bytes")
    func sha512Size() {
        let hasher = PrismHasher(algorithm: .sha512)
        let hash = hasher.hash("test")
        #expect(hash.count == 64)
    }

    @Test("Same input produces same hash")
    func deterministic() {
        let hasher = PrismHasher()
        let h1 = hasher.hash("hello")
        let h2 = hasher.hash("hello")
        #expect(h1 == h2)
    }

    @Test("Different input produces different hash")
    func unique() {
        let hasher = PrismHasher()
        let h1 = hasher.hash("hello")
        let h2 = hasher.hash("world")
        #expect(h1 != h2)
    }

    @Test("Hex hash format")
    func hexFormat() {
        let hasher = PrismHasher()
        let hex = hasher.hashHex("test")
        #expect(hex.count == 64) // 32 bytes = 64 hex chars
        #expect(hex.allSatisfy { "0123456789abcdef".contains($0) })
    }

    @Test("HMAC generation and verification")
    func hmac() {
        let hasher = PrismHasher()
        let key = SymmetricKey(size: .bits256)
        let data = Data("authenticated message".utf8)

        let mac = hasher.hmac(data, key: key)
        #expect(hasher.verifyHMAC(mac, for: data, key: key))
    }

    @Test("HMAC fails with wrong key")
    func hmacWrongKey() {
        let hasher = PrismHasher()
        let key1 = SymmetricKey(size: .bits256)
        let key2 = SymmetricKey(size: .bits256)
        let data = Data("message".utf8)

        let mac = hasher.hmac(data, key: key1)
        #expect(!hasher.verifyHMAC(mac, for: data, key: key2))
    }

    @Test("HMAC fails with wrong data")
    func hmacWrongData() {
        let hasher = PrismHasher()
        let key = SymmetricKey(size: .bits256)
        let data = Data("original".utf8)
        let tampered = Data("tampered".utf8)

        let mac = hasher.hmac(data, key: key)
        #expect(!hasher.verifyHMAC(mac, for: tampered, key: key))
    }

    @Test("All algorithms available")
    func algorithms() {
        #expect(PrismHasher.Algorithm.allCases.count == 3)
    }
}

@Suite("KeyDeriv")
struct PrismKeyDerivationTests {
    @Test("Derive key from symmetric key")
    func deriveFromKey() {
        let kd = PrismKeyDerivation()
        let inputKey = SymmetricKey(size: .bits256)
        let derived = kd.deriveKey(from: inputKey)

        let exported = derived.withUnsafeBytes { Data($0) }
        #expect(exported.count == 32)
    }

    @Test("Same input produces same derived key")
    func deterministic() {
        let kd = PrismKeyDerivation()
        let inputKey = SymmetricKey(data: Data(repeating: 0x42, count: 32))
        let salt = Data(repeating: 0x01, count: 32)

        let k1 = kd.deriveKey(from: inputKey, salt: salt)
        let k2 = kd.deriveKey(from: inputKey, salt: salt)

        let d1 = k1.withUnsafeBytes { Data($0) }
        let d2 = k2.withUnsafeBytes { Data($0) }
        #expect(d1 == d2)
    }

    @Test("Different salt produces different key")
    func differentSalt() {
        let kd = PrismKeyDerivation()
        let inputKey = SymmetricKey(data: Data(repeating: 0x42, count: 32))

        let k1 = kd.deriveKey(from: inputKey, salt: Data(repeating: 0x01, count: 32))
        let k2 = kd.deriveKey(from: inputKey, salt: Data(repeating: 0x02, count: 32))

        let d1 = k1.withUnsafeBytes { Data($0) }
        let d2 = k2.withUnsafeBytes { Data($0) }
        #expect(d1 != d2)
    }

    @Test("Derive key from password")
    func passwordDerivation() {
        let kd = PrismKeyDerivation()
        let salt = kd.generateSalt()
        let key = kd.deriveKey(fromPassword: "myPassword123", salt: salt)

        let exported = key.withUnsafeBytes { Data($0) }
        #expect(exported.count == 32)
    }

    @Test("Generate salt produces correct size")
    func saltSize() {
        let kd = PrismKeyDerivation()
        let salt16 = kd.generateSalt(byteCount: 16)
        let salt32 = kd.generateSalt(byteCount: 32)

        #expect(salt16.count == 16)
        #expect(salt32.count == 32)
    }

    @Test("Generated salts are unique")
    func saltUnique() {
        let kd = PrismKeyDerivation()
        let s1 = kd.generateSalt()
        let s2 = kd.generateSalt()
        #expect(s1 != s2)
    }

    @Test("Derive from shared secret")
    func sharedSecret() {
        let kd = PrismKeyDerivation()
        let secret = Data(repeating: 0xFF, count: 32)
        let key = kd.deriveKey(from: secret)

        let exported = key.withUnsafeBytes { Data($0) }
        #expect(exported.count == 32)
    }

    @Test("Custom output byte count")
    func customOutputSize() {
        let kd = PrismKeyDerivation()
        let inputKey = SymmetricKey(size: .bits256)
        let key = kd.deriveKey(from: inputKey, outputByteCount: 64)

        let exported = key.withUnsafeBytes { Data($0) }
        #expect(exported.count == 64)
    }
}
