import CryptoKit
import Foundation

/// Hash-based file tamper detection.
///
/// Computes and stores SHA-256 hashes of critical files, then verifies them later.
///
/// ```swift
/// let integrity = PrismFileIntegrity()
/// try integrity.registerFile(at: configURL)
///
/// // Later...
/// let result = try integrity.verify(at: configURL)
/// if !result.isValid {
///     print("File was tampered with!")
/// }
/// ```
public struct PrismFileIntegrity: Sendable {
    private let keychain: PrismKeychain

    public init(keychain: PrismKeychain = PrismKeychain(service: "PrismFileIntegrity")) {
        self.keychain = keychain
    }

    /// Result of a file integrity verification.
    public struct VerificationResult: Sendable, Equatable {
        public let path: String
        public let isValid: Bool
        public let expectedHash: String
        public let actualHash: String
        public let verifiedAt: Date

        public init(path: String, isValid: Bool, expectedHash: String, actualHash: String, verifiedAt: Date = .now) {
            self.path = path
            self.isValid = isValid
            self.expectedHash = expectedHash
            self.actualHash = actualHash
            self.verifiedAt = verifiedAt
        }
    }

    /// Computes and stores the hash of a file.
    public func registerFile(at url: URL) throws {
        let hash = try computeHash(at: url)
        let item = PrismKeychainItem(id: hashKey(for: url), service: "PrismFileIntegrity")
        try keychain.save(string: hash, for: item)
    }

    /// Verifies a file against its stored hash.
    public func verify(at url: URL) throws -> VerificationResult {
        let item = PrismKeychainItem(id: hashKey(for: url), service: "PrismFileIntegrity")
        let expectedHash = try keychain.loadString(for: item)
        let actualHash = try computeHash(at: url)

        return VerificationResult(
            path: url.path,
            isValid: expectedHash == actualHash,
            expectedHash: expectedHash,
            actualHash: actualHash
        )
    }

    /// Verifies multiple files and returns all violations.
    public func verifyAll(at urls: [URL]) throws -> [VerificationResult] {
        try urls.map { try verify(at: $0) }
    }

    /// Re-registers a file (updates stored hash).
    public func updateHash(at url: URL) throws {
        try registerFile(at: url)
    }

    /// Removes stored hash for a file.
    public func unregister(at url: URL) throws {
        let item = PrismKeychainItem(id: hashKey(for: url), service: "PrismFileIntegrity")
        try keychain.delete(for: item)
    }

    /// Computes SHA-256 hash of file contents.
    public func computeHash(at url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func hashKey(for url: URL) -> String {
        let pathHash = SHA256.hash(data: Data(url.path.utf8))
        return "file_\(pathHash.prefix(8).map { String(format: "%02x", $0) }.joined())"
    }
}
