import Foundation

/// A single part from a multipart/form-data request.
public struct PrismMultipartPart: Sendable {
    /// The field name from Content-Disposition.
    public let name: String
    /// The original filename, if this part is a file upload.
    public let filename: String?
    /// The Content-Type of this part.
    public let contentType: String?
    /// The raw data of this part.
    public let data: Data

    /// Creates a multipart part with the given field name, optional filename, content type, and data.
    public init(name: String, filename: String? = nil, contentType: String? = nil, data: Data) {
        self.name = name
        self.filename = filename
        self.contentType = contentType
        self.data = data
    }

    /// Returns the part data as a UTF-8 string.
    public var stringValue: String? {
        String(data: data, encoding: .utf8)
    }
}

/// Parser for multipart/form-data request bodies.
public struct PrismMultipartParser: Sendable {

    /// Creates a multipart parser.
    public init() {}

    /// Extracts the boundary string from a Content-Type header.
    public func extractBoundary(from contentType: String) -> String? {
        let parts = contentType.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        for part in parts {
            if part.lowercased().hasPrefix("boundary=") {
                var boundary = String(part.dropFirst("boundary=".count))
                if boundary.hasPrefix("\"") && boundary.hasSuffix("\"") {
                    boundary = String(boundary.dropFirst().dropLast())
                }
                return boundary
            }
        }
        return nil
    }

    /// Parses multipart/form-data body into individual parts.
    public func parse(data: Data, boundary: String) throws -> [PrismMultipartPart] {
        let boundaryData = Data("--\(boundary)".utf8)
        let endBoundaryData = Data("--\(boundary)--".utf8)
        let crlf = Data("\r\n".utf8)
        let doubleCRLF = Data("\r\n\r\n".utf8)

        var parts: [PrismMultipartPart] = []
        var searchStart = data.startIndex

        guard let firstBoundary = data.range(of: boundaryData, in: searchStart..<data.endIndex) else {
            throw PrismContentError.multipartParsingFailed
        }
        searchStart = firstBoundary.upperBound

        while searchStart < data.endIndex {
            if data[searchStart..<min(searchStart + crlf.count, data.endIndex)] == crlf {
                searchStart += crlf.count
            }

            if searchStart + endBoundaryData.count <= data.endIndex {
                let checkEnd = data[searchStart..<searchStart + 2]
                if checkEnd == Data("--".utf8) { break }
            }

            guard let headerEnd = data.range(of: doubleCRLF, in: searchStart..<data.endIndex) else { break }

            let headerData = data[searchStart..<headerEnd.lowerBound]
            guard let headerString = String(data: headerData, encoding: .utf8) else { break }

            let bodyStart = headerEnd.upperBound
            let nextBoundary = data.range(of: boundaryData, in: bodyStart..<data.endIndex)
            let bodyEnd: Int
            if let next = nextBoundary {
                bodyEnd = next.lowerBound - crlf.count
            } else {
                bodyEnd = data.endIndex
            }

            let partData = data[bodyStart..<max(bodyStart, bodyEnd)]

            if let part = parsePart(headers: headerString, data: Data(partData)) {
                parts.append(part)
            }

            if let next = nextBoundary {
                searchStart = next.upperBound
            } else {
                break
            }
        }

        return parts
    }

    private func parsePart(headers: String, data: Data) -> PrismMultipartPart? {
        var name: String?
        var filename: String?
        var contentType: String?

        for line in headers.split(separator: "\r\n") {
            let lineStr = String(line)
            if lineStr.lowercased().hasPrefix("content-disposition:") {
                let params = lineStr.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
                for param in params {
                    if param.lowercased().hasPrefix("name=") {
                        name = extractQuotedValue(param)
                    } else if param.lowercased().hasPrefix("filename=") {
                        filename = extractQuotedValue(param)
                    }
                }
            } else if lineStr.lowercased().hasPrefix("content-type:") {
                contentType = String(lineStr.dropFirst("content-type:".count)).trimmingCharacters(in: .whitespaces)
            }
        }

        guard let name else { return nil }

        return PrismMultipartPart(name: name, filename: filename, contentType: contentType, data: data)
    }

    private func extractQuotedValue(_ param: String) -> String {
        let parts = param.split(separator: "=", maxSplits: 1)
        guard parts.count == 2 else { return "" }
        var value = String(parts[1]).trimmingCharacters(in: .whitespaces)
        if value.hasPrefix("\"") && value.hasSuffix("\"") {
            value = String(value.dropFirst().dropLast())
        }
        return value
    }
}

extension PrismHTTPRequest {
    /// Parses the request body as multipart/form-data.
    public func multipartParts() throws -> [PrismMultipartPart] {
        guard let contentType = headers.value(for: PrismHTTPHeaders.contentType),
              contentType.lowercased().contains("multipart/form-data") else {
            throw PrismContentError.unsupportedContentType(headers.value(for: PrismHTTPHeaders.contentType) ?? "none")
        }

        let parser = PrismMultipartParser()
        guard let boundary = parser.extractBoundary(from: contentType) else {
            throw PrismContentError.multipartBoundaryMissing
        }

        guard let body else {
            throw PrismContentError.emptyBody
        }

        return try parser.parse(data: body, boundary: boundary)
    }
}
