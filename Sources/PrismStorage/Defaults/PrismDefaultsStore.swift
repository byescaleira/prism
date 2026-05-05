import Foundation

/// Modern UserDefaults engine with Codable, observation, and suite support.
public final class PrismDefaultsStore: PrismStorageProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let prefix: String
    private let lock = NSLock()
    private var observers: [String: NSObjectProtocol] = [:]

    public init(suite: String? = nil, prefix: String = "prism.storage.") {
        self.defaults = suite.flatMap { UserDefaults(suiteName: $0) } ?? .standard
        self.prefix = prefix
    }

    private func prefixed(_ key: String) -> String {
        "\(prefix)\(key)"
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            throw PrismStorageError.encodingFailed(key)
        }
        defaults.set(data, forKey: prefixed(key))
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = defaults.data(forKey: prefixed(key)) else { return nil }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw PrismStorageError.decodingFailed(key)
        }
    }

    public func delete(forKey key: String) throws {
        defaults.removeObject(forKey: prefixed(key))
    }

    public func exists(forKey key: String) throws -> Bool {
        defaults.object(forKey: prefixed(key)) != nil
    }

    public func clear() throws {
        let allKeys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
        for key in allKeys {
            defaults.removeObject(forKey: key)
        }
    }

    public func keys() throws -> [String] {
        defaults.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(prefix) }
            .map { String($0.dropFirst(prefix.count)) }
    }

    // MARK: - Typed Key Access

    public func get<T: Codable & Sendable>(_ key: PrismDefaultKey<T>) -> T {
        (try? load(T.self, forKey: key.name)) ?? key.defaultValue
    }

    public func set<T: Codable & Sendable>(_ key: PrismDefaultKey<T>, value: T) {
        try? save(value, forKey: key.name)
    }

    // MARK: - Observation

    public func observe<T: Codable & Sendable>(
        _ type: T.Type,
        forKey key: String
    ) -> AsyncStream<T?> {
        let pkey = prefixed(key)
        return AsyncStream { continuation in
            let observer = NotificationCenter.default.addObserver(
                forName: UserDefaults.didChangeNotification,
                object: self.defaults,
                queue: nil
            ) { [weak self] _ in
                guard let self else {
                    continuation.finish()
                    return
                }
                let value = try? self.load(type, forKey: key)
                continuation.yield(value)
            }
            self.lock.withLock { self.observers[pkey] = observer }
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                self.lock.withLock {
                    if let obs = self.observers.removeValue(forKey: pkey) {
                        NotificationCenter.default.removeObserver(obs)
                    }
                }
            }
        }
    }

    // MARK: - Batch

    public func saveBatch(_ items: [(key: String, data: any Codable & Sendable)]) throws {
        let encoder = JSONEncoder()
        for item in items {
            let data = try encoder.encode(CodableWrapper(item.data))
            defaults.set(data, forKey: prefixed(item.key))
        }
    }
}

private struct CodableWrapper: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        self._encode = { encoder in try value.encode(to: encoder) }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
