import Foundation

public enum PrismStorageError: Error, Sendable, Equatable, LocalizedError {
    case encodingFailed(String)
    case decodingFailed(String)
    case writeFailed(String)
    case readFailed(String)
    case deleteFailed(String)
    case keyNotFound(String)
    case diskFull
    case migrationFailed(String)
    case containerNotAvailable
    case transactionFailed(String)
    case compressionFailed
    case decompressionFailed
    case encryptionFailed
    case decryptionFailed
    case quotaExceeded(Int)
    case invalidConfiguration(String)

    public var errorDescription: String? {
        switch self {
        case .encodingFailed(let detail): "Encoding failed: \(detail)"
        case .decodingFailed(let detail): "Decoding failed: \(detail)"
        case .writeFailed(let detail): "Write failed: \(detail)"
        case .readFailed(let detail): "Read failed: \(detail)"
        case .deleteFailed(let detail): "Delete failed: \(detail)"
        case .keyNotFound(let key): "Key not found: \(key)"
        case .diskFull: "Disk full"
        case .migrationFailed(let detail): "Migration failed: \(detail)"
        case .containerNotAvailable: "SwiftData container not available"
        case .transactionFailed(let detail): "Transaction failed: \(detail)"
        case .compressionFailed: "Compression failed"
        case .decompressionFailed: "Decompression failed"
        case .encryptionFailed: "Encryption failed"
        case .decryptionFailed: "Decryption failed"
        case .quotaExceeded(let bytes): "Quota exceeded: \(bytes) bytes"
        case .invalidConfiguration(let detail): "Invalid configuration: \(detail)"
        }
    }
}
