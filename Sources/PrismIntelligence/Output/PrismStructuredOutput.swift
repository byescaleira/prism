//
//  PrismStructuredOutput.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// The schema type for structured output parsing.
public enum PrismOutputSchema: @unchecked Sendable {
    /// A JSON schema expecting a Decodable type.
    case json(any Decodable.Type)
    /// A list of items.
    case list
    /// Key-value pairs.
    case keyValue
    /// A tabular structure.
    case table
}

/// Parses structured data from raw text.
public struct PrismStructuredParser: Sendable {
    /// Creates a structured parser.
    public init() {}

    /// Attempts to decode a Decodable type from a JSON string.
    public func parse<T: Decodable>(_ text: String, as type: T.Type) -> T? {
        guard let jsonString = extractJSON(text) else { return nil }
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    /// Extracts the first JSON object or array found in mixed text.
    public func extractJSON(_ text: String) -> String? {
        // Try to find a JSON object
        if let objectRange = findBalanced(in: text, open: "{", close: "}") {
            return String(text[objectRange])
        }
        // Try to find a JSON array
        if let arrayRange = findBalanced(in: text, open: "[", close: "]") {
            return String(text[arrayRange])
        }
        return nil
    }

    /// Extracts key-value pairs from text formatted as "key: value" lines.
    public func extractKeyValues(_ text: String) -> [String: String] {
        var result: [String: String] = [:]
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            if let colonIndex = trimmed.firstIndex(of: ":") {
                let key = trimmed[trimmed.startIndex..<colonIndex].trimmingCharacters(in: .whitespaces)
                let value = trimmed[trimmed.index(after: colonIndex)...].trimmingCharacters(in: .whitespaces)
                if !key.isEmpty {
                    result[key] = value
                }
            }
        }
        return result
    }

    private func findBalanced(in text: String, open: Character, close: Character) -> Range<String.Index>? {
        guard let start = text.firstIndex(of: open) else { return nil }
        var depth = 0
        var inString = false
        var escaped = false
        var index = start
        while index < text.endIndex {
            let char = text[index]
            if escaped {
                escaped = false
            } else if char == "\\" && inString {
                escaped = true
            } else if char == "\"" {
                inString.toggle()
            } else if !inString {
                if char == open { depth += 1 }
                if char == close {
                    depth -= 1
                    if depth == 0 {
                        return start..<text.index(after: index)
                    }
                }
            }
            index = text.index(after: index)
        }
        return nil
    }
}

/// Validates parsed output against a schema.
public struct PrismOutputValidator: Sendable {
    /// Creates an output validator.
    public init() {}

    /// Validates that a text can be parsed according to the given schema.
    public func validate(_ text: String, against schema: PrismOutputSchema) -> Bool {
        let parser = PrismStructuredParser()
        switch schema {
        case .json:
            return parser.extractJSON(text) != nil
        case .list:
            let lines = text.components(separatedBy: .newlines).filter {
                !$0.trimmingCharacters(in: .whitespaces).isEmpty
            }
            return !lines.isEmpty
        case .keyValue:
            return !parser.extractKeyValues(text).isEmpty
        case .table:
            let lines = text.components(separatedBy: .newlines).filter {
                !$0.trimmingCharacters(in: .whitespaces).isEmpty
            }
            return lines.count >= 2
        }
    }
}
