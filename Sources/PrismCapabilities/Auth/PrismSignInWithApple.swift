#if canImport(AuthenticationServices)
import AuthenticationServices

// MARK: - Apple ID Scope

/// The scope of user information requested during Sign in with Apple.
public enum PrismAppleIDScope: Sendable, CaseIterable {
    /// Request the user's email address.
    case email
    /// Request the user's full name.
    case fullName
}

// MARK: - Apple ID Credential

/// The credential returned after a successful Sign in with Apple authorization.
public struct PrismAppleIDCredential: Sendable {
    /// The unique user identifier stable across the same developer team.
    public let userID: String
    /// The user's email address, if requested and granted.
    public let email: String?
    /// The user's full name, if requested and granted.
    public let fullName: String?
    /// The JSON Web Token (JWT) used to verify the user's identity.
    public let identityToken: Data?
    /// A short-lived token for exchanging with your server.
    public let authorizationCode: Data?

    /// Creates a new Apple ID credential with the given user information.
    public init(userID: String, email: String? = nil, fullName: String? = nil, identityToken: Data? = nil, authorizationCode: Data? = nil) {
        self.userID = userID
        self.email = email
        self.fullName = fullName
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
    }
}

// MARK: - Credential State

/// The current state of an Apple ID credential.
public enum PrismAppleIDCredentialState: Sendable, CaseIterable {
    /// The user's Apple ID credential is valid and authorized.
    case authorized
    /// The user's Apple ID credential has been revoked.
    case revoked
    /// No credential was found for the given user identifier.
    case notFound
    /// The user's credential has been transferred to a different team.
    case transferred
}

// MARK: - Sign In Client

/// Client that wraps AuthenticationServices for Sign in with Apple.
@MainActor
public final class PrismSignInWithAppleClient {

    /// Creates a new Sign in with Apple client.
    public init() {}

    /// Initiates a Sign in with Apple authorization flow with the requested scopes.
    public func signIn(scopes: [PrismAppleIDScope]) async throws -> PrismAppleIDCredential {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = scopes.map { scope in
            switch scope {
            case .email: .email
            case .fullName: .fullName
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            let delegate = SignInDelegate { result in
                continuation.resume(with: result)
            }
            let controller = ASAuthorizationController(authorizationRequests: [request])
            objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            controller.delegate = delegate
            controller.performRequests()
        }
    }

    /// Checks the current credential state for the given user identifier.
    public func checkCredentialState(userID: String) async -> PrismAppleIDCredentialState {
        await withCheckedContinuation { continuation in
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
                let prismState: PrismAppleIDCredentialState = switch state {
                case .authorized: .authorized
                case .revoked: .revoked
                case .notFound: .notFound
                case .transferred: .transferred
                @unknown default: .notFound
                }
                continuation.resume(returning: prismState)
            }
        }
    }
}

// MARK: - Private Delegate

private final class SignInDelegate: NSObject, ASAuthorizationControllerDelegate, @unchecked Sendable {
    private let completion: (Result<PrismAppleIDCredential, Error>) -> Void

    init(completion: @escaping (Result<PrismAppleIDCredential, Error>) -> Void) {
        self.completion = completion
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            completion(.failure(ASAuthorizationError(.unknown)))
            return
        }
        let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        let prismCredential = PrismAppleIDCredential(
            userID: credential.user,
            email: credential.email,
            fullName: fullName.isEmpty ? nil : fullName,
            identityToken: credential.identityToken,
            authorizationCode: credential.authorizationCode
        )
        completion(.success(prismCredential))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
}
#endif
