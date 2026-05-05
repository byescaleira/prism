import Compression
import Foundation

/// Gzip/deflate compression middleware using Apple's built-in compression.
public struct PrismCompressionMiddleware: PrismMiddleware {
    private let minimumSize: Int

    /// Creates a new `PrismCompressionMiddleware` with the specified configuration.
    public init(minimumSize: Int = 1024) {
        self.minimumSize = minimumSize
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        var response = try await next(request)

        let acceptEncoding = request.headers.value(for: "Accept-Encoding") ?? ""
        let bodyData = response.body.data

        guard bodyData.count >= minimumSize else { return response }

        if acceptEncoding.contains("gzip") {
            if let compressed = compress(bodyData, using: COMPRESSION_ZLIB) {
                response.body = .data(compressed)
                response.headers.set(name: "Content-Encoding", value: "deflate")
                response.headers.set(name: PrismHTTPHeaders.contentLength, value: "\(compressed.count)")
            }
        }

        return response
    }

    private func compress(_ data: Data, using algorithm: compression_algorithm) -> Data? {
        let bufferSize = data.count
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { destinationBuffer.deallocate() }

        let compressedSize = data.withUnsafeBytes { sourcePointer -> Int in
            guard let baseAddress = sourcePointer.baseAddress else { return 0 }
            return compression_encode_buffer(
                destinationBuffer,
                bufferSize,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                data.count,
                nil,
                algorithm
            )
        }

        guard compressedSize > 0 && compressedSize < data.count else { return nil }
        return Data(bytes: destinationBuffer, count: compressedSize)
    }
}
