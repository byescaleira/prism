import SwiftUI

// MARK: - Markdown Renderers

extension PrismMarkdownView {

    // MARK: - Block Renderer

    @ViewBuilder
    package func renderBlock(_ block: MarkdownBlock) -> some View {
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
    package func renderHeading(level: Int, text: String) -> some View {
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

    package func renderInlineText(_ text: String) -> Text {
        parseInlineElements(text)
    }

    package func parseInlineElements(_ text: String) -> Text {
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
    package func renderCodeBlock(_ code: String) -> some View {
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
    package func renderBlockquote(_ text: String) -> some View {
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
    package func renderUnorderedList(_ items: [String]) -> some View {
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
    package func renderOrderedList(_ items: [String]) -> some View {
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
    package func renderImage(alt: String, url: String) -> some View {
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
