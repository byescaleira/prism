import CryptoKit
import Foundation

/// A tamper-evident audit log entry with hash chain integrity.
public struct PrismAuditLogEntry: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let event: PrismSecurityEvent
    /// SHA-256 hash of the previous entry (empty string for first entry).
    public let previousHash: String
    /// SHA-256 hash of this entry (event + previousHash).
    public let entryHash: String
    public let sequence: Int

    public init(event: PrismSecurityEvent, previousHash: String, sequence: Int) {
        self.id = event.id
        self.event = event
        self.previousHash = previousHash
        self.sequence = sequence

        var data = Data()
        data.append(Data(event.id.utf8))
        data.append(Data(event.kind.rawValue.utf8))
        data.append(Data(event.detail.utf8))
        data.append(Data("\(event.timestamp.timeIntervalSince1970)".utf8))
        data.append(Data(previousHash.utf8))
        data.append(Data("\(sequence)".utf8))
        let digest = SHA256.hash(data: data)
        self.entryHash = digest.map { String(format: "%02x", $0) }.joined()
    }
}
