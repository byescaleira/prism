import Foundation

/// Actor that writes HTTP chunked transfer-encoded data.
public actor PrismStreamWriter {
    private var chunks: [Data] = []
    private var ended = false

    /// Creates a new `PrismStreamWriter` with the specified configuration.
    public init() {}

    /// Writes a data chunk in chunked transfer encoding format.
    public func write(_ data: Data) {
        guard !ended else { return }
        chunks.append(data)
    }

    /// Writes a string chunk.
    public func write(_ string: String) {
        write(Data(string.utf8))
    }

    /// Marks the stream as ended.
    public func end() {
        ended = true
    }

    /// Whether the stream has ended.
    public var isEnded: Bool { ended }

    /// Serializes all buffered chunks into chunked transfer encoding format.
    public func serialize() -> Data {
        var result = Data()
        for chunk in chunks {
            let sizeHex = String(chunk.count, radix: 16)
            result.append(Data("\(sizeHex)\r\n".utf8))
            result.append(chunk)
            result.append(Data("\r\n".utf8))
        }
        result.append(Data("0\r\n\r\n".utf8))
        return result
    }
}

/// Helpers for creating chunked transfer responses.
public enum PrismChunkedResponse {
    /// Creates a response configured for chunked transfer encoding.
    public static func chunked(contentType: String = "application/octet-stream") -> PrismHTTPResponse {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Transfer-Encoding", value: "chunked")
        headers.set(name: "Content-Type", value: contentType)
        return PrismHTTPResponse(status: .ok, headers: headers, body: .empty)
    }
}

/// Extension for creating responses from AsyncStream.
extension PrismHTTPResponse {
    /// Creates a response by collecting all chunks from an AsyncStream and encoding as chunked transfer.
    public static func streaming(_ stream: AsyncStream<Data>, contentType: String = "application/octet-stream") async -> PrismHTTPResponse {
        var body = Data()
        for await chunk in stream {
            let sizeHex = String(chunk.count, radix: 16)
            body.append(Data("\(sizeHex)\r\n".utf8))
            body.append(chunk)
            body.append(Data("\r\n".utf8))
        }
        body.append(Data("0\r\n\r\n".utf8))

        var headers = PrismHTTPHeaders()
        headers.set(name: "Transfer-Encoding", value: "chunked")
        headers.set(name: "Content-Type", value: contentType)
        return PrismHTTPResponse(status: .ok, headers: headers, body: .data(body))
    }
}

/// Extension for reading request body in chunks.
extension PrismHTTPRequest {
    /// Splits the request body into fixed-size chunks.
    public func bodyChunks(size: Int = 8192) -> [Data] {
        guard let body, !body.isEmpty else { return [] }
        var chunks: [Data] = []
        var offset = body.startIndex
        while offset < body.endIndex {
            let end = min(offset + size, body.endIndex)
            chunks.append(body[offset..<end])
            offset = end
        }
        return chunks
    }
}
