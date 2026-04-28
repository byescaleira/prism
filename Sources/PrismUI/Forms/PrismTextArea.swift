import SwiftUI

/// Multi-line text input with character count and configurable height.
public struct PrismTextArea: View {
    @Environment(\.prismTheme) private var theme
    @FocusState private var isFocused: Bool

    @Binding private var text: String
    private let title: LocalizedStringKey
    private let maxCharacters: Int?
    private let minHeight: CGFloat

    public init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        maxCharacters: Int? = nil,
        minHeight: CGFloat = 100
    ) {
        self.title = title
        self._text = text
        self.maxCharacters = maxCharacters
        self.minHeight = minHeight
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            TextEditor(text: $text)
                .font(TypographyToken.body.font)
                .foregroundStyle(theme.color(.onSurface))
                .scrollContentBackground(.hidden)
                .frame(minHeight: minHeight)
                .padding(SpacingToken.md.rawValue)
                .background(theme.color(.surfaceSecondary), in: RadiusToken.md.shape)
                .overlay(
                    RadiusToken.md.shape
                        .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
                )
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    if let maxCharacters, newValue.count > maxCharacters {
                        text = String(newValue.prefix(maxCharacters))
                    }
                }
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(title)
                            .font(TypographyToken.body.font)
                            .foregroundStyle(theme.color(.onBackgroundTertiary))
                            .padding(SpacingToken.md.rawValue)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }

            if let maxCharacters {
                HStack {
                    Spacer()
                    Text("\(text.count)/\(maxCharacters)")
                        .font(TypographyToken.caption.font)
                        .foregroundStyle(isOverLimit ? theme.color(.error) : theme.color(.onBackgroundTertiary))
                }
            }
        }
        .accessibilityLabel(title)
    }

    private var borderColor: Color {
        if isOverLimit {
            return theme.color(.error)
        }
        return isFocused ? theme.color(.interactive) : theme.color(.borderSubtle)
    }

    private var isOverLimit: Bool {
        guard let maxCharacters else { return false }
        return text.count >= maxCharacters
    }
}
