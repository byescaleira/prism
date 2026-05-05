import SwiftUI

/// Modifier that registers undo/redo operations for value changes.
///
/// ```swift
/// @State private var text = ""
///
/// TextField("Name", text: $text)
///     .prismUndoable($text, actionName: "Edit Name")
/// ```
private struct PrismUndoModifier<Value: Equatable>: ViewModifier {
    @Environment(\.undoManager) private var undoManager
    @Binding var value: Value
    let actionName: String
    @State private var previousValue: Value?

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { oldValue, newValue in
                guard let undoManager else { return }
                let captured = oldValue
                undoManager.registerUndo(withTarget: UndoTarget.shared) { _ in
                    let current = self.value
                    self.value = captured
                    undoManager.registerUndo(withTarget: UndoTarget.shared) { _ in
                        self.value = current
                    }
                    undoManager.setActionName(actionName)
                }
                undoManager.setActionName(actionName)
            }
    }
}

/// Shared undo target for NSObject-based undo manager.
private final class UndoTarget: NSObject, @unchecked Sendable {
    static let shared = UndoTarget()
}

/// Undo toolbar buttons for quick access.
public struct PrismUndoButtons: View {
    @Environment(\.undoManager) private var undoManager
    @Environment(\.prismTheme) private var theme

    /// Creates undo/redo toolbar buttons.
    public init() {}

    /// The content and behavior of the undo buttons.
    public var body: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            Button {
                undoManager?.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 16, weight: .medium))
            }
            .disabled(!(undoManager?.canUndo ?? false))

            Button {
                undoManager?.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 16, weight: .medium))
            }
            .disabled(!(undoManager?.canRedo ?? false))
        }
        .foregroundStyle(theme.color(.interactive))
    }
}

extension View {

    /// Registers undo/redo for changes to binding value.
    public func prismUndoable<Value: Equatable>(
        _ value: Binding<Value>,
        actionName: String = "Change"
    ) -> some View {
        modifier(PrismUndoModifier(value: value, actionName: actionName))
    }
}
