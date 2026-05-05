import Foundation

/// A parsed media type from the Accept header.
public struct PrismMediaType: Sendable, Equatable {
    /// The primary type component (e.g., "application").
    public let type: String
    /// The subtype component (e.g., "json").
    public let subtype: String
    /// The quality factor from 0.0 to 1.0.
    public let quality: Double

    /// Creates a media type with the given type, subtype, and quality factor.
    public init(type: String, subtype: String, quality: Double = 1.0) {
        self.type = type
        self.subtype = subtype
        self.quality = quality
    }

    /// Full MIME type string.
    public var fullType: String { "\(type)/\(subtype)" }

    /// Checks if this media type matches the given type/subtype, supporting wildcards.
    public func matches(_ matchType: String, _ matchSubtype: String) -> Bool {
        let typeOK = type == "*" || matchType == "*" || type == matchType
        let subtypeOK = subtype == "*" || matchSubtype == "*" || subtype == matchSubtype
        return typeOK && subtypeOK
    }

    /// Parses an Accept header into sorted media types.
    public static func parse(_ header: String) -> [PrismMediaType] {
        let entries = header.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        var types: [PrismMediaType] = []

        for entry in entries {
            let parts = entry.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
            guard let mimePart = parts.first else { continue }
            let mimePieces = mimePart.split(separator: "/")
            guard mimePieces.count == 2 else { continue }

            var quality = 1.0
            for param in parts.dropFirst() {
                let kv = param.split(separator: "=")
                if kv.count == 2 && kv[0].trimmingCharacters(in: .whitespaces) == "q" {
                    quality = Double(kv[1].trimmingCharacters(in: .whitespaces)) ?? 1.0
                }
            }

            types.append(PrismMediaType(
                type: String(mimePieces[0]),
                subtype: String(mimePieces[1]),
                quality: quality
            ))
        }

        return types.sorted { $0.quality > $1.quality }
    }
}

/// Supported response formats.
public enum PrismResponseFormat: Sendable, Equatable {
    /// JSON format (application/json).
    case json
    /// XML format (application/xml).
    case xml
    /// HTML format (text/html).
    case html
    /// CSV format (text/csv).
    case csv
    /// Plain text format (text/plain).
    case text
    /// A custom MIME type.
    case custom(String)

    /// The MIME type for this format.
    public var mimeType: String {
        switch self {
        case .json: return "application/json"
        case .xml: return "application/xml"
        case .html: return "text/html"
        case .csv: return "text/csv"
        case .text: return "text/plain"
        case .custom(let mime): return mime
        }
    }

    /// The type component of the MIME type.
    var typeComponent: String { String(mimeType.split(separator: "/")[0]) }
    /// The subtype component of the MIME type.
    var subtypeComponent: String { String(mimeType.split(separator: "/")[1]) }
}

/// Negotiates the best response format from an Accept header.
public struct PrismContentNegotiator: Sendable {
    /// Creates a content negotiator.
    public init() {}

    /// Picks the best format from available options based on the Accept header.
    public static func negotiate(accept: String, available: [PrismResponseFormat]) -> PrismResponseFormat? {
        let requested = PrismMediaType.parse(accept)
        for mediaType in requested {
            for format in available {
                if mediaType.matches(format.typeComponent, format.subtypeComponent) {
                    return format
                }
            }
        }
        return available.first
    }
}

/// Builds a response in the negotiated format.
public struct PrismNegotiatedResponse: Sendable {
    /// Creates a negotiated response builder.
    public init() {}

    /// Responds with data in the best format based on the request's Accept header.
    public static func respond(
        to request: PrismHTTPRequest,
        data: [String: Any],
        available: [PrismResponseFormat] = [.json, .xml, .html, .csv, .text]
    ) -> PrismHTTPResponse {
        let accept = request.headers.value(for: "Accept") ?? "application/json"
        let format = PrismContentNegotiator.negotiate(accept: accept, available: available) ?? .json
        return render(data: data, as: format)
    }

    /// Renders data in a specific format.
    public static func render(data: [String: Any], as format: PrismResponseFormat) -> PrismHTTPResponse {
        let body: Data
        let contentType: String

        switch format {
        case .json:
            body = (try? JSONSerialization.data(withJSONObject: data, options: [.sortedKeys])) ?? Data()
            contentType = "application/json; charset=utf-8"

        case .xml:
            var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root>\n"
            for (key, value) in data.sorted(by: { $0.key < $1.key }) {
                let escaped = xmlEscape("\(value)")
                xml += "  <\(key)>\(escaped)</\(key)>\n"
            }
            xml += "</root>"
            body = Data(xml.utf8)
            contentType = "application/xml; charset=utf-8"

        case .html:
            var html = "<!DOCTYPE html><html><body><table>\n"
            for (key, value) in data.sorted(by: { $0.key < $1.key }) {
                let escaped = htmlEscape("\(value)")
                html += "<tr><th>\(htmlEscape(key))</th><td>\(escaped)</td></tr>\n"
            }
            html += "</table></body></html>"
            body = Data(html.utf8)
            contentType = "text/html; charset=utf-8"

        case .csv:
            let keys = data.keys.sorted()
            let header = keys.joined(separator: ",")
            let values = keys.map { csvEscape("\(data[$0] ?? "")") }.joined(separator: ",")
            body = Data("\(header)\n\(values)\n".utf8)
            contentType = "text/csv; charset=utf-8"

        case .text:
            let text = data.sorted(by: { $0.key < $1.key })
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "\n")
            body = Data(text.utf8)
            contentType = "text/plain; charset=utf-8"

        case .custom(let mime):
            body = (try? JSONSerialization.data(withJSONObject: data)) ?? Data()
            contentType = mime
        }

        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: contentType)
        headers.set(name: "Content-Length", value: "\(body.count)")
        return PrismHTTPResponse(status: .ok, headers: headers, body: .data(body))
    }

    private static func xmlEscape(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private static func htmlEscape(_ string: String) -> String {
        xmlEscape(string)
    }

    private static func csvEscape(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }
}
