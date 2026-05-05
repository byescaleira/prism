import SwiftUI

/// Themed password field with visibility toggle.
public struct PrismSecureField: View {
    @Environment(\.prismTheme) private var theme
    @FocusState private var isFocused: Bool

    @Binding private var text: String
    private let title: LocalizedStringKey

    @State private var isRevealed = false

    /// Creates a secure field with title and password visibility toggle.
    public init(_ title: LocalizedStringKey, text: Binding<String>) {
        self.title = title
        self._text = text
    }

    /// The secure field view body with reveal toggle and focus border.
    public var body: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            Group {
                if isRevealed {
                    TextField(title, text: $text)
                } else {
                    SecureField(title, text: $text)
                }
            }
            .font(TypographyToken.body.font)
            .foregroundStyle(theme.color(.onSurface))
            .focused($isFocused)

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .font(.system(size: 16))
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
        }
        .padding(.horizontal, SpacingToken.lg.rawValue)
        .padding(.vertical, SpacingToken.md.rawValue)
        .frame(minHeight: 44)
        .background(theme.color(.surfaceSecondary), in: RadiusToken.md.shape)
        .overlay(
            RadiusToken.md.shape
                .stroke(
                    isFocused ? theme.color(.interactive) : theme.color(.borderSubtle),
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}
