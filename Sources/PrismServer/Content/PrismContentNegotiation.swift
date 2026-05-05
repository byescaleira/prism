import Foundation

/// Extensions on PrismHTTPRequest for body decoding.
extension PrismHTTPRequest {
    /// Decodes the request body as JSON into the given type.
    public func decodeJSON<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard let body else {
            throw PrismContentError.emptyBody
        }
        do {
            return try decoder.decode(type, from: body)
        } catch {
            throw PrismContentError.decodingFailed(error.localizedDescription)
        }
    }

    /// Returns the raw body as a UTF-8 string.
    public var bodyString: String? {
        body.flatMap { String(data: $0, encoding: .utf8) }
    }

    /// Returns the body parsed as URL-encoded form data.
    public var formData: [String: String] {
        guard let body, let string = String(data: body, encoding: .utf8) else { return [:] }
        var result: [String: String] = [:]
        for pair in string.split(separator: "&") {
            let kv = pair.split(separator: "=", maxSplits: 1)
            if kv.count == 2 {
                let key = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                let value = String(kv[1]).removingPercentEncoding ?? String(kv[1])
                result[key] = value
            }
        }
        return result
    }
}

/// Errors during content parsing.
public enum PrismContentError: Error, Sendable {
    /// The request body is empty.
    case emptyBody
    /// Body decoding failed with the given reason.
    case decodingFailed(String)
    /// The request's content type is not supported.
    case unsupportedContentType(String)
    /// The multipart boundary marker is missing from Content-Type.
    case multipartBoundaryMissing
    /// Multipart body parsing failed.
    case multipartParsingFailed
}
