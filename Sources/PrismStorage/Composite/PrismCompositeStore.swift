import Foundation

/// Read-through/write-through composite of multiple stores (e.g. memory → disk).
/// On load: tries each store in order, populates misses upstream.
/// On save: writes to all stores.
public final class PrismCompositeStore: PrismStorageProtocol, @unchecked Sendable {
    private let stores: [PrismStorageProtocol]
    private let lock = NSLock()

    public init(stores: [PrismStorageProtocol]) {
        precondition(!stores.isEmpty, "CompositeStore requires at least one store")
        self.stores = stores
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        for store in stores {
            try store.save(value, forKey: key)
        }
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) throws -> T? {
        lock.lock()
        defer { lock.unlock() }
        for (index, store) in stores.enumerated() {
            if let value = try store.load(type, forKey: key) {
                for upstream in stores[0..<index] {
                    try? upstream.save(value, forKey: key)
                }
                return value
            }
        }
        return nil
    }

    public func delete(forKey key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        for store in stores {
            try store.delete(forKey: key)
        }
    }

    public func exists(forKey key: String) throws -> Bool {
        lock.lock()
        defer { lock.unlock() }
        for store in stores {
            if try store.exists(forKey: key) { return true }
        }
        return false
    }

    public func clear() throws {
        lock.lock()
        defer { lock.unlock() }
        for store in stores {
            try store.clear()
        }
    }

    public func keys() throws -> [String] {
        lock.lock()
        defer { lock.unlock() }
        var allKeys = Set<String>()
        for store in stores {
            let storeKeys = try store.keys()
            allKeys.formUnion(storeKeys)
        }
        return Array(allKeys)
    }
}

/// Async variant for actor-based stores.
public actor PrismCompositeAsyncStore: PrismAsyncStorageProtocol {
    private let stores: [PrismAsyncStorageProtocol]

    public init(stores: [PrismAsyncStorageProtocol]) {
        precondition(!stores.isEmpty, "CompositeStore requires at least one store")
        self.stores = stores
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) async throws {
        for store in stores {
            try await store.save(value, forKey: key)
        }
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
        for (index, store) in stores.enumerated() {
            if let value = try await store.load(type, forKey: key) {
                for upstream in stores[0..<index] {
                    try? await upstream.save(value, forKey: key)
                }
                return value
            }
        }
        return nil
    }

    public func delete(forKey key: String) async throws {
        for store in stores {
            try await store.delete(forKey: key)
        }
    }

    public func exists(forKey key: String) async throws -> Bool {
        for store in stores {
            if try await store.exists(forKey: key) { return true }
        }
        return false
    }

    public func clear() async throws {
        for store in stores {
            try await store.clear()
        }
    }

    public func keys() async throws -> [String] {
        var allKeys = Set<String>()
        for store in stores {
            let storeKeys = try await store.keys()
            allKeys.formUnion(storeKeys)
        }
        return Array(allKeys)
    }
}
