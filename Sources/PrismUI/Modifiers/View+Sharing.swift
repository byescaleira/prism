import SwiftUI

/// Themed share button using native ShareLink.
///
/// ```swift
/// PrismShareButton("Share Photo", item: imageURL, preview: SharePreview("My Photo"))
/// ```
public struct PrismShareButton<Data: Transferable>: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    private let item: Data
    private let preview: SharePreview<Never, Never>

    public init(
        _ title: LocalizedStringKey = "Share",
        item: Data,
        preview: SharePreview<Never, Never>
    ) {
        self.title = title
        self.item = item
        self.preview = preview
    }

    public var body: some View {
        ShareLink(item: item, preview: preview) {
            Label(title, systemImage: "square.and.arrow.up")
        }
        .foregroundStyle(theme.color(.interactive))
    }
}

extension PrismShareButton where Data == String {

    public init(
        _ title: LocalizedStringKey = "Share",
        text: String
    ) {
        self.title = title
        self.item = text
        self.preview = SharePreview(text)
    }
}

extension PrismShareButton where Data == URL {

    public init(
        _ title: LocalizedStringKey = "Share",
        url: URL
    ) {
        self.title = title
        self.item = url
        self.preview = SharePreview(url.lastPathComponent)
    }
}

// MARK: - Searchable

/// Searchable modifier wrapper with themed styling.
private struct PrismSearchableModifier: ViewModifier {
    @Binding var text: String
    let prompt: LocalizedStringKey
    let placement: SearchFieldPlacement

    func body(content: Content) -> some View {
        content
            .searchable(text: $text, placement: placement, prompt: prompt)
            .scrollDismissesKeyboard(.interactively)
    }
}

extension View {

    /// Adds a search field with themed styling and keyboard dismiss.
    public func prismSearchable(
        text: Binding<String>,
        prompt: LocalizedStringKey = "Search",
        placement: SearchFieldPlacement = .automatic
    ) -> some View {
        modifier(PrismSearchableModifier(text: text, prompt: prompt, placement: placement))
    }
}
