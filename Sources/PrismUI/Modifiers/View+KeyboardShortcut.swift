import SwiftUI

/// Keyboard shortcut descriptor for Prism components.
///
/// Wraps SwiftUI `KeyboardShortcut` with display-friendly metadata.
public struct PrismShortcut: Sendable {
    /// The keyboard key for the shortcut.
    public let key: KeyEquivalent
    /// The modifier keys required for the shortcut.
    public let modifiers: EventModifiers
    /// A human-readable title describing the shortcut action.
    public let title: String

    /// Creates a shortcut with a key, modifiers, and descriptive title.
    public init(_ key: KeyEquivalent, modifiers: EventModifiers = .command, title: String) {
        self.key = key
        self.modifiers = modifiers
        self.title = title
    }
}

// MARK: - Common Presets

extension PrismShortcut {
    /// Preset shortcut for save (Cmd+S).
    public static let save = PrismShortcut("s", modifiers: .command, title: "Save")
    /// Preset shortcut for undo (Cmd+Z).
    public static let undo = PrismShortcut("z", modifiers: .command, title: "Undo")
    /// Preset shortcut for redo (Cmd+Shift+Z).
    public static let redo = PrismShortcut("z", modifiers: [.command, .shift], title: "Redo")
    /// Preset shortcut for delete (Cmd+Delete).
    public static let delete = PrismShortcut(.delete, modifiers: .command, title: "Delete")
    /// Preset shortcut for search (Cmd+F).
    public static let search = PrismShortcut("f", modifiers: .command, title: "Search")
    /// Preset shortcut for new item (Cmd+N).
    public static let newItem = PrismShortcut("n", modifiers: .command, title: "New")
    /// Preset shortcut for refresh (Cmd+R).
    public static let refresh = PrismShortcut("r", modifiers: .command, title: "Refresh")
    /// Preset shortcut for close (Cmd+W).
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

    /// Creates a shortcut group with a title and grouped shortcut content.
    public init(
        _ title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    /// The content and behavior of the shortcut group.
    public var body: some View {
        content
    }
}
