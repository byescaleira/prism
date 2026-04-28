import SwiftUI

/// Keyboard shortcut descriptor for Prism components.
///
/// Wraps SwiftUI `KeyboardShortcut` with display-friendly metadata.
public struct PrismShortcut: Sendable {
    public let key: KeyEquivalent
    public let modifiers: EventModifiers
    public let title: String

    public init(_ key: KeyEquivalent, modifiers: EventModifiers = .command, title: String) {
        self.key = key
        self.modifiers = modifiers
        self.title = title
    }
}

// MARK: - Common Presets

extension PrismShortcut {
    public static let save = PrismShortcut("s", modifiers: .command, title: "Save")
    public static let undo = PrismShortcut("z", modifiers: .command, title: "Undo")
    public static let redo = PrismShortcut("z", modifiers: [.command, .shift], title: "Redo")
    public static let delete = PrismShortcut(.delete, modifiers: .command, title: "Delete")
    public static let search = PrismShortcut("f", modifiers: .command, title: "Search")
    public static let newItem = PrismShortcut("n", modifiers: .command, title: "New")
    public static let refresh = PrismShortcut("r", modifiers: .command, title: "Refresh")
    public static let close = PrismShortcut("w", modifiers: .command, title: "Close")
}

// MARK: - View Modifier

private struct PrismKeyboardShortcutModifier: ViewModifier {
    let shortcut: PrismShortcut

    func body(content: Content) -> some View {
        content
            .keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
    }
}

extension View {

    /// Applies a Prism keyboard shortcut to a view.
    public func prismKeyboardShortcut(_ shortcut: PrismShortcut) -> some View {
        modifier(PrismKeyboardShortcutModifier(shortcut: shortcut))
    }
}

// MARK: - Shortcut Group

/// Groups keyboard shortcuts for display in command menus (macOS/iPadOS).
///
/// ```swift
/// PrismShortcutGroup("Edit") {
///     Button("Save") { save() }
///         .prismKeyboardShortcut(.save)
///     Button("Undo") { undo() }
///         .prismKeyboardShortcut(.undo)
/// }
/// ```
public struct PrismShortcutGroup<Content: View>: View {
    private let title: LocalizedStringKey
    private let content: Content

    public init(
        _ title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        content
    }
}
