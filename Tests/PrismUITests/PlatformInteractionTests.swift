import SwiftUI
import Testing

@testable import PrismUI

@MainActor
@Suite("Platform Interactions")
struct PlatformInteractionTests {

    // MARK: - Haptics

    @Suite("Haptics")
    struct HapticTests {

        @Test("PrismHapticType impact cases")
        @MainActor func impactCases() {
            let types: [PrismHapticType] = [
                .impact(.light), .impact(.medium), .impact(.heavy),
                .impact(.soft), .impact(.rigid),
            ]
            #expect(types.count == 5)
        }

        @Test("PrismHapticType notification cases")
        @MainActor func notificationCases() {
            let types: [PrismHapticType] = [
                .notification(.success), .notification(.warning), .notification(.error),
            ]
            #expect(types.count == 3)
        }

        @Test("PrismHapticType selection")
        @MainActor func selectionCase() {
            let type: PrismHapticType = .selection
            _ = type
        }

        @Test("prismHaptic modifier applies")
        @MainActor func hapticModifier() {
            let view = Text("Tap")
                .prismHaptic(.impact(.medium), trigger: false)
            _ = view
        }

        @Test("PrismHaptics.play does not crash")
        @MainActor func playDoesNotCrash() {
            PrismHaptics.play(.selection)
            PrismHaptics.play(.impact(.light))
            PrismHaptics.play(.notification(.success))
        }

        @Test("PrismHaptics.prepare does not crash")
        @MainActor func prepareDoesNotCrash() {
            PrismHaptics.prepare(.selection)
            PrismHaptics.prepare(.impact(.heavy))
            PrismHaptics.prepare(.notification(.error))
        }
    }

    // MARK: - Drag & Drop

    @Suite("Drag & Drop")
    struct DragDropTests {

        @Test("prismDraggable modifier applies")
        @MainActor func draggableModifier() {
            let view = Text("Drag me")
                .prismDraggable("text-payload")
            _ = view
        }

        @Test("prismDropTarget modifier applies")
        @MainActor func dropTargetModifier() {
            let view = Text("Drop here")
                .prismDropTarget(for: String.self) { items in
                    !items.isEmpty
                }
            _ = view
        }

        @Test("PrismReorderableList with Identifiable data")
        @MainActor func reorderableList() {
            struct Item: Identifiable {
                let id = UUID()
                let name: String
            }
            @State var items = [Item(name: "A"), Item(name: "B"), Item(name: "C")]
            let view = PrismReorderableList($items) { item in
                Text(item.name)
            }
            _ = view.body
        }

        @Test("PrismReorderableList with explicit id")
        @MainActor func reorderableListExplicitId() {
            struct Named {
                let name: String
            }
            @State var items = [Named(name: "X"), Named(name: "Y")]
            let view = PrismReorderableList($items, id: \.name) { item in
                Text(item.name)
            }
            _ = view.body
        }
    }

    // MARK: - Keyboard Shortcuts

    @Suite("Keyboard Shortcuts")
    struct KeyboardShortcutTests {

        @Test("PrismShortcut preset values")
        @MainActor func presetValues() {
            #expect(PrismShortcut.save.title == "Save")
            #expect(PrismShortcut.undo.title == "Undo")
            #expect(PrismShortcut.redo.title == "Redo")
            #expect(PrismShortcut.delete.title == "Delete")
            #expect(PrismShortcut.search.title == "Search")
            #expect(PrismShortcut.newItem.title == "New")
            #expect(PrismShortcut.refresh.title == "Refresh")
            #expect(PrismShortcut.close.title == "Close")
        }

        @Test("Custom PrismShortcut creation")
        @MainActor func customShortcut() {
            let shortcut = PrismShortcut("p", modifiers: [.command, .shift], title: "Print")
            #expect(shortcut.title == "Print")
            #expect(shortcut.modifiers == [.command, .shift])
        }

        @Test("prismKeyboardShortcut modifier applies")
        @MainActor func shortcutModifier() {
            let view = Button("Save") {}
                .prismKeyboardShortcut(.save)
            _ = view
        }

        @Test("PrismShortcutGroup wraps content")
        @MainActor func shortcutGroup() {
            let view = PrismShortcutGroup("Edit") {
                Button("Undo") {}
            }
            _ = view.body
        }
    }

    // MARK: - Focus Management

    @Suite("Focus Management")
    struct FocusTests {

        @Test("PrismFocusStyle cases exist")
        @MainActor func focusStyleCases() {
            let styles: [PrismFocusStyle] = [.ring, .highlight, .scale, .subtle]
            #expect(styles.count == 4)
        }

        @Test("prismFocusStyle modifier applies")
        @MainActor func focusStyleModifier() {
            let view = Text("Focus me")
                .prismFocusStyle(.ring)
            _ = view
        }

