import Combine
import SwiftUI

/// Themed search bar with debounce and clear button.
public struct PrismSearchBar: View {
    @Environment(\.prismTheme) private var theme
    @FocusState private var isFocused: Bool

    @Binding private var text: String
    private let placeholder: LocalizedStringKey
    private let debounce: Duration
    private let onSubmit: (() -> Void)?

    @State private var debouncedText = ""
    @State private var debounceTask: Task<Void, Never>?

    public init(
        text: Binding<String>,
        placeholder: LocalizedStringKey = "Search",
        debounce: Duration = .milliseconds(300),
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.debounce = debounce
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(theme.color(.onBackgroundSecondary))

            TextField(placeholder, text: $text)
                .font(TypographyToken.body.font)
                .foregroundStyle(theme.color(.onSurface))
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }
                .onChange(of: text) { _, newValue in
                    scheduleDebounce(newValue)
                }

            if !text.isEmpty {
                Button {
                    text = ""
                    isFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(theme.color(.onBackgroundTertiary))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, SpacingToken.md.rawValue)
        .padding(.vertical, SpacingToken.sm.rawValue)
        .frame(minHeight: 36)
        .background(theme.color(.surfaceSecondary), in: RadiusToken.lg.shape)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(placeholder)
    }

    private func scheduleDebounce(_ value: String) {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            debouncedText = value
        }
    }
}
