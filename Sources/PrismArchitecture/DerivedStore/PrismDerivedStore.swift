//
//  PrismDerivedStore.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import Observation

/// A read-only view into a parent store that only notifies when the derived value changes.
@MainActor
@Observable
public final class PrismDerivedStore<ParentState: PrismState, LocalState: Equatable & Sendable> {
    /// The current derived value projected from the parent store.
    public private(set) var value: LocalState

    @ObservationIgnored
    private let transform: @MainActor @Sendable (ParentState) -> LocalState

    /// Creates a derived store with an initial parent state and a transform function.
    public init(
        initialState: ParentState,
        transform: @escaping @MainActor @Sendable (ParentState) -> LocalState
    ) {
        self.transform = transform
        self.value = transform(initialState)
    }

    /// Updates the derived value from a new parent state, notifying only when it changes.
    public func update(from parentState: ParentState) {
        let newValue = transform(parentState)
        if newValue != value {
            value = newValue
        }
    }
}

// MARK: - PrismStore derive extension

extension PrismStore {
    /// Creates a read-only derived store that projects a sub-value from this store's state.
    public func derive<LocalState: Equatable & Sendable>(
        _ transform: @escaping @MainActor @Sendable (State) -> LocalState
    ) -> PrismDerivedStore<State, LocalState> where State: PrismState {
        PrismDerivedStore(
            initialState: state,
            transform: transform
        )
    }
}

// MARK: - Scoped Store

/// A scoped store that maps parent actions to child actions for sub-feature isolation.
@MainActor
@Observable
public final class PrismStoreScope<ParentState: PrismState, LocalState: Equatable & Sendable, LocalAction: Sendable> {
    /// The current scoped state value.
    public private(set) var state: LocalState

    @ObservationIgnored
    private let toLocalState: @MainActor @Sendable (ParentState) -> LocalState

    @ObservationIgnored
    private let sendAction: @MainActor @Sendable (LocalAction) -> Void

    /// Creates a scoped store bridging parent and child state and actions.
    public init(
        parentState: ParentState,
        toLocalState: @escaping @MainActor @Sendable (ParentState) -> LocalState,
        sendAction: @escaping @MainActor @Sendable (LocalAction) -> Void
    ) {
        self.toLocalState = toLocalState
        self.sendAction = sendAction
        self.state = toLocalState(parentState)
    }

    /// Sends a local action to the parent store via the action mapping.
    public func send(_ action: LocalAction) {
        sendAction(action)
    }

    /// Updates the scoped state from a new parent state.
    public func update(from parentState: ParentState) {
        let newState = toLocalState(parentState)
        if newState != state {
            state = newState
        }
    }
}
