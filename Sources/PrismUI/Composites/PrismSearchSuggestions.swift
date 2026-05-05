import SwiftUI

/// Search bar with autocomplete suggestion dropdown.
///
/// ```swift
/// PrismSearchSuggestions(
///     text: $query,
///     suggestions: filteredItems
/// ) { item in
///     Text(item.name)
/// } onSelect: { item in
///     navigateTo(item)
/// }
/// ```
@MainActor
public struct PrismSearchSuggestions<Item: Identifiable & Sendable, Row: View>: View {
    @Environment(\.prismTheme) private var theme
    @FocusState private var isFocused: Bool

    @Binding private var text: String
    private let suggestions: [Item]
    private let placeholder: LocalizedStringKey
    private let maxSuggestions: Int
    private let row: (Item) -> Row
    private let onSelect: (Item) -> Void

    @State private var showSuggestions = false

    /// Creates a search bar with autocomplete suggestions and selection handler.
    public init(
        text: Binding<String>,
        suggestions: [Item],
        placeholder: LocalizedStringKey = "Search",
        maxSuggestions: Int = 5,
        @ViewBuilder row: @escaping (Item) -> Row,
        onSelect: @escaping (Item) -> Void
    ) {
        self._text = text
        self.suggestions = suggestions
        self.placeholder = placeholder
        self.maxSuggestions = maxSuggestions
        self.row = row
        self.onSelect = onSelect
    }

    /// The search suggestions view body with dropdown list.
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            searchField
            if showSuggestions && !visibleSuggestions.isEmpty {
                suggestionsList
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: showSuggestions)
        .onChange(of: text) { _, newValue in
            showSuggestions = !newValue.isEmpty && isFocused
        }
        .onChange(of: isFocused) { _, focused in
            showSuggestions = focused && !text.isEmpty
        }
    }

    private var visibleSuggestions: [Item] {
        Array(suggestions.prefix(maxSuggestions))
    }

    private var searchField: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(theme.color(.onBackgroundSecondary))

            TextField(placeholder, text: $text)
                .font(TypographyToken.body.font)
                .foregroundStyle(theme.color(.onSurface))
                .focused($isFocused)
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(theme.color(.onBackgroundTertiary))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, SpacingToken.md.rawValue)
        .padding(.vertical, SpacingToken.sm.rawValue)
        .frame(minHeight: 36)
        .background(theme.color(.surfaceSecondary), in: RadiusToken.lg.shape)
    }

    private var suggestionsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(visibleSuggestions) { item in
                Button {
                    onSelect(item)
                    showSuggestions = false
                    isFocused = false
                } label: {
                    row(item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, SpacingToken.md.rawValue)
                        .padding(.vertical, SpacingToken.sm.rawValue)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if item.id != visibleSuggestions.last?.id {
                    Divider().padding(.leading, SpacingToken.md.rawValue)
                }
            }
        }
        .background(theme.color(.surface), in: RadiusToken.md.shape)
        .prismElevation(.medium)
        .padding(.top, SpacingToken.xs.rawValue)
    }
}
