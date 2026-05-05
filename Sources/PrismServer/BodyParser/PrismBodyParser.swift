import Foundation

/// A parsed XML node.
public struct PrismXMLNode: Sendable {
    /// The element tag name.
    public let name: String
    /// The element's XML attributes.
    public let attributes: [String: String]
    /// The text content of this node.
    public var text: String?
    /// The child nodes nested within this element.
    public var children: [PrismXMLNode]

    /// Creates an XML node with the given tag name, attributes, text, and children.
    public init(name: String, attributes: [String: String] = [:], text: String? = nil, children: [PrismXMLNode] = []) {
        self.name = name
        self.attributes = attributes
        self.text = text
        self.children = children
    }

    /// Finds the first child with the given name.
    public func child(_ name: String) -> PrismXMLNode? {
        children.first { $0.name == name }
    }

    /// Finds all children with the given name.
    public func childrenNamed(_ name: String) -> [PrismXMLNode] {
        children.filter { $0.name == name }
    }
}

/// Simple XML parser using Foundation's XMLParser.
public enum PrismXMLParserUtil {
    /// Parses raw XML data into a tree of nodes.
    public static func parse(_ data: Data) -> PrismXMLNode? {
        let parser = XMLParser(data: data)
        let delegate = XMLParserDelegateImpl()
        parser.delegate = delegate
        guard parser.parse(), let root = delegate.root else { return nil }
        return root
    }
}

private final class XMLParserDelegateImpl: NSObject, XMLParserDelegate, @unchecked Sendable {
    var root: PrismXMLNode?
    private var stack: [PrismXMLNode] = []
    private var currentText = ""

    func parser(
        _ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        let node = PrismXMLNode(name: elementName, attributes: attributeDict)
        stack.append(node)
        currentText = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        guard var completed = stack.popLast() else { return }
        let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            completed.text = trimmed
        }
        currentText = ""

        if stack.isEmpty {
            root = completed
        } else {
            stack[stack.count - 1].children.append(completed)
        }
    }
}

/// Parses URL-encoded form data with nested keys.
public enum PrismNestedFormParser {
    /// Parses `user[name]=John&user[age]=30` into nested dictionaries.
    public static func parse(_ body: String) -> [String: Any] {
        var result: [String: Any] = [:]
        let pairs = body.split(separator: "&", omittingEmptySubsequences: true)

        for pair in pairs {
            let parts = pair.split(separator: "=", maxSplits: 1)
            guard let rawKey = parts.first else { continue }
            let rawValue = parts.count > 1 ? String(parts[1]) : ""

            let key = rawKey.removingPercentEncoding ?? String(rawKey)
            let value = rawValue.removingPercentEncoding ?? rawValue

            let segments = parseKeySegments(key)
            setNested(&result, segments: segments, value: value)
        }

        return result
    }

    private static func parseKeySegments(_ key: String) -> [String] {
        var segments: [String] = []
        var current = ""
        var inBracket = false

        for char in key {
            if char == "[" {
                if !current.isEmpty || segments.isEmpty {
                    segments.append(current)
                    current = ""
                }
                inBracket = true
            } else if char == "]" && inBracket {
                segments.append(current)
                current = ""
                inBracket = false
            } else {
                current.append(char)
            }
        }
        if !current.isEmpty {
            segments.append(current)
        }
        return segments
    }

    private static func setNested(_ dict: inout [String: Any], segments: [String], value: String) {
        guard let first = segments.first else { return }
        if segments.count == 1 {
            dict[first] = value
            return
        }

        let rest = Array(segments.dropFirst())
        if var nested = dict[first] as? [String: Any] {
            setNested(&nested, segments: rest, value: value)
            dict[first] = nested
        } else {
            var nested: [String: Any] = [:]
            setNested(&nested, segments: rest, value: value)
            dict[first] = nested
        }
    }
}

/// Middleware that auto-detects and parses request bodies.
public struct PrismBodyParserMiddleware: PrismMiddleware, Sendable {
    /// Creates a new body parser middleware.
    public init() {}

    /// Detects the content type and annotates the request with the parsed body type.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        var req = request
        let contentType = req.headers.value(for: "Content-Type")?.lowercased() ?? ""

        if contentType.contains("application/json") {
            req.userInfo["parsedBodyType"] = "json"
        } else if contentType.contains("application/x-www-form-urlencoded") {
            req.userInfo["parsedBodyType"] = "form"
        } else if contentType.contains("multipart/form-data") {
            req.userInfo["parsedBodyType"] = "multipart"
        } else if contentType.contains("application/xml") || contentType.contains("text/xml") {
            req.userInfo["parsedBodyType"] = "xml"
        }

        return try await next(req)
    }
}

extension PrismHTTPRequest {
    /// Parses body as XML.
    public var xmlBody: PrismXMLNode? {
        guard let body else { return nil }
        return PrismXMLParserUtil.parse(body)
    }

    /// Parses body as nested URL-encoded form data.
    public var nestedFormData: [String: Any] {
        guard let body, let str = String(data: body, encoding: .utf8) else { return [:] }
        return PrismNestedFormParser.parse(str)
    }
}
