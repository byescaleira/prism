import SwiftUI

/// Rendering style for markdown content.
public enum PrismMarkdownStyle: String, Sendable, CaseIterable {
    /// Full-size rendering with generous spacing.
    case `default`
    /// Tighter spacing for constrained layouts.
    case compact
    /// Optimized for API/library documentation pages.
    case documentation
}

/// A SwiftUI view that renders a Markdown string using PrismUI design tokens.
@MainActor
public struct PrismMarkdownView: View {
    @Environment(\.prismTheme) private var theme

    private let markdown: String
    private let style: PrismMarkdownStyle

    /// Creates a markdown renderer with the given content and style.
    public init(_ markdown: String, style: PrismMarkdownStyle = .default) {
        self.markdown = markdown
        self.style = style
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: blockSpacing) {
                ForEach(Array(parseBlocks().enumerated()), id: \.offset) { _, block in
                    renderBlock(block)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(contentPadding)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Markdown content")
    }

    // MARK: - Style Metrics

    private var blockSpacing: CGFloat {
        switch style {
        case .default: SpacingToken.md.rawValue
        case .compact: SpacingToken.sm.rawValue
        case .documentation: SpacingToken.lg.rawValue
        }
    }

    private var contentPadding: CGFloat {
        switch style {
        case .default: SpacingToken.md.rawValue
        case .compact: SpacingToken.sm.rawValue
        case .documentation: SpacingToken.lg.rawValue
        }
    }

    // MARK: - Block Model

    private enum MarkdownBlock: Sendable {
        case heading(level: Int, text: String)
        case paragraph(text: String)
        case codeBlock(language: String, code: String)
        case blockquote(text: String)
        case unorderedList(items: [String])
        case orderedList(items: [String])
        case horizontalRule
        case image(alt: String, url: String)
    }

    // MARK: - Parser

    private func parseBlocks() -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        let lines = markdown.components(separatedBy: "\n")
        var index = 0

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Horizontal rule
            if trimmed.count >= 3
                && (trimmed.allSatisfy({ $0 == "-" }) || trimmed.allSatisfy({ $0 == "*" })
                    || trimmed.allSatisfy({ $0 == "_" }))
            {
                blocks.append(.horizontalRule)
                index += 1
                continue
            }

            // Heading
            if let headingLevel = parseHeadingLevel(trimmed) {
                let text = String(trimmed.dropFirst(headingLevel + 1))
                blocks.append(.heading(level: headingLevel, text: text.trimmingCharacters(in: .whitespaces)))
                index += 1
                continue
            }

            // Code block
            if trimmed.hasPrefix("```") {
                let language = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                index += 1
                while index < lines.count && !lines[index].trimmingCharacters(in: .whitespaces).hasPrefix("```")
                {
                    codeLines.append(lines[index])
                    index += 1
                }
                blocks.append(.codeBlock(language: language, code: codeLines.joined(separator: "\n")))
                index += 1
                continue
            }

            // Blockquote
            if trimmed.hasPrefix(">") {
                var quoteLines: [String] = []
                while index < lines.count
                    && lines[index].trimmingCharacters(in: .whitespaces).hasPrefix(">")
                {
                    let quoteLine = lines[index].trimmingCharacters(in: .whitespaces)
                    quoteLines.append(String(quoteLine.dropFirst(1)).trimmingCharacters(in: .whitespaces))
                    index += 1
                }
                blocks.append(.blockquote(text: quoteLines.joined(separator: " ")))
                continue
            }

            // Unordered list
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
                var items: [String] = []
                while index < lines.count {
                    let itemLine = lines[index].trimmingCharacters(in: .whitespaces)
                    if itemLine.hasPrefix("- ") || itemLine.hasPrefix("* ") || itemLine.hasPrefix("+ ") {
                        items.append(String(itemLine.dropFirst(2)))
                        index += 1
                    } else {
                        break
                    }
                }
                blocks.append(.unorderedList(items: items))
                continue
            }

