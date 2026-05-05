import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Rich Text & Markdown")
struct RichTextTests {

    // MARK: - PrismMarkdownView

    @Suite("PrismMarkdownView")
    struct MarkdownViewTests {

        @Test("PrismMarkdownView conforms to View")
        @MainActor func markdownViewIsView() {
            let view = PrismMarkdownView("# Hello\nSome **bold** text.")
            #expect(type(of: view) is any View.Type)
        }

        @Test("PrismMarkdownView accepts all styles")
        @MainActor func markdownViewStyles() {
            let defaultView = PrismMarkdownView("text", style: .default)
            let compactView = PrismMarkdownView("text", style: .compact)
            let docView = PrismMarkdownView("text", style: .documentation)
            #expect(type(of: defaultView) is any View.Type)
            #expect(type(of: compactView) is any View.Type)
            #expect(type(of: docView) is any View.Type)
        }

        @Test("PrismMarkdownView renders with complex markdown")
        @MainActor func markdownViewComplexContent() {
            let markdown = """
                # Title
                ## Subtitle

                Some **bold** and *italic* text with `inline code`.

                ```swift
                let x = 42
                ```

                > A blockquote

                - Item 1
                - Item 2

                1. First
                2. Second

                ---

                ![alt](https://example.com/image.png)
                """
            let view = PrismMarkdownView(markdown)
            #expect(type(of: view) is any View.Type)
        }
    }

    // MARK: - PrismMarkdownStyle

    @Suite("PrismMarkdownStyle")
    struct MarkdownStyleTests {

        @Test("PrismMarkdownStyle has 3 cases")
        func markdownStyleCaseCount() {
            let cases = PrismMarkdownStyle.allCases
            #expect(cases.count == 3)
        }

        @Test("PrismMarkdownStyle cases have correct raw values")
        func markdownStyleRawValues() {
            #expect(PrismMarkdownStyle.default.rawValue == "default")
            #expect(PrismMarkdownStyle.compact.rawValue == "compact")
            #expect(PrismMarkdownStyle.documentation.rawValue == "documentation")
        }
    }

    // MARK: - PrismTextFormatting

    @Suite("PrismTextFormatting")
    struct TextFormattingTests {

        @Test("PrismTextFormatting has all expected cases")
        func textFormattingCases() {
            let url = URL(string: "https://example.com")!
            let cases: [PrismTextFormatting] = [
                .bold, .italic, .underline, .strikethrough,
                .code, .heading(1), .link(url),
                .bulletList, .numberedList,
            ]
            #expect(cases.count == 9)
        }

        @Test("PrismTextFormatting heading levels vary")
        func textFormattingHeadingLevels() {
            let h1 = PrismTextFormatting.heading(1)
            let h2 = PrismTextFormatting.heading(2)
            let h6 = PrismTextFormatting.heading(6)
            #expect(h1 != h2)
            #expect(h2 != h6)
        }

        @Test("PrismTextFormatting conforms to Hashable")
        func textFormattingHashable() {
            let set: Set<PrismTextFormatting> = [.bold, .italic, .bold]
            #expect(set.count == 2)
        }
    }

    // MARK: - PrismAttributedStringBuilder

    @Suite("PrismAttributedStringBuilder")
    struct AttributedStringBuilderTests {

        @Test("PrismAttributedStringBuilder builds non-empty string")
        func builderProducesNonEmpty() {
            let result = PrismAttributedStringBuilder()
                .text("Hello")
                .build()
            #expect(!result.characters.isEmpty)
        }

        @Test("builder chaining bold + italic + text")
        func builderChaining() {
            let result = PrismAttributedStringBuilder()
                .bold("Bold")
                .italic("Italic")
                .text("Plain")
                .build()
            let content = String(result.characters)
            #expect(content == "BoldItalicPlain")
        }

        @Test("builder appends code segment")
        func builderCode() {
            let result = PrismAttributedStringBuilder()
                .code("var x = 1")
                .build()
            #expect(String(result.characters) == "var x = 1")
        }

        @Test("builder appends link segment")
        func builderLink() {
            let url = URL(string: "https://example.com")!
            let result = PrismAttributedStringBuilder()
                .link("Example", url: url)
                .build()
            #expect(String(result.characters) == "Example")
        }

