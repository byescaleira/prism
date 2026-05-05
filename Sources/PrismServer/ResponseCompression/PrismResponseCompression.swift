import Compression
import Foundation

/// Supported response body compression algorithms.
public enum PrismCompressionAlgorithm: String, Sendable {
    case gzip
    case deflate

    var compressionAlgorithm: compression_algorithm {
        switch self {
        case .gzip: return COMPRESSION_ZLIB
        case .deflate: return COMPRESSION_ZLIB
        }
    }
}

/// Configuration options for ResponseCompression.
public struct PrismResponseCompressionConfig: Sendable {
    /// The minimum size.
    public let minimumSize: Int
    /// The preferred algorithm.
    public let preferredAlgorithm: PrismCompressionAlgorithm
    /// The compressible types.
    public let compressibleTypes: Set<String>
    /// The excluded paths.
    public let excludedPaths: [String]
    /// The level.
    public let level: Int

    /// Creates a new `PrismResponseCompressionConfig` with the specified configuration.
    public init(
        minimumSize: Int = 1024,
        preferredAlgorithm: PrismCompressionAlgorithm = .gzip,
        compressibleTypes: Set<String>? = nil,
        excludedPaths: [String] = [],
        level: Int = 6
    ) {
        self.minimumSize = minimumSize
        self.preferredAlgorithm = preferredAlgorithm
        self.compressibleTypes = compressibleTypes ?? Self.defaultCompressibleTypes
        self.excludedPaths = excludedPaths
        self.level = level
    }

    /// The default set of MIME types eligible for response compression.
    public static let defaultCompressibleTypes: Set<String> = [
        "text/html", "text/css", "text/plain", "text/xml", "text/csv",
        "application/json", "application/javascript", "application/xml",
        "application/xhtml+xml", "application/rss+xml", "application/atom+xml",
        "image/svg+xml", "application/wasm", "text/markdown",
    ]
}

/// Middleware that compresses response bodies using gzip or deflate.
public struct PrismResponseCompressionMiddleware: PrismMiddleware {
    private let config: PrismResponseCompressionConfig

    /// Creates a new `PrismResponseCompressionMiddleware` with the specified configuration.
    public init(config: PrismResponseCompressionConfig = PrismResponseCompressionConfig()) {
        self.config = config
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        var response = try await next(request)

        for excluded in config.excludedPaths {
            if request.path.hasPrefix(excluded) { return response }
        }

        if response.headers.value(for: "Content-Encoding") != nil { return response }

        let bodyData = response.body.data
        guard bodyData.count >= config.minimumSize else { return response }

        guard isCompressible(response: response) else { return response }

        let acceptEncoding = request.headers.value(for: "Accept-Encoding")?.lowercased() ?? ""
        let algorithm = negotiateAlgorithm(acceptEncoding: acceptEncoding)

        guard let algo = algorithm else { return response }

        guard let compressed = compressData(bodyData, algorithm: algo) else { return response }
        guard compressed.count < bodyData.count else { return response }

        response.body = .data(compressed)
        response.headers.set(name: "Content-Encoding", value: algo.rawValue)
        response.headers.set(name: PrismHTTPHeaders.contentLength, value: "\(compressed.count)")
        response.headers.add(name: "Vary", value: "Accept-Encoding")

        return response
    }

    private func isCompressible(response: PrismHTTPResponse) -> Bool {
        guard let contentType = response.headers.value(for: PrismHTTPHeaders.contentType) else { return false }
        let baseType = contentType.split(separator: ";").first?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
        return config.compressibleTypes.contains(baseType)
    }

    private func negotiateAlgorithm(acceptEncoding: String) -> PrismCompressionAlgorithm? {
        let preferred = config.preferredAlgorithm
        if acceptEncoding.contains(preferred.rawValue) { return preferred }
        if acceptEncoding.contains("gzip") { return .gzip }
        if acceptEncoding.contains("deflate") { return .deflate }
        return nil
    }

    private func compressData(_ data: Data, algorithm: PrismCompressionAlgorithm) -> Data? {
        let bufferSize = max(data.count, 64)
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
                algorithm.compressionAlgorithm
            )
        }

        guard compressedSize > 0 else { return nil }
        return Data(bytes: destinationBuffer, count: compressedSize)
    }
}
