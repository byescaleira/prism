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

/// Applies token-based syntax coloring to source code strings.
public struct PrismSyntaxHighlighter: Sendable {

    /// Creates a syntax highlighter instance.
    public init() {}

    /// Highlights the given source code for the specified language.
    public func highlight(_ code: String, language: PrismSyntaxLanguage) -> AttributedString {
        guard language != .plainText else {
            return AttributedString(code)
        }

        let tokens = tokenize(code, language: language)
        return colorize(tokens)
    }

    // MARK: - Token Types

    private enum TokenType: Sendable {
        case keyword
        case string
        case comment
        case number
        case punctuation
        case type
        case plain
    }

    private struct Token: Sendable {
        let text: String
        let type: TokenType
    }

    // MARK: - Language Keywords

    private func keywords(for language: PrismSyntaxLanguage) -> Set<String> {
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

    // MARK: - Tokenizer

    private func tokenize(_ code: String, language: PrismSyntaxLanguage) -> [Token] {
        var tokens: [Token] = []
        let chars = Array(code)
        let languageKeywords = keywords(for: language)
        var index = chars.startIndex

        while index < chars.count {
            let char = chars[index]

            // Single-line comment
            if char == "/" && index + 1 < chars.count && chars[index + 1] == "/" {
                var comment = ""
                while index < chars.count && chars[index] != "\n" {
                    comment.append(chars[index])
                    index += 1
                }
                tokens.append(Token(text: comment, type: .comment))
                continue
            }

            // Multi-line comment
            if char == "/" && index + 1 < chars.count && chars[index + 1] == "*" {
                var comment = ""
                comment.append(chars[index])
                index += 1
                comment.append(chars[index])
                index += 1
                while index < chars.count {
                    if chars[index] == "*" && index + 1 < chars.count && chars[index + 1] == "/" {
                        comment.append(chars[index])
                        index += 1
                        comment.append(chars[index])
                        index += 1
                        break
                    }
                    comment.append(chars[index])
                    index += 1
                }
                tokens.append(Token(text: comment, type: .comment))
                continue
            }

            // Python/hash comment
            if char == "#" && (language == .python || language == .css) {
                var comment = ""
                while index < chars.count && chars[index] != "\n" {
                    comment.append(chars[index])
                    index += 1
                }
                tokens.append(Token(text: comment, type: .comment))
                continue
            }

            // HTML comment
            if char == "<" && index + 3 < chars.count
                && chars[index + 1] == "!" && chars[index + 2] == "-" && chars[index + 3] == "-"
            {
                var comment = ""
                while index < chars.count {
                    comment.append(chars[index])
                    if comment.hasSuffix("-->") {
                        index += 1
                        break
                    }
                    index += 1
                }
                tokens.append(Token(text: comment, type: .comment))
                continue
            }

            // Strings (double and single quote)
            if char == "\"" || char == "'" {
                let quote = char
                var str = String(char)
                index += 1
                while index < chars.count && chars[index] != quote {
                    if chars[index] == "\\" && index + 1 < chars.count {
                        str.append(chars[index])
                        index += 1
                    }
                    str.append(chars[index])
                    index += 1
                }
                if index < chars.count {
                    str.append(chars[index])
                    index += 1
                }
                tokens.append(Token(text: str, type: .string))
                continue
            }

            // Numbers
            if char.isNumber || (char == "." && index + 1 < chars.count && chars[index + 1].isNumber) {
                var num = ""
                while index < chars.count && (chars[index].isNumber || chars[index] == "." || chars[index] == "_") {
                    num.append(chars[index])
                    index += 1
                }
                tokens.append(Token(text: num, type: .number))
                continue
            }

            // Words (identifiers / keywords)
            if char.isLetter || char == "_" || char == "@" {
                var word = ""
                while index < chars.count && (chars[index].isLetter || chars[index].isNumber || chars[index] == "_")
                {
                    word.append(chars[index])
                    index += 1
                }
                let tokenType: TokenType =
                    if languageKeywords.contains(word) {
                        .keyword
                    } else if word.first?.isUppercase == true {
                        .type
                    } else {
                        .plain
                    }
                tokens.append(Token(text: word, type: tokenType))
                continue
            }

            // @ prefix (Swift attributes)
            if char == "@" && language == .swift {
                var attr = "@"
                index += 1
                while index < chars.count && (chars[index].isLetter || chars[index].isNumber) {
                    attr.append(chars[index])
                    index += 1
                }
                let tokenType: TokenType = languageKeywords.contains(attr) ? .keyword : .plain
                tokens.append(Token(text: attr, type: tokenType))
                continue
            }

            // Punctuation / whitespace / other
            tokens.append(Token(text: String(char), type: char.isPunctuation ? .punctuation : .plain))
            index += 1
        }

        return tokens
    }

    // MARK: - Colorizer

    private func colorize(_ tokens: [Token]) -> AttributedString {
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
}

/// A themed code block view with line numbers, syntax highlighting, and a copy button.
@MainActor
public struct PrismCodeBlock: View {
    @Environment(\.prismTheme) private var theme

    private let code: String
    private let language: PrismSyntaxLanguage
    private let showLineNumbers: Bool

    @State private var copied = false

    /// Creates a code block view with the given source and language.
    public init(_ code: String, language: PrismSyntaxLanguage = .plainText, showLineNumbers: Bool = true) {
        self.code = code
        self.language = language
        self.showLineNumbers = showLineNumbers
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with language label and copy button
            HStack {
                Text(language.rawValue)
                    .font(TypographyToken.caption.font)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))

                Spacer()

                Button {
                    copyToClipboard()
                } label: {
                    Label(
                        copied ? "Copied" : "Copy",
                        systemImage: copied ? "checkmark" : "doc.on.doc"
                    )
                    .font(TypographyToken.caption.font)
                    .foregroundStyle(theme.color(.interactive))
                }
                .accessibilityLabel(copied ? "Copied to clipboard" : "Copy code")
            }
            .padding(.horizontal, SpacingToken.md.rawValue)
            .padding(.vertical, SpacingToken.xs.rawValue)
            .background(theme.color(.surfaceElevated))

            Divider()

            // Code content
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    if showLineNumbers {
                        lineNumberColumn
                    }
                    highlightedCodeView
                }
                .padding(SpacingToken.sm.rawValue)
            }
        }
        .background(theme.color(.surfaceSecondary))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.md.rawValue))
        .overlay(
            RoundedRectangle(cornerRadius: RadiusToken.md.rawValue)
                .stroke(theme.color(.borderSubtle), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Code block in \(language.rawValue)")
    }

    // MARK: - Subviews

    private var lines: [String] {
        code.components(separatedBy: "\n")
    }

    @ViewBuilder
    private var lineNumberColumn: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(1...max(lines.count, 1), id: \.self) { number in
                Text("\(number)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(theme.color(.onBackgroundTertiary))
                    .frame(minWidth: 28, alignment: .trailing)
            }
        }
        .padding(.trailing, SpacingToken.sm.rawValue)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var highlightedCodeView: some View {
        let highlighter = PrismSyntaxHighlighter()
        let highlighted = highlighter.highlight(code, language: language)
        Text(highlighted)
            .textSelection(.enabled)
    }

    // MARK: - Actions

    private func copyToClipboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = code
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        #endif

        withAnimation(.easeInOut(duration: 0.2)) {
            copied = true
        }

        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeInOut(duration: 0.2)) {
                copied = false
            }
        }
    }
}