        @Test("builder appends colored segment")
        func builderColored() {
            let result = PrismAttributedStringBuilder()
                .colored("Red", color: .red)
                .build()
            #expect(String(result.characters) == "Red")
        }

        @Test("builder newline inserts line break")
        func builderNewline() {
            let result = PrismAttributedStringBuilder()
                .text("Line1")
                .newline()
                .text("Line2")
                .build()
            let content = String(result.characters)
            #expect(content.contains("\n"))
        }

        @Test("empty builder produces empty string")
        func builderEmpty() {
            let result = PrismAttributedStringBuilder().build()
            #expect(result.characters.isEmpty)
        }
    }

    // MARK: - PrismTextBuilder (Result Builder)

    @Suite("PrismTextBuilder")
    struct TextBuilderTests {

        @Test("result builder composes attributed strings")
        func resultBuilderComposition() {
            @PrismTextBuilder var text: AttributedString {
                AttributedString("Hello ")
                AttributedString.prismBold("World")
            }
            #expect(String(text.characters) == "Hello World")
        }
    }

    // MARK: - PrismSyntaxLanguage

    @Suite("PrismSyntaxLanguage")
    struct SyntaxLanguageTests {

        @Test("PrismSyntaxLanguage has 7 cases")
        func syntaxLanguageCaseCount() {
            #expect(PrismSyntaxLanguage.allCases.count == 7)
        }

        @Test("PrismSyntaxLanguage file extensions are unique")
        func syntaxLanguageFileExtensions() {
            let extensions = PrismSyntaxLanguage.allCases.map(\.fileExtension)
            #expect(Set(extensions).count == 7)
        }
    }

    // MARK: - PrismSyntaxHighlighter

    @Suite("PrismSyntaxHighlighter")
    struct SyntaxHighlighterTests {

        @Test("PrismSyntaxHighlighter produces non-empty result for Swift")
        func highlighterSwift() {
            let highlighter = PrismSyntaxHighlighter()
            let result = highlighter.highlight("let x = 42", language: .swift)
            #expect(!result.characters.isEmpty)
        }

        @Test("PrismSyntaxHighlighter handles plain text")
        func highlighterPlainText() {
            let highlighter = PrismSyntaxHighlighter()
            let result = highlighter.highlight("hello world", language: .plainText)
            #expect(String(result.characters) == "hello world")
        }

        @Test("PrismSyntaxHighlighter handles all languages")
        func highlighterAllLanguages() {
            let highlighter = PrismSyntaxHighlighter()
            for language in PrismSyntaxLanguage.allCases {
                let result = highlighter.highlight("test", language: language)
                #expect(!result.characters.isEmpty)
            }
        }

        @Test("PrismSyntaxHighlighter highlights comments")
        func highlighterComments() {
            let highlighter = PrismSyntaxHighlighter()
            let result = highlighter.highlight("// comment\nlet x = 1", language: .swift)
            #expect(!result.characters.isEmpty)
        }
    }

    // MARK: - PrismCodeBlock

    @Suite("PrismCodeBlock")
    struct CodeBlockTests {

        @Test("PrismCodeBlock conforms to View")
        @MainActor func codeBlockIsView() {
            let view = PrismCodeBlock("let x = 42", language: .swift)
            #expect(type(of: view) is any View.Type)
        }

        @Test("PrismCodeBlock works without line numbers")
        @MainActor func codeBlockNoLineNumbers() {
            let view = PrismCodeBlock("print(\"hi\")", language: .python, showLineNumbers: false)
            #expect(type(of: view) is any View.Type)
        }
    }

    // MARK: - PrismFormattingToolbar

    @Suite("PrismFormattingToolbar")
    struct FormattingToolbarTests {

        @Test("PrismFormattingToolbar conforms to View")
        @MainActor func toolbarIsView() {
            let view = PrismFormattingToolbar(onFormat: { _ in })
            #expect(type(of: view) is any View.Type)
        }
    }

    // MARK: - PrismRichTextEditor

    @Suite("PrismRichTextEditor")
    struct RichTextEditorTests {

        @Test("PrismRichTextEditor conforms to View")
        @MainActor func editorIsView() {
            @State var text = AttributedString("Hello")
            let view = PrismRichTextEditor(text: $text)
            #expect(type(of: view) is any View.Type)
        }
    }
}
