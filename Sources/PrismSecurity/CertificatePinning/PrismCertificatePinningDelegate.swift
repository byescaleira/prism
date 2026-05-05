import CryptoKit
import Foundation
import Security

/// URLSession delegate that enforces certificate pinning.
///
/// ```swift
/// let validator = PrismPinningValidator(pins: [
///     PrismCertificatePin(
///         host: "api.example.com",
///         publicKeyHash: "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=",
///         backupHashes: ["CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC="]
///     )
/// ])
/// let delegate = PrismCertificatePinningDelegate(validator: validator)
/// let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
/// ```
public final class PrismCertificatePinningDelegate: NSObject, URLSessionDelegate, Sendable {
    private let validator: PrismPinningValidator
    private let policy: PrismPinningPolicy

    public init(
        validator: PrismPinningValidator,
        policy: PrismPinningPolicy = .strict
    ) {
        self.validator = validator
        self.policy = policy
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust
        else {
            return (.performDefaultHandling, nil)
        }

        let host = challenge.protectionSpace.host
        let credential = URLCredential(trust: serverTrust)
        let publicKeyHash = Self.extractPublicKeyHash(from: serverTrust)
        let result: PrismPinningResult
        if let hash = publicKeyHash {
            result = await validator.validate(publicKeyHash: hash, forHost: host)
        } else {
            result = PrismPinningResult(host: host, isValid: false, serverHash: "extraction_failed")
        }

        switch policy {
        case .strict:
            if result.isValid {
                return (.useCredential, credential)
            }
            return (.cancelAuthenticationChallenge, nil)

        case .reportOnly:
            return (.useCredential, credential)

        case .trustFirstUse:
            if result.isValid {
                return (.useCredential, credential)
            }
            return (.cancelAuthenticationChallenge, nil)
        }
    }

    private static func extractPublicKeyHash(from trust: SecTrust) -> String? {
        guard SecTrustGetCertificateCount(trust) > 0,
              let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let leaf = chain.first,
              let publicKey = SecCertificateCopyKey(leaf)
        else { return nil }

        var error: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as? Data else {
            return nil
        }

        return PrismCertificatePin.hash(publicKeyDER: keyData)
    }
}
