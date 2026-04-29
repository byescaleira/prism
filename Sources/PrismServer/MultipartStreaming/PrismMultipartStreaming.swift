import Foundation

public struct PrismStreamingPart: Sendable {
    public let name: String
    public let filename: String?
    public let contentType: String?
    public let headers: [String: String]
    public let data: Data

    public init(name: String, filename: String? = nil, contentType: String? = nil, headers: [String: String] = [:], data: Data) {
        self.name = name
        self.filename = filename
        self.contentType = contentType
        self.headers = headers
        self.data = data
    }
}

public struct PrismMultipartProgress: Sendable {
    public let bytesProcessed: Int
    public let totalBytes: Int?
    public let partsCompleted: Int

    public var fraction: Double? {
        guard let total = totalBytes, total > 0 else { return nil }
        return Double(bytesProcessed) / Double(total)
    }
}

public struct PrismMultipartStreamParser: Sendable {
    private let boundary: String
    private let maxPartSize: Int
    private let maxParts: Int

    public init(boundary: String, maxPartSize: Int = 10 * 1024 * 1024, maxParts: Int = 100) {
        self.boundary = boundary
        self.maxPartSize = maxPartSize
        self.maxParts = maxParts
    }

    public static func extractBoundary(from contentType: String) -> String? {
        let parts = contentType.split(separator: ";")
        for part in parts {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            if trimmed.lowercased().hasPrefix("boundary=") {
                var boundary = String(trimmed.dropFirst("boundary=".count))
                if boundary.hasPrefix("\"") && boundary.hasSuffix("\"") {
                    boundary = String(boundary.dropFirst().dropLast())
                }
                return boundary
            }
        }
        return nil
    }

    public func parse(_ data: Data, onProgress: (@Sendable (PrismMultipartProgress) -> Void)? = nil) throws -> [PrismStreamingPart] {
        let delimiter = Data("--\(boundary)".utf8)
        let crlf = Data("\r\n".utf8)
        let doubleCrlf = Data("\r\n\r\n".utf8)

        var parts: [PrismStreamingPart] = []
        var position = 0
        let totalBytes = data.count

        guard let firstBoundaryRange = data.range(of: delimiter) else {
            return []
        }
        position = firstBoundaryRange.upperBound

        while position < totalBytes {
            if data[position..<min(position + crlf.count, totalBytes)] == crlf {
                position += crlf.count
            }

            if position + 2 <= totalBytes {
                let check = data[position..<min(position + 2, totalBytes)]
                if check == Data("--".utf8) {
                    break
                }
            }

            guard let nextBoundary = data.range(of: delimiter, options: [], in: position..<totalBytes) else {
                break
            }

            let partData = data[position..<nextBoundary.lowerBound]

            guard let headerEnd = partData.range(of: doubleCrlf) else {
                position = nextBoundary.upperBound
                continue
            }

            let headerData = partData[partData.startIndex..<headerEnd.lowerBound]
            let bodyData: Data
            let bodyStart = headerEnd.upperBound
            let bodyEnd = nextBoundary.lowerBound - crlf.count
            if bodyStart <= bodyEnd {
                bodyData = Data(partData[bodyStart..<bodyEnd])
            } else {
                bodyData = Data()
            }

            guard bodyData.count <= maxPartSize else {
                throw PrismMultipartStreamError.partTooLarge(maxSize: maxPartSize)
            }

            let headers = parsePartHeaders(headerData)
            let disposition = headers["content-disposition"] ?? ""
            let name = extractField(from: disposition, field: "name") ?? ""
            let filename = extractField(from: disposition, field: "filename")
            let contentType = headers["content-type"]

            parts.append(PrismStreamingPart(
                name: name,
                filename: filename,
                contentType: contentType,
                headers: headers,
                data: bodyData
            ))

            guard parts.count <= maxParts else {
                throw PrismMultipartStreamError.tooManyParts(maxParts: maxParts)
            }

            onProgress?(PrismMultipartProgress(
                bytesProcessed: nextBoundary.upperBound,
                totalBytes: totalBytes,
                partsCompleted: parts.count
            ))

            position = nextBoundary.upperBound
        }

        return parts
    }

    public func parseAsync(_ data: Data) -> AsyncStream<PrismStreamingPart> {
        AsyncStream { continuation in
            do {
                let parts = try parse(data)
                for part in parts {
                    continuation.yield(part)
                }
            } catch {
                // Stream ends on error
            }
            continuation.finish()
        }
    }

    private func parsePartHeaders(_ data: Data) -> [String: String] {
        guard let headerString = String(data: Data(data), encoding: .utf8) else { return [:] }
        var headers: [String: String] = [:]
        for line in headerString.split(separator: "\r\n") {
            let parts = line.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces).lowercased()
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                headers[key] = value
            }
        }
        return headers
    }

    private func extractField(from value: String, field: String) -> String? {
        let pattern = field + "=\""
        guard let start = value.range(of: pattern) else { return nil }
        let rest = value[start.upperBound...]
        guard let end = rest.firstIndex(of: "\"") else { return nil }
        return String(rest[..<end])
    }
}

public enum PrismMultipartStreamError: Error, Sendable {
    case partTooLarge(maxSize: Int)
    case tooManyParts(maxParts: Int)
    case invalidBoundary
    case malformedPart
}

public struct PrismMultipartStreamMiddleware: PrismMiddleware {
    private let maxPartSize: Int
    private let maxParts: Int

    public init(maxPartSize: Int = 10 * 1024 * 1024, maxParts: Int = 100) {
        self.maxPartSize = maxPartSize
        self.maxParts = maxParts
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        guard let contentType = request.contentType,
              contentType.lowercased().contains("multipart/form-data"),
              let boundary = PrismMultipartStreamParser.extractBoundary(from: contentType),
              let body = request.body else {
            return try await next(request)
        }

        let parser = PrismMultipartStreamParser(boundary: boundary, maxPartSize: maxPartSize, maxParts: maxParts)
        let parts = try parser.parse(body)

        var req = request
        for (index, part) in parts.enumerated() {
            req.userInfo["multipart.\(index).name"] = part.name
            if let filename = part.filename {
                req.userInfo["multipart.\(index).filename"] = filename
            }
            if let ct = part.contentType {
                req.userInfo["multipart.\(index).contentType"] = ct
            }
            req.userInfo["multipart.\(index).size"] = "\(part.data.count)"
        }
        req.userInfo["multipart.count"] = "\(parts.count)"

        return try await next(req)
    }
}
