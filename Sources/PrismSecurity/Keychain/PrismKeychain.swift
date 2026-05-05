import Foundation
import Security

/// Full-featured keychain wrapper for storing, retrieving, and managing sensitive data.
public struct PrismKeychain: Sendable {
    private let defaultService: String

    /// Creates a keychain instance with a default service identifier.
    public init(service: String = "PrismSecurity") {
        self.defaultService = service
    }

    // MARK: - Data Operations

    /// Saves raw data to the keychain.
    public func save(data: Data, for item: PrismKeychainItem) throws {
        var query = baseQuery(for: item)

        if let accessControl = createAccessControl(item.accessControl) {
            query[kSecAttrAccessControl as String] = accessControl
        } else {
            query[kSecAttrAccessible as String] = item.accessControl.accessibility.cfValue
        }

        query[kSecValueData as String] = data

        let deleteStatus = SecItemDelete(query as CFDictionary)
        if deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound {
            throw PrismSecurityError.keychainOperationFailed(status: deleteStatus)
        }

        let addStatus = SecItemAdd(query as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw mapKeychainError(addStatus)
        }
    }

    /// Retrieves raw data from the keychain.
    public func load(for item: PrismKeychainItem) throws -> Data {
        var query = baseQuery(for: item)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw mapKeychainError(status)
        }

        guard let data = result as? Data else {
            throw PrismSecurityError.keychainDataConversionFailed
        }

        return data
    }

    /// Deletes an item from the keychain.
    public func delete(for item: PrismKeychainItem) throws {
        let query = baseQuery(for: item)
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw mapKeychainError(status)
        }
    }

    /// Whether an item exists in the keychain.
    public func exists(for item: PrismKeychainItem) -> Bool {
        var query = baseQuery(for: item)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue

        var result: AnyObject?
        return SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess
    }

    // MARK: - Codable Operations

    /// Saves a Codable value to the keychain.
    public func save<T: Codable & Sendable>(_ value: T, for item: PrismKeychainItem) throws {
        let data = try JSONEncoder().encode(value)
        try save(data: data, for: item)
    }

    /// Loads a Codable value from the keychain.
    public func load<T: Codable & Sendable>(_ type: T.Type, for item: PrismKeychainItem) throws -> T {
        let data = try load(for: item)
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw PrismSecurityError.keychainDataConversionFailed
        }
    }

    // MARK: - String Operations

    /// Saves a string value to the keychain.
    public func save(string: String, for item: PrismKeychainItem) throws {
        guard let data = string.data(using: .utf8) else {
            throw PrismSecurityError.keychainDataConversionFailed
        }
        try save(data: data, for: item)
    }

    /// Loads a string value from the keychain.
    public func loadString(for item: PrismKeychainItem) throws -> String {
        let data = try load(for: item)
        guard let string = String(data: data, encoding: .utf8) else {
            throw PrismSecurityError.keychainDataConversionFailed
        }
        return string
    }

    // MARK: - Bulk Operations

    /// Deletes all items for the default service.
    public func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: defaultService,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw mapKeychainError(status)
        }
    }

    // MARK: - Private

    private func baseQuery(for item: PrismKeychainItem) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: item.service,
            kSecAttrAccount as String: item.id,
        ]

        if let accessGroup = item.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        if item.synchronizable {
            query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }

        return query
    }

    private func createAccessControl(
        _ control: PrismKeychainAccessControl
    ) -> SecAccessControl? {
        guard !control.flags.isEmpty else { return nil }
        return SecAccessControlCreateWithFlags(
            nil,
            control.accessibility.cfValue,
            control.flags,
            nil
        )
    }

    private func mapKeychainError(_ status: OSStatus) -> PrismSecurityError {
        switch status {
        case errSecItemNotFound: .keychainItemNotFound
        case errSecDuplicateItem: .keychainDuplicateItem
        case errSecAuthFailed, errSecInteractionNotAllowed: .keychainAccessDenied
        default: .keychainOperationFailed(status: status)
        }
    }
}
