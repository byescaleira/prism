import Foundation

/// File-based storage engine with atomic writes, TTL, and compression support.
public actor PrismDiskStore: PrismAsyncStorageProtocol {
    public enum Directory: Sendable {
        case documents
        case caches
        case applicationSupport
        case temporary
        case custom(URL)

        var url: URL {
            switch self {
            case .documents:
                FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            case .caches:
                FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            case .applicationSupport:
                FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            case .temporary:
                FileManager.default.temporaryDirectory
            case .custom(let url):
                url
            }
        }
    }

    private let baseDirectory: URL
    private let maxSize: Int?
    private let defaultTTL: TimeInterval?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileManager: FileManager

    public init(
        directory: Directory = .applicationSupport,
        subdirectory: String = "PrismStorage",
        maxSize: Int? = nil,
        defaultTTL: TimeInterval? = nil
    ) {
        let base = directory.url.appendingPathComponent(subdirectory)
        self.baseDirectory = base
        self.maxSize = maxSize
        self.defaultTTL = defaultTTL
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.fileManager = .default

        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
    }

    private func fileURL(for key: String) -> URL {
        baseDirectory.appendingPathComponent(sanitize(key)).appendingPathExtension("json")
    }

    private func metaURL(for key: String) -> URL {
        baseDirectory.appendingPathComponent(sanitize(key)).appendingPathExtension("meta")
    }

    private func sanitize(_ key: String) -> String {
        key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
    }

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) async throws {
        let data: Data
        do {
            data = try encoder.encode(value)
        } catch {
            throw PrismStorageError.encodingFailed(key)
        }

        if let maxSize, data.count > maxSize {
            throw PrismStorageError.quotaExceeded(data.count)
        }

        let url = fileURL(for: key)
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw PrismStorageError.writeFailed(key)
        }

        if let ttl = defaultTTL {
            let meta = PrismDiskMeta(
                createdAt: .now,
                expiresAt: Date.now.addingTimeInterval(ttl),
                size: data.count
            )
            let metaData = try encoder.encode(meta)
            try? metaData.write(to: metaURL(for: key), options: .atomic)
        }
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
        let url = fileURL(for: key)
        guard fileManager.fileExists(atPath: url.path) else { return nil }

        if let meta = loadMeta(for: key), meta.isExpired {
            try? await delete(forKey: key)
            return nil
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw PrismStorageError.readFailed(key)
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw PrismStorageError.decodingFailed(key)
        }
    }

    public func delete(forKey key: String) async throws {
        let url = fileURL(for: key)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        let meta = metaURL(for: key)
        if fileManager.fileExists(atPath: meta.path) {
            try? fileManager.removeItem(at: meta)
        }
    }

    public func exists(forKey key: String) async throws -> Bool {
        let url = fileURL(for: key)
        guard fileManager.fileExists(atPath: url.path) else { return false }
        if let meta = loadMeta(for: key), meta.isExpired {
            try? await delete(forKey: key)
            return false
        }
        return true
    }

    public func clear() async throws {
        let contents = try fileManager.contentsOfDirectory(
            at: baseDirectory, includingPropertiesForKeys: nil
        )
        for url in contents {
            try? fileManager.removeItem(at: url)
        }
    }

    public func keys() async throws -> [String] {
        guard fileManager.fileExists(atPath: baseDirectory.path) else { return [] }
        let contents = try fileManager.contentsOfDirectory(
            at: baseDirectory, includingPropertiesForKeys: nil
        )
        return contents
            .filter { $0.pathExtension == "json" }
            .compactMap { $0.deletingPathExtension().lastPathComponent
                .removingPercentEncoding }
    }

    // MARK: - TTL

    public func save<T: Codable & Sendable>(
        _ value: T, forKey key: String, ttl: TimeInterval
    ) async throws {
        let data = try encoder.encode(value)
        let url = fileURL(for: key)
        try data.write(to: url, options: .atomic)

        let meta = PrismDiskMeta(
            createdAt: .now,
            expiresAt: Date.now.addingTimeInterval(ttl),
            size: data.count
        )
        let metaData = try encoder.encode(meta)
        try? metaData.write(to: metaURL(for: key), options: .atomic)
    }

    /// Removes all expired entries.
    public func pruneExpired() async throws {
        for key in try await keys() {
            if let meta = loadMeta(for: key), meta.isExpired {
                try? await delete(forKey: key)
            }
        }
    }

    /// Total bytes used on disk.
    public func totalSize() async throws -> Int {
        guard fileManager.fileExists(atPath: baseDirectory.path) else { return 0 }
        let contents = try fileManager.contentsOfDirectory(
            at: baseDirectory, includingPropertiesForKeys: [.fileSizeKey]
        )
        return contents.reduce(0) { total, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return total + size
        }
    }

    // MARK: - Private

    private func loadMeta(for key: String) -> PrismDiskMeta? {
        let url = metaURL(for: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(PrismDiskMeta.self, from: data)
    }
}

struct PrismDiskMeta: Codable, Sendable {
    let createdAt: Date
    let expiresAt: Date?
    let size: Int

    var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date.now >= expiresAt
    }
}
