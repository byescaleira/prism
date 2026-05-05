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

// MARK: - Block Model

package enum MarkdownBlock: Sendable {
    case heading(level: Int, text: String)
    case paragraph(text: String)
    case codeBlock(language: String, code: String)
    case blockquote(text: String)
    case unorderedList(items: [String])
    case orderedList(items: [String])
    case horizontalRule
    case image(alt: String, url: String)
}

/// A SwiftUI view that renders a Markdown string using PrismUI design tokens.
@MainActor
public struct PrismMarkdownView: View {
    @Environment(\.prismTheme) package var theme

    private let markdown: String
    private let style: PrismMarkdownStyle

    /// Creates a markdown renderer with the given content and style.
    public init(_ markdown: String, style: PrismMarkdownStyle = .default) {
        self.markdown = markdown
        self.style = style
    }

    /// The view body.
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

    // MARK: - Parser

    package func parseBlocks() -> [MarkdownBlock] {
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
                while index < lines.count && !lines[index].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
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
            if trimmed.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
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

    package func extractBracketContent(_ text: String, open: String, close: String) -> String {
        guard let openRange = text.range(of: open),
            let closeRange = text.range(of: close, range: openRange.upperBound..<text.endIndex)
        else { return "" }
        return String(text[openRange.upperBound..<closeRange.lowerBound])
    }
}
