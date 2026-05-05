#if canImport(LocalAuthentication)
    import LocalAuthentication

    // MARK: - Biometric Type

    /// The type of biometric authentication available on the current device.
    ///
    /// Maps to `LABiometryType` from the LocalAuthentication framework.
    /// Use `PrismBiometricClient.availableBiometricType()` to query the device.
    public enum PrismBiometricType: Sendable, CaseIterable {
        /// No biometric authentication is available.
        case none
        /// Touch ID (fingerprint) is available.
        case touchID
        /// Face ID (facial recognition) is available.
        case faceID
        /// Optic ID (iris recognition) is available — Apple Vision Pro.
        case opticID
    }

    // MARK: - Biometric Policy

    /// The authentication policy to evaluate.
    ///
    /// - `deviceOwnerAuthenticationWithBiometrics`: Biometrics only (Touch ID, Face ID, or Optic ID).
    /// - `deviceOwnerAuthentication`: Biometrics with passcode fallback.
    public enum PrismBiometricPolicy: Sendable, CaseIterable {
        /// Authenticate using biometrics only. Falls back to nothing if biometrics fail.
        case deviceOwnerAuthenticationWithBiometrics
        /// Authenticate using biometrics with device passcode as fallback.
        case deviceOwnerAuthentication
    }

    // MARK: - Biometric Error

    /// Errors that can occur during biometric authentication.
    ///
    /// Maps to common `LAError` codes for a simplified, Prism-native API surface.
    public enum PrismBiometricError: Sendable, CaseIterable {
        /// Authentication was not successful because the user failed to provide valid credentials.
        case authenticationFailed
        /// The user tapped the Cancel button in the authentication dialog.
        case userCancel
        /// The user tapped the fallback button in the authentication dialog.
        case userFallback
        /// The system canceled authentication (e.g., another app came to the foreground).
        case systemCancel
        /// A passcode is not set on the device.
        case passcodeNotSet
        /// Biometry is not available on the device.
        case biometryNotAvailable
        /// The user has not enrolled in biometric authentication.
        case biometryNotEnrolled
        /// Biometry is locked because there were too many failed attempts.
        case biometryLockout
    }

    // MARK: - Biometric Result

    /// The result of a biometric authentication attempt.
    ///
    /// Contains whether authentication succeeded and an optional error describing the failure reason.
    ///
    /// ```swift
    /// let client = PrismBiometricClient()
    /// let result = await client.authenticate(reason: "Unlock your vault", policy: .deviceOwnerAuthenticationWithBiometrics)
    /// if result.success {
    ///     // proceed
    /// } else if let error = result.error {
    ///     // handle error
    /// }
    /// ```
    public struct PrismBiometricResult: Sendable {
        /// Whether the authentication attempt was successful.
        public let success: Bool
        /// The error that occurred during authentication, if any.
        public let error: PrismBiometricError?

        /// Creates a new biometric result with the given success status and optional error.
        public init(success: Bool, error: PrismBiometricError? = nil) {
            self.success = success
            self.error = error
        }
    }

    // MARK: - Biometric Client

    /// Client that wraps LocalAuthentication for biometric (Touch ID / Face ID / Optic ID) evaluation.
    ///
    /// Provides a simplified, `Sendable`-safe API over `LAContext` for querying device capabilities
    /// and performing biometric authentication.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let client = PrismBiometricClient()
    ///
    /// // Check available biometric type
    /// let biometricType = client.availableBiometricType()
    ///
    /// // Evaluate policy feasibility
    /// let canUse = client.canEvaluate(policy: .deviceOwnerAuthenticationWithBiometrics)
    ///
    /// // Authenticate
    /// let result = await client.authenticate(
    ///     reason: "Access your secure data",
    ///     policy: .deviceOwnerAuthenticationWithBiometrics
    /// )
    /// ```
    public final class PrismBiometricClient: Sendable {

        /// Creates a new biometric authentication client.
        public init() {}

        /// Returns the biometric type available on the current device.
        ///
        /// Internally creates a fresh `LAContext` and queries its `biometryType`
        /// after evaluating policy feasibility.
        public func availableBiometricType() -> PrismBiometricType {
            let context = LAContext()
            var error: NSError?
            _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            return context.biometryType.toPrism
        }

        /// Checks whether the given policy can be evaluated on this device.
        ///
        /// - Parameter policy: The authentication policy to check.
        /// - Returns: `true` if the policy can be evaluated, `false` otherwise.
        public func canEvaluate(policy: PrismBiometricPolicy) -> Bool {
            let context = LAContext()
            var error: NSError?
            return context.canEvaluatePolicy(policy.toLAPolicy, error: &error)
        }

        /// Performs biometric authentication with the specified reason and policy.
        ///
        /// - Parameters:
        ///   - reason: A localized string explaining why authentication is needed.
        ///   - policy: The authentication policy to use.
        /// - Returns: A `PrismBiometricResult` indicating success or failure with an error.
        public func authenticate(reason: String, policy: PrismBiometricPolicy) async -> PrismBiometricResult {
            let context = LAContext()
            do {
                let success = try await context.evaluatePolicy(policy.toLAPolicy, localizedReason: reason)
                return PrismBiometricResult(success: success)
            } catch let error as LAError {
                return PrismBiometricResult(success: false, error: error.toPrism)
            } catch {
                return PrismBiometricResult(success: false, error: .authenticationFailed)
            }
        }
    }

    // MARK: - Internal Mapping

    extension LABiometryType {
        /// Converts the system `LABiometryType` to the Prism domain type.
        var toPrism: PrismBiometricType {
            switch self {
            case .none: .none
            case .touchID: .touchID
            case .faceID: .faceID
            case .opticID: .opticID
            @unknown default: .none
            }
        }
    }

    extension PrismBiometricPolicy {
        /// Converts the Prism policy to the system `LAPolicy`.
        var toLAPolicy: LAPolicy {
            switch self {
            case .deviceOwnerAuthenticationWithBiometrics: .deviceOwnerAuthenticationWithBiometrics
            case .deviceOwnerAuthentication: .deviceOwnerAuthentication
            }
        }
    }

    extension LAError {
        /// Converts a system `LAError` to the Prism domain error.
        var toPrism: PrismBiometricError {
            switch self.code {
            case .authenticationFailed: .authenticationFailed
            case .userCancel: .userCancel
            case .userFallback: .userFallback
            case .systemCancel: .systemCancel
            case .passcodeNotSet: .passcodeNotSet
            case .biometryNotAvailable: .biometryNotAvailable
            case .biometryNotEnrolled: .biometryNotEnrolled
            case .biometryLockout: .biometryLockout
            @unknown default: .authenticationFailed
            }
        }
    }
#endif
