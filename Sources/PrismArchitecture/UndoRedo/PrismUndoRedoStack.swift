//
//  PrismUndoRedoStack.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import Observation

/// A stack-based undo/redo manager for state snapshots.
@MainActor
@Observable
public final class PrismUndoRedoStack<State: PrismState> {
    /// Past states available for undo, most recent last.
    public private(set) var undoStack: [State] = []

    /// States available for redo after an undo, most recent last.
    public private(set) var redoStack: [State] = []

    /// The maximum number of states retained in the undo stack.
    public let maxStackSize: Int

    /// Whether there is at least one state to undo to.
    public var canUndo: Bool {
        !undoStack.isEmpty
    }

    /// Whether there is at least one state to redo to.
    public var canRedo: Bool {
        !redoStack.isEmpty
    }

    /// Creates an undo/redo stack with the given capacity.
    public init(maxStackSize: Int = 50) {
        self.maxStackSize = maxStackSize
    }

    /// Pushes the current state onto the undo stack before a mutation.
    public func push(_ state: State) {
        undoStack.append(state)
        redoStack.removeAll()

        // Evict the oldest entry when over capacity
        if undoStack.count > maxStackSize {
            undoStack.removeFirst()
        }
    }

    /// Pops the most recent state from the undo stack and returns it.
    public func undo() -> State? {
        guard let state = undoStack.popLast() else { return nil }
        redoStack.append(state)
        return state
    }

    /// Pops the most recent state from the redo stack and returns it.
    public func redo() -> State? {
        guard let state = redoStack.popLast() else { return nil }
        undoStack.append(state)
        return state
    }

    /// Empties both the undo and redo stacks.
    public func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
}
