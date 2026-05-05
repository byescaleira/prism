import SwiftUI

/// Programming languages supported by the syntax highlighter.
public enum PrismSyntaxLanguage: String, Sendable, CaseIterable {
    /// Swift source code.
    case swift
    /// JSON data.
    case json
    /// HTML markup.
    case html
    /// CSS stylesheets.
    case css
    /// JavaScript source code.
    case javascript
    /// Python source code.
    case python
    /// Unformatted plain text.
    case plainText

    /// File extension typically associated with this language.
    public var fileExtension: String {
        switch self {
        case .swift: "swift"
        case .json: "json"
        case .html: "html"
        case .css: "css"
        case .javascript: "js"
        case .python: "py"
        case .plainText: "txt"
        }
    }
}

// MARK: - Token Types

package enum PrismSyntaxTokenType: Sendable {
    case keyword
    case string
    case comment
    case number
    case punctuation
    case type
    case plain
}

package struct PrismSyntaxToken: Sendable {
    package let text: String
    package let type: PrismSyntaxTokenType

    package init(text: String, type: PrismSyntaxTokenType) {
        self.text = text
        self.type = type
    }
}

// MARK: - Language Keywords

package func prismSyntaxKeywords(for language: PrismSyntaxLanguage) -> Set<String> {
    switch language {
    case .swift:
        return [
            "import", "struct", "class", "enum", "protocol", "func", "var", "let",
            "if", "else", "guard", "switch", "case", "return", "for", "in", "while",
            "do", "try", "catch", "throw", "throws", "async", "await", "public",
            "private", "internal", "fileprivate", "open", "static", "override",
            "init", "deinit", "self", "Self", "super", "nil", "true", "false",
            "some", "any", "where", "extension", "typealias", "associatedtype",
            "@MainActor", "@Sendable", "@State", "@Binding", "@Environment",
            "@Observable", "@Published",
        ]
    case .javascript:
        return [
            "const", "let", "var", "function", "return", "if", "else", "for",
            "while", "do", "switch", "case", "break", "continue", "class",
            "extends", "import", "export", "default", "from", "async", "await",
            "try", "catch", "throw", "new", "this", "typeof", "instanceof",
            "null", "undefined", "true", "false", "of", "in",
        ]
    case .python:
        return [
            "def", "class", "if", "elif", "else", "for", "while", "return",
            "import", "from", "as", "try", "except", "finally", "raise", "with",
            "lambda", "pass", "break", "continue", "and", "or", "not", "is",
            "in", "True", "False", "None", "self", "yield", "async", "await",
        ]
    case .html:
        return [
            "html", "head", "body", "div", "span", "p", "a", "img", "ul", "ol",
            "li", "table", "tr", "td", "th", "form", "input", "button", "script",
            "style", "link", "meta", "title", "section", "article", "nav", "header",
            "footer", "main",
        ]
    case .css:
        return [
            "color", "background", "margin", "padding", "border", "display",
            "position", "width", "height", "font", "text", "flex", "grid",
            "align", "justify", "transform", "transition", "animation",
            "opacity", "overflow", "z-index", "@media", "@keyframes", "important",
        ]
    case .json, .plainText:
        return []
    }
}

// MARK: - Colorizer

package func prismSyntaxColorize(_ tokens: [PrismSyntaxToken]) -> AttributedString {
    var result = AttributedString()

    for token in tokens {
        var attr = AttributedString(token.text)
        attr.font = .system(.body, design: .monospaced)

        switch token.type {
        case .keyword:
            attr.foregroundColor = .pink
        case .string:
            attr.foregroundColor = .red
        case .comment:
            attr.foregroundColor = .gray
        case .number:
            attr.foregroundColor = .purple
        case .type:
            attr.foregroundColor = .cyan
        case .punctuation:
            attr.foregroundColor = .secondary
        case .plain:
            break
        }

        result.append(attr)
    }

    return result
}
