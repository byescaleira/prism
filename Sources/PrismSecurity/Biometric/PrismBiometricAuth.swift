#if canImport(LocalAuthentication)
    import Foundation
    import LocalAuthentication

    /// Simplified biometric authentication using Face ID, Touch ID, or Optic ID.
    public struct PrismBiometricAuth: Sendable {
        public init() {}

        /// Returns the biometric type available on this device.
        public func availableType() -> PrismBiometricType {
            let context = LAContext()
            var error: NSError?
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                return .none
            }
            switch context.biometryType {
            case .touchID: return .touchID
            case .faceID: return .faceID
            case .opticID: return .opticID
            case .none: return .none
            @unknown default: return .none
            }
        }

        /// Whether biometric authentication is available.
        public func isAvailable() -> Bool {
            availableType() != .none
        }

        /// Whether the device can evaluate the given policy.
        public func canAuthenticate(policy: PrismBiometricPolicy = .biometricsOnly) -> Bool {
            let context = LAContext()
            var error: NSError?
            return context.canEvaluatePolicy(policy.laPolicy, error: &error)
        }

        /// Authenticates the user with biometrics.
        /// - Parameters:
        ///   - reason: Localized reason displayed to the user.
        ///   - policy: Authentication policy. Defaults to `.biometricsOnly`.
        /// - Returns: `true` if authentication succeeded.
        @discardableResult
        public func authenticate(
            reason: String,
            policy: PrismBiometricPolicy = .biometricsOnly
        ) async throws -> Bool {
            let context = LAContext()

            var error: NSError?
            guard context.canEvaluatePolicy(policy.laPolicy, error: &error) else {
                throw mapLAError(error)
            }

            do {
                return try await context.evaluatePolicy(policy.laPolicy, localizedReason: reason)
            } catch let error as LAError {
                throw mapLAErrorCode(error.code)
            }
        }

        /// Authenticates and returns a result instead of throwing.
        public func authenticateResult(
            reason: String,
            policy: PrismBiometricPolicy = .biometricsOnly
        ) async -> Result<Bool, PrismSecurityError> {
            do {
                let success = try await authenticate(reason: reason, policy: policy)
                return .success(success)
            } catch let error as PrismSecurityError {
                return .failure(error)
            } catch {
                return .failure(.biometricAuthenticationFailed)
            }
        }

        private func mapLAError(_ error: NSError?) -> PrismSecurityError {
            guard let laError = error as? LAError else { return .biometricNotAvailable }
            return mapLAErrorCode(laError.code)
        }

        private func mapLAErrorCode(_ code: LAError.Code) -> PrismSecurityError {
            switch code {
            case .biometryNotAvailable: .biometricNotAvailable
            case .biometryNotEnrolled: .biometricNotEnrolled
            case .biometryLockout: .biometricLockout
            case .userCancel: .biometricUserCancel
            case .systemCancel: .biometricSystemCancel
            case .authenticationFailed: .biometricAuthenticationFailed
            default: .biometricAuthenticationFailed
            }
        }
    }

    extension PrismBiometricPolicy {
        var laPolicy: LAPolicy {
            switch self {
            case .biometricsOnly: .deviceOwnerAuthenticationWithBiometrics
            case .biometricsOrPasscode: .deviceOwnerAuthentication
            }
        }
    }
#endif
