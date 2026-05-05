import CryptoKit
import Foundation

/// Cryptographic hashing and HMAC operations via CryptoKit.
public struct PrismHasher: Sendable {
    /// Supported hash algorithms.
    public enum Algorithm: String, Sendable, Hashable, CaseIterable {
        case sha256
        case sha384
        case sha512
    }

    private let algorithm: Algorithm

    /// Creates a hasher with the specified algorithm.
    public init(algorithm: Algorithm = .sha256) {
        self.algorithm = algorithm
    }

    /// Computes a hash digest of the given data.
    public func hash(_ data: Data) -> Data {
        switch algorithm {
        case .sha256: Data(SHA256.hash(data: data))
        case .sha384: Data(SHA384.hash(data: data))
        case .sha512: Data(SHA512.hash(data: data))
        }
    }

    /// Computes a hash digest of the given string.
    public func hash(_ string: String) -> Data {
        hash(Data(string.utf8))
    }

    /// Computes a hex-encoded hash digest.
    public func hashHex(_ data: Data) -> String {
        hash(data).map { String(format: "%02x", $0) }.joined()
    }

    /// Computes a hex-encoded hash of a string.
    public func hashHex(_ string: String) -> String {
        hashHex(Data(string.utf8))
    }

    /// Computes an HMAC authentication code.
    public func hmac(_ data: Data, key: SymmetricKey) -> Data {
        switch algorithm {
        case .sha256:
            Data(HMAC<SHA256>.authenticationCode(for: data, using: key))
        case .sha384:
            Data(HMAC<SHA384>.authenticationCode(for: data, using: key))
        case .sha512:
            Data(HMAC<SHA512>.authenticationCode(for: data, using: key))
        }
    }

    /// Verifies an HMAC authentication code.
    public func verifyHMAC(_ mac: Data, for data: Data, key: SymmetricKey) -> Bool {
        switch algorithm {
        case .sha256:
            HMAC<SHA256>.isValidAuthenticationCode(mac, authenticating: data, using: key)
        case .sha384:
            HMAC<SHA384>.isValidAuthenticationCode(mac, authenticating: data, using: key)
        case .sha512:
            HMAC<SHA512>.isValidAuthenticationCode(mac, authenticating: data, using: key)
        }
    }
}
