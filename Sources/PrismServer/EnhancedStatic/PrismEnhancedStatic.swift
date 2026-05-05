import Foundation
import CryptoKit

/// Configuration for the enhanced static file middleware.
public struct PrismEnhancedStaticConfig: Sendable {
    /// The root directory to serve files from.
    public let rootDirectory: String
    /// The default index file served for directory requests.
    public let indexFile: String
    /// Whether ETag headers are generated for files.
    public let enableETag: Bool
    /// Whether byte-range requests are supported.
    public let enableRangeRequests: Bool
    /// Whether If-None-Match and If-Modified-Since checks are enabled.
    public let enableConditionalRequests: Bool
    /// The Cache-Control header value for served files.
    public let cacheControl: String
    /// The max-age directive value in seconds.
    public let maxAge: Int
    /// Whether ETags are computed from content hashes instead of modification time.
    public let hashBasedETag: Bool

    /// Creates an enhanced static config for the given root directory.
    public init(
        rootDirectory: String,
        indexFile: String = "index.html",
        enableETag: Bool = true,
        enableRangeRequests: Bool = true,
        enableConditionalRequests: Bool = true,
        cacheControl: String? = nil,
        maxAge: Int = 3600,
        hashBasedETag: Bool = true
    ) {
        self.rootDirectory = rootDirectory
        self.indexFile = indexFile
        self.enableETag = enableETag
        self.enableRangeRequests = enableRangeRequests
        self.enableConditionalRequests = enableConditionalRequests
        self.cacheControl = cacheControl ?? "public, max-age=\(maxAge)"
        self.maxAge = maxAge
        self.hashBasedETag = hashBasedETag
    }
}

/// Middleware that serves static files with ETag, range requests, and conditional support.
public struct PrismEnhancedStaticMiddleware: PrismMiddleware {
    private let config: PrismEnhancedStaticConfig

    /// Creates an enhanced static middleware with the given configuration.
    public init(config: PrismEnhancedStaticConfig) {
        self.config = config
    }

    /// Serves static files for GET/HEAD requests with caching, ETag, and range support.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        guard request.method == .GET || request.method == .HEAD else {
            return try await next(request)
        }

        let sanitizedPath = sanitize(path: request.path)
        var filePath = (config.rootDirectory as NSString).appendingPathComponent(sanitizedPath)
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false

        guard fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory) else {
            return try await next(request)
        }

        if isDirectory.boolValue {
            filePath = (filePath as NSString).appendingPathComponent(config.indexFile)
            guard fileManager.fileExists(atPath: filePath) else {
                return try await next(request)
            }
        }

        guard isPathSafe(filePath) else {
            return PrismHTTPResponse(status: .forbidden, body: .text("Forbidden"))
        }

        guard let attributes = try? fileManager.attributesOfItem(atPath: filePath) else {
            return try await next(request)
        }

        let fileSize = (attributes[.size] as? Int) ?? 0
        let modificationDate = attributes[.modificationDate] as? Date

        var headers = PrismHTTPHeaders()
        let ext = (filePath as NSString).pathExtension
        headers.set(name: PrismHTTPHeaders.contentType, value: PrismMIMEType.forExtension(ext))
        headers.set(name: PrismHTTPHeaders.cacheControl, value: config.cacheControl)

        if let modDate = modificationDate {
            headers.set(name: "Last-Modified", value: formatHTTPDate(modDate))
        }

        var etag: String?
        if config.enableETag {
            if config.hashBasedETag, let data = fileManager.contents(atPath: filePath) {
                let hash = SHA256.hash(data: data)
                etag = "\"\(hash.compactMap { String(format: "%02x", $0) }.joined().prefix(16))\""
            } else if let date = modificationDate {
                etag = "\"\(Int(date.timeIntervalSince1970))-\(fileSize)\""
            }
            if let etag = etag {
                headers.set(name: PrismHTTPHeaders.eTag, value: etag)
            }
        }

        if config.enableConditionalRequests {
            if let ifNoneMatch = request.headers.value(for: PrismHTTPHeaders.ifNoneMatch),
               let etag = etag, ifNoneMatch == etag {
                return PrismHTTPResponse(status: .notModified, headers: headers)
            }

            if let ifModifiedSince = request.headers.value(for: "If-Modified-Since"),
               let modDate = modificationDate {
                if let sinceDate = parseHTTPDate(ifModifiedSince) {
                    if modDate <= sinceDate {
                        return PrismHTTPResponse(status: .notModified, headers: headers)
                    }
                }
            }
        }

        if config.enableRangeRequests {
            headers.set(name: "Accept-Ranges", value: "bytes")

            if let rangeHeader = request.headers.value(for: "Range") {
                if let range = parseRange(rangeHeader, fileSize: fileSize) {
                    guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
                        return PrismHTTPResponse(status: .internalServerError)
                    }
                    defer { fileHandle.closeFile() }

                    fileHandle.seek(toFileOffset: UInt64(range.lowerBound))
                    let length = range.upperBound - range.lowerBound + 1
                    let data = fileHandle.readData(ofLength: length)

                    headers.set(name: PrismHTTPHeaders.contentLength, value: "\(data.count)")
                    headers.set(name: "Content-Range", value: "bytes \(range.lowerBound)-\(range.upperBound)/\(fileSize)")

                    return PrismHTTPResponse(
                        status: .partialContent,
                        headers: headers,
                        body: request.method == .HEAD ? .empty : .data(data)
                    )
                } else {
                    headers.set(name: "Content-Range", value: "bytes */\(fileSize)")
                    return PrismHTTPResponse(status: .rangeNotSatisfiable, headers: headers)
                }
            }
        }

        headers.set(name: PrismHTTPHeaders.contentLength, value: "\(fileSize)")

        if request.method == .HEAD {
            return PrismHTTPResponse(status: .ok, headers: headers)
        }

        guard let data = fileManager.contents(atPath: filePath) else {
            return PrismHTTPResponse(status: .internalServerError)
        }

        return PrismHTTPResponse(status: .ok, headers: headers, body: .data(data))
    }

    private func sanitize(path: String) -> String {
        let components = path.split(separator: "/").filter { $0 != ".." && $0 != "." }
        return components.joined(separator: "/")
    }

    private func isPathSafe(_ filePath: String) -> Bool {
        let resolvedRoot = (config.rootDirectory as NSString).standardizingPath
        let resolvedFile = (filePath as NSString).standardizingPath
        return resolvedFile.hasPrefix(resolvedRoot)
    }

    private func parseRange(_ header: String, fileSize: Int) -> ClosedRange<Int>? {
        guard header.hasPrefix("bytes=") else { return nil }
        let rangeStr = String(header.dropFirst("bytes=".count))
        let parts = rangeStr.split(separator: "-", maxSplits: 1)

        if parts.count == 2 {
            if let start = Int(parts[0]), let end = Int(parts[1]) {
                guard start <= end && start < fileSize else { return nil }
                return start...min(end, fileSize - 1)
            } else if parts[0].isEmpty, let suffix = Int(parts[1]) {
                let start = max(0, fileSize - suffix)
                return start...(fileSize - 1)
            } else if let start = Int(parts[0]), parts[1].isEmpty {
                guard start < fileSize else { return nil }
                return start...(fileSize - 1)
            }
        }
        return nil
    }

    private func formatHTTPDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        return formatter.string(from: date)
    }

    private func parseHTTPDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        return formatter.date(from: string)
    }
}
