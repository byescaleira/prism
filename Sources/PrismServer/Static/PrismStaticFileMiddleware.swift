import Foundation

/// Middleware that serves static files from a directory.
public struct PrismStaticFileMiddleware: PrismMiddleware {
    private let rootDirectory: String
    private let indexFile: String
    private let enableETag: Bool
    private let enableRangeRequests: Bool

    /// Creates a new `PrismStaticFileMiddleware` with the specified configuration.
    public init(
        rootDirectory: String,
        indexFile: String = "index.html",
        enableETag: Bool = true,
        enableRangeRequests: Bool = true
    ) {
        self.rootDirectory = rootDirectory
        self.indexFile = indexFile
        self.enableETag = enableETag
        self.enableRangeRequests = enableRangeRequests
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        guard request.method == .GET || request.method == .HEAD else {
            return try await next(request)
        }

        let sanitizedPath = sanitize(path: request.path)
        var filePath = (rootDirectory as NSString).appendingPathComponent(sanitizedPath)

        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false

        guard fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory) else {
            return try await next(request)
        }

        if isDirectory.boolValue {
            filePath = (filePath as NSString).appendingPathComponent(indexFile)
            guard fileManager.fileExists(atPath: filePath) else {
                return try await next(request)
            }
        }

        guard isPathSafe(filePath, rootDirectory: rootDirectory) else {
            return PrismHTTPResponse(status: .forbidden, body: .text("Forbidden"))
        }

        guard let attributes = try? fileManager.attributesOfItem(atPath: filePath) else {
            return try await next(request)
        }

        let fileSize = (attributes[.size] as? Int) ?? 0
        let modificationDate = attributes[.modificationDate] as? Date

        var headers = PrismHTTPHeaders()
        let mimeType = PrismMIMEType.forExtension((filePath as NSString).pathExtension)
        headers.set(name: PrismHTTPHeaders.contentType, value: mimeType)

        if enableETag, let date = modificationDate {
            let etag = "\"\(Int(date.timeIntervalSince1970))-\(fileSize)\""
            headers.set(name: PrismHTTPHeaders.eTag, value: etag)

            if let ifNoneMatch = request.headers.value(for: PrismHTTPHeaders.ifNoneMatch),
                ifNoneMatch == etag
            {
                return PrismHTTPResponse(status: .notModified, headers: headers)
            }
        }

        if enableRangeRequests, let rangeHeader = request.headers.value(for: "Range") {
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
                headers.set(name: "Accept-Ranges", value: "bytes")

                return PrismHTTPResponse(
                    status: PrismHTTPStatus(code: 206, reason: "Partial Content"),
                    headers: headers,
                    body: request.method == .HEAD ? .empty : .data(data)
                )
            }
        }

        headers.set(name: "Accept-Ranges", value: "bytes")
        headers.set(name: PrismHTTPHeaders.contentLength, value: "\(fileSize)")
        headers.set(name: PrismHTTPHeaders.cacheControl, value: "public, max-age=3600")

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

    private func isPathSafe(_ filePath: String, rootDirectory: String) -> Bool {
        let resolvedRoot = (rootDirectory as NSString).standardizingPath
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
}
