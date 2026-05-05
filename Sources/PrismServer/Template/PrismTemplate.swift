import Foundation

/// Lightweight template engine with variable interpolation, conditionals, and loops.
///
/// Syntax:
/// - `{{ variable }}` — interpolation (HTML-escaped)
/// - `{! variable !}` — raw interpolation (no escaping)
/// - `{% if condition %}...{% endif %}` — conditional
/// - `{% for item in items %}...{% endfor %}` — loop
/// - `{% include "partial" %}` — partial inclusion
public struct PrismTemplate: Sendable {
    private let source: String

    /// Creates a new `PrismTemplate` with the specified configuration.
    public init(_ source: String) {
        self.source = source
    }

    /// Renders the template with the given context.
    public func render(_ context: PrismTemplateContext) throws -> String {
        try renderString(source, context: context)
    }

    private func renderString(_ input: String, context: PrismTemplateContext) throws -> String {
        var output = input

        output = try processForLoops(output, context: context)
        output = try processConditionals(output, context: context)
        output = processIncludes(output, context: context)
        output = processRawInterpolation(output, context: context)
        output = processInterpolation(output, context: context)

        return output
    }

    private func processInterpolation(_ input: String, context: PrismTemplateContext) -> String {
        var result = input
        let pattern = #"\{\{\s*(\w+(?:\.\w+)*)\s*\}\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))

        for match in matches.reversed() {
            guard let keyRange = Range(match.range(at: 1), in: result),
                let fullRange = Range(match.range, in: result)
            else { continue }
            let key = String(result[keyRange])
            let value = context.resolve(key)
            result.replaceSubrange(fullRange, with: htmlEscape(value))
        }
        return result
    }

    private func processRawInterpolation(_ input: String, context: PrismTemplateContext) -> String {
        var result = input
        let pattern = #"\{!\s*(\w+(?:\.\w+)*)\s*!\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))

        for match in matches.reversed() {
            guard let keyRange = Range(match.range(at: 1), in: result),
                let fullRange = Range(match.range, in: result)
            else { continue }
            let key = String(result[keyRange])
            result.replaceSubrange(fullRange, with: context.resolve(key))
        }
        return result
    }

    private func processConditionals(_ input: String, context: PrismTemplateContext) throws -> String {
        var result = input
        let pattern = #"\{%\s*if\s+(\w+)\s*%\}(.*?)\{%\s*endif\s*%\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators) else {
            return result
        }

        var matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        while !matches.isEmpty {
            for match in matches.reversed() {
                guard let condRange = Range(match.range(at: 1), in: result),
                    let bodyRange = Range(match.range(at: 2), in: result),
                    let fullRange = Range(match.range, in: result)
                else { continue }

                let condition = String(result[condRange])
                let body = String(result[bodyRange])

                if context.isTruthy(condition) {
                    result.replaceSubrange(fullRange, with: try renderString(body, context: context))
                } else {
                    result.replaceSubrange(fullRange, with: "")
                }
            }
            matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        }
        return result
    }

    private func processForLoops(_ input: String, context: PrismTemplateContext) throws -> String {
        var result = input
        let pattern = #"\{%\s*for\s+(\w+)\s+in\s+(\w+)\s*%\}(.*?)\{%\s*endfor\s*%\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators) else {
            return result
        }

        var matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        while !matches.isEmpty {
            for match in matches.reversed() {
                guard let itemRange = Range(match.range(at: 1), in: result),
                    let listRange = Range(match.range(at: 2), in: result),
                    let bodyRange = Range(match.range(at: 3), in: result),
                    let fullRange = Range(match.range, in: result)
                else { continue }

                let itemName = String(result[itemRange])
                let listName = String(result[listRange])
                let body = String(result[bodyRange])

                let items = context.resolveArray(listName)
                var rendered = ""
                for item in items {
                    var childContext = context
                    childContext.set(itemName, to: item)
                    rendered += try renderString(body, context: childContext)
                }
                result.replaceSubrange(fullRange, with: rendered)
            }
            matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        }
        return result
    }

    private func processIncludes(_ input: String, context: PrismTemplateContext) -> String {
        var result = input
        let pattern = #"\{%\s*include\s+"([^"]+)"\s*%\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))

        for match in matches.reversed() {
            guard let nameRange = Range(match.range(at: 1), in: result),
                let fullRange = Range(match.range, in: result)
            else { continue }
            let name = String(result[nameRange])
            let partial = context.partials[name] ?? ""
            result.replaceSubrange(fullRange, with: partial)
        }
        return result
    }

    private func htmlEscape(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

/// Template rendering context with variables, arrays, and partials.
public struct PrismTemplateContext: Sendable {
    private var values: [String: String] = [:]
    private var arrays: [String: [String]] = [:]
    /// Named partial templates for inclusion.
    public var partials: [String: String] = [:]

    /// Creates a new `PrismTemplateContext` with the specified configuration.
    public init() {}

    /// Sets a string value for the given template variable key.
    public mutating func set(_ key: String, to value: String) {
        values[key] = value
    }

    /// Sets an array of strings for the given template loop key.
    public mutating func set(_ key: String, to items: [String]) {
        arrays[key] = items
    }

    /// Registers a named partial template for inclusion during rendering.
    public mutating func setPartial(_ name: String, content: String) {
        partials[name] = content
    }

    func resolve(_ key: String) -> String {
        values[key] ?? ""
    }

    func resolveArray(_ key: String) -> [String] {
        arrays[key] ?? []
    }

    func isTruthy(_ key: String) -> Bool {
        if let value = values[key] {
            return !value.isEmpty && value != "false" && value != "0"
        }
        if let arr = arrays[key] {
            return !arr.isEmpty
        }
        return false
    }
}

extension PrismHTTPResponse {
    /// Creates an HTML response rendered from a template.
    public static func template(_ source: String, context: PrismTemplateContext, status: PrismHTTPStatus = .ok)
        -> PrismHTTPResponse
    {
        let template = PrismTemplate(source)
        do {
            let rendered = try template.render(context)
            return .html(rendered, status: status)
        } catch {
            return .text("Template rendering error: \(error)", status: .internalServerError)
        }
    }
}
