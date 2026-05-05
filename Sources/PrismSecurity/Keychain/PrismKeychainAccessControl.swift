import Foundation
import Security

/// Access control options for keychain items.
public struct PrismKeychainAccessControl: Sendable {
    /// The underlying SecAccessControlCreateFlags.
    public let flags: SecAccessControlCreateFlags
    /// Accessibility level for the keychain item.
    public let accessibility: PrismKeychainAccessibility

    /// Default — accessible when device is unlocked, no biometric required.
    public static let `default` = PrismKeychainAccessControl(
        flags: [],
        accessibility: .whenUnlocked
    )

    /// Requires biometric authentication to access.
    public static let biometricAny = PrismKeychainAccessControl(
        flags: .biometryAny,
        accessibility: .whenPasscodeSet
    )

    /// Requires current biometric enrollment (re-enrollment invalidates access).
    public static let biometricCurrentSet = PrismKeychainAccessControl(
        flags: .biometryCurrentSet,
        accessibility: .whenPasscodeSet
    )

    /// Requires device passcode.
    public static let devicePasscode = PrismKeychainAccessControl(
        flags: .devicePasscode,
        accessibility: .whenPasscodeSet
    )

    /// Requires biometric or device passcode.
    public static let biometricOrPasscode = PrismKeychainAccessControl(
        flags: [.biometryAny, .or, .devicePasscode],
        accessibility: .whenPasscodeSet
    )

    public init(flags: SecAccessControlCreateFlags, accessibility: PrismKeychainAccessibility) {
        self.flags = flags
        self.accessibility = accessibility
    }
}

/// When a keychain item is accessible.
public enum PrismKeychainAccessibility: Sendable, Hashable {
    case whenUnlocked
    case afterFirstUnlock
    case whenPasscodeSet

    var cfValue: CFString {
        switch self {
        case .whenUnlocked: kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock
        case .whenPasscodeSet: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
