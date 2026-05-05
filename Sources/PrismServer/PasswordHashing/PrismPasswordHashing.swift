#if canImport(CommonCrypto)
    import Foundation
    import CommonCrypto

    /// Errors related to PasswordHashing operations.
    public enum PrismPasswordHashingError: Error, Sendable {
        case hashingFailed
        case invalidFormat
        case verificationFailed
    }

    /// PasswordHasher protocol.
    public protocol PrismPasswordHasher: Sendable {
        func hash(_ password: String) throws -> String
        func verify(_ password: String, against hash: String) throws -> Bool
    }

    /// Hash algorithm variants for PBKDF2 key derivation.
    public enum PrismPBKDF2Algorithm: String, Sendable {
        case sha256 = "pbkdf2-sha256"
        case sha512 = "pbkdf2-sha512"

        var ccAlgorithm: CCPseudoRandomAlgorithm {
            switch self {
            case .sha256: CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256)
            case .sha512: CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512)
            }
        }
    }

    /// Password hasher using PBKDF2 with SHA-256 key derivation.
    public struct PrismPBKDF2Hasher: PrismPasswordHasher {
        /// The algorithm.
        public let algorithm: PrismPBKDF2Algorithm
        /// The iterations.
        public let iterations: Int
        /// The salt length.
        public let saltLength: Int
        /// The key length.
        public let keyLength: Int

        /// Creates a new `PrismPBKDF2Hasher` with the specified configuration.
        public init(
            algorithm: PrismPBKDF2Algorithm = .sha256,
            iterations: Int = 600_000,
            saltLength: Int = 16,
            keyLength: Int = 32
        ) {
            self.algorithm = algorithm
            self.iterations = iterations
            self.saltLength = saltLength
            self.keyLength = keyLength
        }

        /// Computes a hash of the input.
        public func hash(_ password: String) throws -> String {
            var salt = [UInt8](repeating: 0, count: saltLength)
            for i in 0..<saltLength {
                salt[i] = UInt8.random(in: 0...255)
            }

            let derived = try deriveKey(password: password, salt: salt, iterations: iterations)

            let saltB64 = Data(salt).base64EncodedString()
            let hashB64 = Data(derived).base64EncodedString()
            return "$\(algorithm.rawValue)$\(iterations)$\(saltB64)$\(hashB64)"
        }

        /// Verifies the token signature and claims validity, returning the decoded claims.
        public func verify(_ password: String, against hash: String) throws -> Bool {
            let parts = hash.split(separator: "$", omittingEmptySubsequences: true)
            guard parts.count == 4 else { throw PrismPasswordHashingError.invalidFormat }

            let algString = String(parts[0])
            guard let parsedAlgorithm = PrismPBKDF2Algorithm(rawValue: algString) else {
                throw PrismPasswordHashingError.invalidFormat
            }

            guard let parsedIterations = Int(parts[1]) else {
                throw PrismPasswordHashingError.invalidFormat
            }

            guard let saltData = Data(base64Encoded: String(parts[2])) else {
                throw PrismPasswordHashingError.invalidFormat
            }

            guard let expectedHash = Data(base64Encoded: String(parts[3])) else {
                throw PrismPasswordHashingError.invalidFormat
            }

            let salt = [UInt8](saltData)
            let hasher = PrismPBKDF2Hasher(
                algorithm: parsedAlgorithm,
                iterations: parsedIterations,
                saltLength: salt.count,
                keyLength: expectedHash.count
            )

            let derived = try hasher.deriveKey(password: password, salt: salt, iterations: parsedIterations)

            return constantTimeEqual(derived, [UInt8](expectedHash))
        }

        private func deriveKey(password: String, salt: [UInt8], iterations: Int) throws -> [UInt8] {
            let passwordData = Array(password.utf8)
            var derivedKey = [UInt8](repeating: 0, count: keyLength)

            let status = CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                passwordData,
                passwordData.count,
                salt,
                salt.count,
                algorithm.ccAlgorithm,
                UInt32(iterations),
                &derivedKey,
                keyLength
            )

            guard status == kCCSuccess else {
                throw PrismPasswordHashingError.hashingFailed
            }

            return derivedKey
        }

        private func constantTimeEqual(_ a: [UInt8], _ b: [UInt8]) -> Bool {
            guard a.count == b.count else { return false }
            var result: UInt8 = 0
            for i in 0..<a.count {
                result |= a[i] ^ b[i]
            }
            return result == 0
        }
    }
#endif
