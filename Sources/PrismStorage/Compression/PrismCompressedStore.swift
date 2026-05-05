import Foundation

/// Transparent compression wrapper — compresses values before delegating to an inner store.
public final class PrismCompressedStore: PrismStorageProtocol, @unchecked Sendable {
    private let inner: PrismStorageProtocol
    private let algorithm: NSData.CompressionAlgorithm
    private let lock = NSLock()

    public init(
        wrapping store: PrismStorageProtocol,
        algorithm: NSData.CompressionAlgorithm = .lzfse
    ) {
        self.inner = store
        self.algorithm = algorithm
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            throw PrismStorageError.encodingFailed(key)
        }
        let compressed = try compress(data)
        lock.lock()
        defer { lock.unlock() }
        try inner.save(compressed, forKey: key)
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) throws -> T? {
        lock.lock()
        let compressed: Data? = try inner.load(Data.self, forKey: key)
        lock.unlock()

        guard let compressed else { return nil }
        let data = try decompress(compressed)
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw PrismStorageError.decodingFailed(key)
        }
    }

    public func delete(forKey key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        try inner.delete(forKey: key)
    }

    public func exists(forKey key: String) throws -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return try inner.exists(forKey: key)
    }

    public func clear() throws {
        lock.lock()
        defer { lock.unlock() }
        try inner.clear()
    }

    public func keys() throws -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return try inner.keys()
    }

    private func compress(_ data: Data) throws -> Data {
        let nsData = data as NSData
        guard let compressed = try? nsData.compressed(using: algorithm) else {
            throw PrismStorageError.compressionFailed
        }
        return compressed as Data
    }

    private func decompress(_ data: Data) throws -> Data {
        let nsData = data as NSData
        guard let decompressed = try? nsData.decompressed(using: algorithm) else {
            throw PrismStorageError.decompressionFailed
        }
        return decompressed as Data
    }
}

/// Async variant wrapping an async store.
public actor PrismCompressedAsyncStore: PrismAsyncStorageProtocol {
    private let inner: PrismAsyncStorageProtocol
    private let algorithm: NSData.CompressionAlgorithm

    public init(
        wrapping store: PrismAsyncStorageProtocol,
        algorithm: NSData.CompressionAlgorithm = .lzfse
    ) {
        self.inner = store
        self.algorithm = algorithm
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(value)
        let compressed = try compress(data)
        try await inner.save(compressed, forKey: key)
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
        guard let compressed: Data = try await inner.load(Data.self, forKey: key) else { return nil }
        let data = try decompress(compressed)
        return try JSONDecoder().decode(type, from: data)
    }

    public func delete(forKey key: String) async throws {
        try await inner.delete(forKey: key)
    }

    public func exists(forKey key: String) async throws -> Bool {
        try await inner.exists(forKey: key)
    }

    public func clear() async throws {
        try await inner.clear()
    }

    public func keys() async throws -> [String] {
        try await inner.keys()
    }

    private func compress(_ data: Data) throws -> Data {
        let nsData = data as NSData
        guard let compressed = try? nsData.compressed(using: algorithm) else {
            throw PrismStorageError.compressionFailed
        }
        return compressed as Data
    }

    private func decompress(_ data: Data) throws -> Data {
        let nsData = data as NSData
        guard let decompressed = try? nsData.decompressed(using: algorithm) else {
            throw PrismStorageError.decompressionFailed
        }
        return decompressed as Data
    }
}