            // Ordered list
            if let _ = trimmed.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                var items: [String] = []
                while index < lines.count {
                    let itemLine = lines[index].trimmingCharacters(in: .whitespaces)
                    if let range = itemLine.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                        items.append(String(itemLine[range.upperBound...]))
                        index += 1
                    } else {
                        break
                    }
                }
                blocks.append(.orderedList(items: items))
                continue
            }

            // Image
            if let imageMatch = trimmed.range(of: #"!\[([^\]]*)\]\(([^)]+)\)"#, options: .regularExpression) {
                let matched = String(trimmed[imageMatch])
                let alt = extractBracketContent(matched, open: "[", close: "]")
                let url = extractBracketContent(matched, open: "(", close: ")")
                blocks.append(.image(alt: alt, url: url))
                index += 1
                continue
            }

            // Empty line — skip
            if trimmed.isEmpty {
                index += 1
                continue
            }

            // Paragraph (default)
            blocks.append(.paragraph(text: trimmed))
            index += 1
        }

        return blocks
    }

    private func parseHeadingLevel(_ line: String) -> Int? {
        var count = 0
        for char in line {
            if char == "#" {
                count += 1
            } else if char == " " && count > 0 && count <= 6 {
                return count
            } else {
                return nil
            }
        }
        return nil
    }

    private func extractBracketContent(_ text: String, open: String, close: String) -> String {
        guard let openRange = text.range(of: open),
            let closeRange = text.range(of: close, range: openRange.upperBound..<text.endIndex)
        else { return "" }
        return String(text[openRange.upperBound..<closeRange.lowerBound])
    }

    // MARK: - Renderers

    @ViewBuilder
    private func renderBlock(_ block: MarkdownBlock) -> some View {
        switch block {
        case .heading(let level, let text):
            renderHeading(level: level, text: text)
        case .paragraph(let text):
            renderInlineText(text)
                .font(TypographyToken.body.font)
                .foregroundStyle(theme.color(.onBackground))
        case .codeBlock(_, let code):
            renderCodeBlock(code)
        case .blockquote(let text):
            renderBlockquote(text)
        case .unorderedList(let items):
            renderUnorderedList(items)
        case .orderedList(let items):
            renderOrderedList(items)
        case .horizontalRule:
            Divider()
                .padding(.vertical, SpacingToken.sm.rawValue)
        case .image(let alt, let url):
            renderImage(alt: alt, url: url)
        }
    }

    @ViewBuilder
    private func renderHeading(level: Int, text: String) -> some View {
        let token: TypographyToken =
            switch level {
            case 1: .largeTitle
            case 2: .title
            case 3: .title2
            case 4: .title3
            case 5: .headline
            default: .subheadline
            }

        Text(text)
            .font(token.font)
            .foregroundStyle(theme.color(.onBackground))
            .accessibilityAddTraits(.isHeader)
            .padding(.top, level <= 2 ? SpacingToken.sm.rawValue : 0)
    }

    private func renderInlineText(_ text: String) -> Text {
        parseInlineElements(text)
    }

    private func parseInlineElements(_ text: String) -> Text {
        var result = Text("")
        var remaining = text[text.startIndex..<text.endIndex]

        while !remaining.isEmpty {
            // Bold + italic (***text***)
            if let range = remaining.range(of: #"\*\*\*(.+?)\*\*\*"#, options: .regularExpression) {
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty { result = result + Text(before) }
                let inner = String(remaining[range]).dropFirst(3).dropLast(3)
                result = result + Text(String(inner)).bold().italic()
                remaining = remaining[range.upperBound...]
                continue
            }

            // Bold (**text**)
            if let range = remaining.range(of: #"\*\*(.+?)\*\*"#, options: .regularExpression) {
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty { result = result + Text(before) }
                let inner = String(remaining[range]).dropFirst(2).dropLast(2)
                result = result + Text(String(inner)).bold()
                remaining = remaining[range.upperBound...]
                continue
            }

            // Italic (*text*)
            if let range = remaining.range(of: #"\*(.+?)\*"#, options: .regularExpression) {
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty { result = result + Text(before) }
                let inner = String(remaining[range]).dropFirst(1).dropLast(1)
                result = result + Text(String(inner)).italic()
                remaining = remaining[range.upperBound...]
                continue
            }

            // Inline code (`code`)
            if let range = remaining.range(of: #"`([^`]+)`"#, options: .regularExpression) {
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty { result = result + Text(before) }
                let inner = String(remaining[range]).dropFirst(1).dropLast(1)
                result =
                    result
                    + Text(String(inner))
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
                remaining = remaining[range.upperBound...]
                continue
            }

            // Link [text](url)
            if let range = remaining.range(of: #"\[([^\]]+)\]\(([^)]+)\)"#, options: .regularExpression) {
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty { result = result + Text(before) }
                let matched = String(remaining[range])
                let linkText = extractBracketContent(matched, open: "[", close: "]")
                let linkURL = extractBracketContent(matched, open: "(", close: ")")
                if let url = URL(string: linkURL) {
                    result =
                        result
                        + Text(
                            AttributedString(linkText, attributes: .init([.link: url]))
                        )
                        .foregroundColor(.accentColor)
                        .underline()
                } else {
                    result = result + Text(linkText).foregroundColor(.accentColor)
                }
                remaining = remaining[range.upperBound...]
                continue
            }

            // No match — consume rest
            result = result + Text(String(remaining))
            break
        }

        return result
    }

    @ViewBuilder
    private func renderCodeBlock(_ code: String) -> some View {
        Text(code)
            .font(.system(.callout, design: .monospaced))
            .foregroundStyle(theme.color(.onSurface))
            .padding(SpacingToken.md.rawValue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.color(.surfaceSecondary))
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.sm.rawValue))
            .accessibilityLabel("Code block")
    }

    @ViewBuilder
    private func renderBlockquote(_ text: String) -> some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            RoundedRectangle(cornerRadius: 2)
                .fill(theme.color(.brand))
                .frame(width: 4)
            renderInlineText(text)
                .font(TypographyToken.body.font)
                .foregroundStyle(theme.color(.onBackgroundSecondary))
        }
        .padding(.vertical, SpacingToken.xs.rawValue)
        .accessibilityLabel("Blockquote: \(text)")
    }

    @ViewBuilder
    private func renderUnorderedList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: SpacingToken.sm.rawValue) {
                    Text("\u{2022}")
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                    renderInlineText(item)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackground))
                }
            }
        }
        .padding(.leading, SpacingToken.md.rawValue)
    }

    @ViewBuilder
    private func renderOrderedList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .firstTextBaseline, spacing: SpacingToken.sm.rawValue) {
                    Text("\(index + 1).")
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                        .frame(minWidth: 20, alignment: .trailing)
                    renderInlineText(item)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackground))
                }
            }
        }
        .padding(.leading, SpacingToken.md.rawValue)
    }

    @ViewBuilder
    private func renderImage(alt: String, url: String) -> some View {
        if let imageURL = URL(string: url) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.md.rawValue))
                        .accessibilityLabel(alt)
                case .failure:
                    Label(alt.isEmpty ? "Image" : alt, systemImage: "photo")
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                default:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 100)
                }
            }
        }
    }
}
