import Foundation

/// RFC 7230 compliant HTTP/1.1 request parser.
public struct PrismHTTPParser: Sendable {

    /// Errors that can occur during HTTP parsing.
    public enum ParserError: Error, Sendable {
        /// The data does not contain a complete HTTP request.
        case incompleteRequest
        /// The request line is malformed.
        case invalidRequestLine
        /// The HTTP method is not recognized.
        case invalidMethod
        /// A header line is malformed.
        case invalidHeader
        /// The request body exceeds the maximum allowed size.
        case bodyTooLarge
    }

    /// Maximum allowed body size in bytes. Default 10 MB.
    public let maxBodySize: Int

    /// Creates an HTTP parser with the given maximum body size.
    public init(maxBodySize: Int = 10_485_760) {
        self.maxBodySize = maxBodySize
    }

    /// Attempts to parse a complete HTTP/1.1 request from raw data.
    /// Returns the parsed request and the number of bytes consumed.
    public func parse(_ data: Data) throws -> (PrismHTTPRequest, Int) {
        guard let headerEnd = findHeaderEnd(in: data) else {
            throw ParserError.incompleteRequest
        }

        let headerData = data[data.startIndex..<headerEnd]
        guard let headerString = String(data: headerData, encoding: .utf8) else {
            throw ParserError.invalidRequestLine
        }

        let lines = headerString.split(separator: "\r\n", omittingEmptySubsequences: false)
        guard !lines.isEmpty else {
            throw ParserError.invalidRequestLine
        }

        let (method, uri, version) = try parseRequestLine(String(lines[0]))

        var headers = PrismHTTPHeaders()
        for i in 1..<lines.count {
            let line = lines[i]
            if line.isEmpty { break }
            guard let colonIndex = line.firstIndex(of: ":") else {
                throw ParserError.invalidHeader
            }
            let name = String(line[line.startIndex..<colonIndex]).trimmingCharacters(in: .whitespaces)
            let value = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
            headers.add(name: name, value: value)
        }

        let bodyStart = headerEnd + 4  // skip \r\n\r\n
        var body: Data?
        var totalConsumed = bodyStart

        if let contentLengthStr = headers.value(for: PrismHTTPHeaders.contentLength),
            let contentLength = Int(contentLengthStr)
        {
            guard contentLength <= maxBodySize else {
                throw ParserError.bodyTooLarge
            }
            let bodyEnd = bodyStart + contentLength
            guard data.count >= bodyEnd else {
                throw ParserError.incompleteRequest
            }
            body = data[bodyStart..<bodyEnd]
            totalConsumed = bodyEnd
        }

        let request = PrismHTTPRequest(
            method: method,
            uri: uri,
            version: version,
            headers: headers,
            body: body
        )

        return (request, totalConsumed)
    }

    // MARK: - Private

    private func findHeaderEnd(in data: Data) -> Int? {
        let separator: [UInt8] = [0x0D, 0x0A, 0x0D, 0x0A]  // \r\n\r\n
        guard data.count >= 4 else { return nil }
        for i in 0...(data.count - 4) {
            if data[data.startIndex + i] == separator[0]
                && data[data.startIndex + i + 1] == separator[1]
                && data[data.startIndex + i + 2] == separator[2]
                && data[data.startIndex + i + 3] == separator[3]
            {
                return data.startIndex + i
            }
        }
        return nil
    }

    private func parseRequestLine(_ line: String) throws -> (PrismHTTPMethod, String, String) {
        let parts = line.split(separator: " ", maxSplits: 2)
        guard parts.count == 3 else {
            throw ParserError.invalidRequestLine
        }
        guard let method = PrismHTTPMethod(rawValue: String(parts[0])) else {
            throw ParserError.invalidMethod
        }
        return (method, String(parts[1]), String(parts[2]))
    }
}
