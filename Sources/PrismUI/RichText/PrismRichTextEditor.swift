import SwiftUI

/// Formatting operations available in the rich text editor.
public enum PrismTextFormatting: Sendable, Hashable {
    /// Bold text.
    case bold
    /// Italic text.
    case italic
    /// Underlined text.
    case underline
    /// Strikethrough text.
    case strikethrough
    /// Monospaced code span.
    case code
    /// Heading at the given level (1-6).
    case heading(Int)
    /// Hyperlink to the given URL.
    case link(URL)
    /// Unordered bullet list.
    case bulletList
    /// Ordered numbered list.
    case numberedList
}

/// A rich text editor view backed by AttributedString with formatting support.
@MainActor
public struct PrismRichTextEditor: View {
    @Environment(\.prismTheme) private var theme

    @Binding private var text: AttributedString
    @State private var showLinkSheet = false
    @State private var linkURLString = ""

    /// Creates a rich text editor bound to the given attributed string.
    public init(text: Binding<AttributedString>) {
        self._text = text
    }

    /// The view body.
    public var body: some View {
        VStack(spacing: 0) {
            PrismFormattingToolbar(
                onFormat: { formatting in
                    applyFormatting(formatting)
                }
            )

            TextEditor(text: plainTextBinding)
                .font(TypographyToken.body.font)
                .foregroundStyle(theme.color(.onBackground))
                .scrollContentBackground(.hidden)
                .background(theme.color(.surface))
                .clipShape(
                    RoundedRectangle(cornerRadius: RadiusToken.md.rawValue)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: RadiusToken.md.rawValue)
                        .stroke(theme.color(.border), lineWidth: 1)
                )
                .padding(.horizontal, SpacingToken.sm.rawValue)
                .padding(.bottom, SpacingToken.sm.rawValue)
                .accessibilityLabel("Rich text editor")
        }
        .background(theme.color(.background))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.lg.rawValue))
        .sheet(isPresented: $showLinkSheet) {
            linkInputSheet
        }
    }

    // MARK: - Plain Text Bridge

    private var plainTextBinding: Binding<String> {
        Binding<String>(
            get: { String(text.characters) },
            set: { newValue in
                text = AttributedString(newValue)
            }
        )
    }

    // MARK: - Formatting

    private func applyFormatting(_ formatting: PrismTextFormatting) {
        switch formatting {
        case .bold:
            applyFont(.body.bold())
        case .italic:
            applyFont(.body.italic())
        case .underline:
            var container = AttributeContainer()
            container.underlineStyle = .single
            text.mergeAttributes(container)
        case .strikethrough:
            var container = AttributeContainer()
            container.strikethroughStyle = .single
            text.mergeAttributes(container)
        case .code:
            let current = String(text.characters)
            text = AttributedString("`\(current)`")
        case .heading(let level):
            let prefix = String(repeating: "#", count: min(max(level, 1), 6)) + " "
            let current = String(text.characters)
            text = AttributedString(prefix + current)
        case .link(let url):
            var container = AttributeContainer()
            container.link = url
            text.mergeAttributes(container)
        case .bulletList:
            let current = String(text.characters)
            let lines = current.components(separatedBy: "\n")
            let bulleted = lines.map { "- \($0)" }.joined(separator: "\n")
            text = AttributedString(bulleted)
        case .numberedList:
            let current = String(text.characters)
            let lines = current.components(separatedBy: "\n")
            let numbered = lines.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
            text = AttributedString(numbered)
        }
    }

    private func applyFont(_ font: Font) {
        var container = AttributeContainer()
        container.swiftUI.font = font
        text.mergeAttributes(container)
    }

    // MARK: - Link Sheet

    @ViewBuilder
    private var linkInputSheet: some View {
        NavigationStack {
            Form {
                Section("URL") {
                    TextField("https://example.com", text: $linkURLString)
                        #if canImport(UIKit) && !os(watchOS)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                        #endif
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Insert Link")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showLinkSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Insert") {
                        if let url = URL(string: linkURLString) {
                            applyFormatting(.link(url))
                        }
                        showLinkSheet = false
                        linkURLString = ""
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

/// A horizontal toolbar providing formatting buttons for rich text editing.
@MainActor
public struct PrismFormattingToolbar: View {
    @Environment(\.prismTheme) private var theme

    private let onFormat: @MainActor (PrismTextFormatting) -> Void

    /// Creates a formatting toolbar that calls the given closure on button tap.
    public init(onFormat: @escaping @MainActor (PrismTextFormatting) -> Void) {
        self.onFormat = onFormat
    }

    /// The view body.
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpacingToken.xs.rawValue) {
                formatButton(icon: "bold", label: "Bold", formatting: .bold)
                formatButton(icon: "italic", label: "Italic", formatting: .italic)
                formatButton(icon: "underline", label: "Underline", formatting: .underline)
                formatButton(icon: "strikethrough", label: "Strikethrough", formatting: .strikethrough)
                formatButton(icon: "chevron.left.forwardslash.chevron.right", label: "Code", formatting: .code)
                formatButton(icon: "list.bullet", label: "Bullet List", formatting: .bulletList)
                formatButton(icon: "list.number", label: "Numbered List", formatting: .numberedList)
            }
            .padding(.horizontal, SpacingToken.sm.rawValue)
            .padding(.vertical, SpacingToken.xs.rawValue)
        }
        .background(theme.color(.surfaceSecondary))
        .accessibilityLabel("Formatting toolbar")
    }

    @ViewBuilder
    private func formatButton(icon: String, label: String, formatting: PrismTextFormatting) -> some View {
        Button {
            onFormat(formatting)
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(theme.color(.onSurface))
                .frame(width: 36, height: 36)
                .background(theme.color(.surface))
                .clipShape(RoundedRectangle(cornerRadius: RadiusToken.sm.rawValue))
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}
