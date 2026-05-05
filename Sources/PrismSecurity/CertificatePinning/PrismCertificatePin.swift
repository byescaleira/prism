import CryptoKit
import Foundation

/// A certificate pin representing a SHA-256 hash of a public key's SPKI data.
public struct PrismCertificatePin: Sendable, Hashable, Identifiable {
    public let id: String
    /// Host domain this pin applies to (e.g., "api.example.com").
    public let host: String
    /// SHA-256 hash of the Subject Public Key Info (SPKI), base64-encoded.
    public let publicKeyHash: String
    /// Backup pins for key rotation (minimum 1 recommended).
    public let backupHashes: [String]
    /// When this pin expires (optional).
    public let expiresAt: Date?

    public init(
        host: String,
        publicKeyHash: String,
        backupHashes: [String] = [],
        expiresAt: Date? = nil
    ) {
        self.id = "\(host)_\(publicKeyHash.prefix(8))"
        self.host = host
        self.publicKeyHash = publicKeyHash
        self.backupHashes = backupHashes
        self.expiresAt = expiresAt
    }

    /// All valid hashes (primary + backups).
    public var allHashes: Set<String> {
        Set([publicKeyHash] + backupHashes)
    }

    /// Whether this pin has expired.
    public var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date.now > expiresAt
    }

    /// Computes SHA-256 hash of a DER-encoded public key.
    public static func hash(publicKeyDER: Data) -> String {
        let digest = SHA256.hash(data: publicKeyDER)
        return Data(digest).base64EncodedString()
    }
}
