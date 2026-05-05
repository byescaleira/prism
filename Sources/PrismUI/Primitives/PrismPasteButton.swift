import SwiftUI
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

/// Themed paste button.
///
/// ```swift
/// PrismPasteButton(payloadType: String.self) { strings in
///     text = strings.first ?? ""
/// }
/// ```
public struct PrismPasteButton: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    private let action: ([String]) -> Void

    /// Creates a paste button with a title and action receiving pasted strings.
    public init(
        _ title: LocalizedStringKey = "Paste",
        action: @escaping ([String]) -> Void
    ) {
        self.title = title
        self.action = action
    }

    /// The content and behavior of the paste button.
    public var body: some View {
        #if os(macOS) || os(iOS)
        PasteButton(payloadType: String.self) { strings in
            action(strings)
        }
        .tint(theme.color(.interactive))
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        #else
        Button(title) {
            action([])
        }
        .foregroundStyle(theme.color(.interactive))
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        #endif
    }
}
