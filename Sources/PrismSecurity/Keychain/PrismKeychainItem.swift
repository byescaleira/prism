import Foundation

/// A typed keychain item descriptor.
public struct PrismKeychainItem: Sendable, Identifiable {
    /// Unique key for the keychain item.
    public let id: String
    /// Service identifier (groups related items).
    public let service: String
    /// Optional access group for shared keychain access.
    public let accessGroup: String?
    /// Access control options.
    public let accessControl: PrismKeychainAccessControl
    /// Whether the item should sync via iCloud Keychain.
    public let synchronizable: Bool

    public init(
        id: String,
        service: String = "PrismSecurity",
        accessGroup: String? = nil,
        accessControl: PrismKeychainAccessControl = .default,
        synchronizable: Bool = false
    ) {
        self.id = id
        self.service = service
        self.accessGroup = accessGroup
        self.accessControl = accessControl
        self.synchronizable = synchronizable
    }
}
