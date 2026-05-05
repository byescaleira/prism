import SwiftUI

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
        return prismSyntaxColorize(tokens)
    }

    // MARK: - Tokenizer

    private func tokenize(_ code: String, language: PrismSyntaxLanguage) -> [PrismSyntaxToken] {
        var tokens: [PrismSyntaxToken] = []
        let chars = Array(code)
        let languageKeywords = prismSyntaxKeywords(for: language)
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
                tokens.append(PrismSyntaxToken(text: comment, type: .comment))
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
                tokens.append(PrismSyntaxToken(text: comment, type: .comment))
                continue
            }

            // Python/hash comment
            if char == "#" && (language == .python || language == .css) {
                var comment = ""
                while index < chars.count && chars[index] != "\n" {
                    comment.append(chars[index])
                    index += 1
                }
                tokens.append(PrismSyntaxToken(text: comment, type: .comment))
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
                tokens.append(PrismSyntaxToken(text: comment, type: .comment))
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
                tokens.append(PrismSyntaxToken(text: str, type: .string))
                continue
            }

            // Numbers
            if char.isNumber || (char == "." && index + 1 < chars.count && chars[index + 1].isNumber) {
                var num = ""
                while index < chars.count && (chars[index].isNumber || chars[index] == "." || chars[index] == "_") {
                    num.append(chars[index])
                    index += 1
                }
                tokens.append(PrismSyntaxToken(text: num, type: .number))
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
                let tokenType: PrismSyntaxTokenType =
                    if languageKeywords.contains(word) {
                        .keyword
                    } else if word.first?.isUppercase == true {
                        .type
                    } else {
                        .plain
                    }
                tokens.append(PrismSyntaxToken(text: word, type: tokenType))
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
                let tokenType: PrismSyntaxTokenType = languageKeywords.contains(attr) ? .keyword : .plain
                tokens.append(PrismSyntaxToken(text: attr, type: tokenType))
                continue
            }

            // Punctuation / whitespace / other
            tokens.append(PrismSyntaxToken(text: String(char), type: char.isPunctuation ? .punctuation : .plain))
            index += 1
        }

        return tokens
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

    /// The view body.
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
