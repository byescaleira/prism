import SwiftUI

/// OTP/PIN code input with individual character cells.
public struct PrismPinField: View {
    @Environment(\.prismTheme) private var theme
    @FocusState private var isFocused: Bool

    @Binding private var code: String
    private let length: Int
    private let isSecure: Bool

    public init(
        code: Binding<String>,
        length: Int = 6,
        isSecure: Bool = false
    ) {
        self._code = code
        self.length = length
        self.isSecure = isSecure
    }

    public var body: some View {
        ZStack {
            hiddenTextField
            cellRow
        }
        .accessibilityElement()
        .accessibilityLabel(Text(verbatim: "\(String.prismPinEntry), \(length) digits"))
        .accessibilityValue(code.isEmpty ? String.prismEmpty : "\(code.count) of \(length) entered")
    }

    private var hiddenTextField: some View {
        TextField("", text: $code)
            .focused($isFocused)
            #if canImport(UIKit) && !os(watchOS)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            #endif
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .onChange(of: code) { _, newValue in
                let filtered = String(newValue.filter { $0.isNumber }.prefix(length))
                if filtered != newValue {
                    code = filtered
                }
            }
    }

    private var cellRow: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            ForEach(0..<length, id: \.self) { index in
                cell(at: index)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }

    @ViewBuilder
    private func cell(at index: Int) -> some View {
        let character = characterAt(index)
        let isCurrentIndex = code.count == index && isFocused

        ZStack {
            if let character {
                if isSecure {
                    Circle()
                        .fill(theme.color(.onSurface))
                        .frame(width: 12, height: 12)
                } else {
                    Text(String(character))
                        .font(TypographyToken.title2.font(weight: .semibold))
                        .foregroundStyle(theme.color(.onSurface))
                }
            } else if isCurrentIndex {
                Rectangle()
                    .fill(theme.color(.interactive))
                    .frame(width: 2, height: 24)
            }
        }
        .frame(width: 48, height: 56)
        .background(theme.color(.surfaceSecondary), in: RadiusToken.md.shape)
        .overlay(
            RadiusToken.md.shape
                .stroke(
                    isCurrentIndex ? theme.color(.interactive) :
                        (character != nil ? theme.color(.border) : theme.color(.borderSubtle)),
                    lineWidth: isCurrentIndex ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.15), value: character != nil)
    }

    private func characterAt(_ index: Int) -> Character? {
        guard index < code.count else { return nil }
        return code[code.index(code.startIndex, offsetBy: index)]
    }
}