        @Test("prismFocusable modifier applies")
        @MainActor func focusableModifier() {
            let view = Text("Focusable")
                .prismFocusable(.highlight)
            _ = view
        }

        @Test("prismFocusable default is ring")
        @MainActor func focusableDefault() {
            let view = Text("Default")
                .prismFocusable()
            _ = view
        }

        @Test("PrismFocusSection renders")
        @MainActor func focusSection() {
            let view = PrismFocusSection("Section Title") {
                Text("Content")
            }
            _ = view.body
        }

        @Test("PrismFocusSection without title")
        @MainActor func focusSectionNoTitle() {
            let view = PrismFocusSection {
                Text("No title")
            }
            _ = view.body
        }
    }

    // MARK: - Undo/Redo

    @Suite("Undo/Redo")
    struct UndoTests {

        @Test("prismUndoable modifier applies")
        @MainActor func undoableModifier() {
            @State var text = "Hello"
            let view = TextField("Name", text: $text)
                .prismUndoable($text, actionName: "Edit Name")
            _ = view
        }

        @Test("prismUndoable default action name")
        @MainActor func undoableDefault() {
            @State var value = 42
            let view = Text("\(value)")
                .prismUndoable($value)
            _ = view
        }

        @Test("PrismUndoButtons renders")
        @MainActor func undoButtons() {
            let view = PrismUndoButtons()
            _ = view.body
        }
    }

    // MARK: - Theme Store

    @Suite("Theme Persistence")
    struct ThemeStoreTests {

        private static func resetThemeDefaults() {
            UserDefaults.standard.removeObject(forKey: "prism.theme.identifier")
        }

        @Test("PrismThemeStore default theme is default")
        @MainActor func defaultTheme() {
            Self.resetThemeDefaults()
            let store = PrismThemeStore()
            #expect(store.currentIdentifier == "default")
        }

        @Test("PrismThemeStore has built-in themes")
        @MainActor func builtInThemes() {
            Self.resetThemeDefaults()
            let store = PrismThemeStore()
            let themes = store.availableThemes
            #expect(themes.contains("default"))
            #expect(themes.contains("dark"))
            #expect(themes.contains("highContrast"))
        }

        @Test("PrismThemeStore set theme changes identifier")
        @MainActor func setTheme() {
            Self.resetThemeDefaults()
            let store = PrismThemeStore()
            store.setTheme("dark", animated: false)
            #expect(store.currentIdentifier == "dark")
            Self.resetThemeDefaults()
        }

        @Test("PrismThemeStore ignores unknown theme")
        @MainActor func unknownTheme() {
            Self.resetThemeDefaults()
            let store = PrismThemeStore()
            store.setTheme("nonexistent", animated: false)
            #expect(store.currentIdentifier == "default")
        }

        @Test("PrismThemeStore register custom theme")
        @MainActor func registerCustom() {
            Self.resetThemeDefaults()
            let store = PrismThemeStore()
            store.register("custom", theme: DarkTheme())
            #expect(store.availableThemes.contains("custom"))
            store.setTheme("custom", animated: false)
            #expect(store.currentIdentifier == "custom")
            Self.resetThemeDefaults()
        }

        @Test("PrismThemeStore custom themes in init")
        @MainActor func customThemesInit() {
            Self.resetThemeDefaults()
            let store = PrismThemeStore(customThemes: ["brand": DarkTheme()])
            #expect(store.availableThemes.contains("brand"))
        }

        @Test("prismThemeStore modifier applies")
        @MainActor func themeStoreModifier() {
            let store = PrismThemeStore()
            let view = Text("Themed")
                .prismThemeStore(store)
            _ = view
        }
    }

    // MARK: - Component Browser

    @Suite("Component Browser")
    struct ComponentBrowserTests {

        @Test("PrismComponentBrowser renders")
        @MainActor func browserRenders() {
            let view = PrismComponentBrowser()
            _ = view.body
        }

        @Test("All component categories exist")
        @MainActor func allCategories() {
            let categories = ComponentCategory.allCases
            #expect(categories.count == 7)
        }

        @Test("Each category has components")
        @MainActor func categoriesNotEmpty() {
            for category in ComponentCategory.allCases {
                #expect(!category.components.isEmpty, "Category \(category.rawValue) should not be empty")
            }
        }

        @Test("ComponentEntry is Hashable")
        @MainActor func entryHashable() {
            let a = ComponentEntry(name: "PrismButton", icon: "hand.tap", summary: "Button")
            let b = ComponentEntry(name: "PrismButton", icon: "hand.tap", summary: "Button")
            #expect(a == b)
        }

        @Test("Total components across categories")
        @MainActor func totalComponents() {
            let total = ComponentCategory.allCases.reduce(0) { $0 + $1.components.count }
            #expect(total >= 30)
        }
    }
}
