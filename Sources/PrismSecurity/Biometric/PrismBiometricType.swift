import Foundation

/// Biometric authentication type available on device.
public enum PrismBiometricType: String, Sendable, Hashable, CaseIterable {
    case none
    case touchID
    case faceID
    case opticID

    /// Human-readable display name.
    public var displayName: String {
        switch self {
        case .none: "None"
        case .touchID: "Touch ID"
        case .faceID: "Face ID"
        case .opticID: "Optic ID"
        }
    }
}

/// Policy for biometric authentication evaluation.
public enum PrismBiometricPolicy: Sendable, Hashable {
    case biometricsOnly
    case biometricsOrPasscode

    /// Whether device passcode is accepted as fallback.
    public var allowsPasscodeFallback: Bool {
        self == .biometricsOrPasscode
    }
}
