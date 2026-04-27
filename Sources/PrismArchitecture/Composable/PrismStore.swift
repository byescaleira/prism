//
//  PrismStore.swift
//  Prism
//
//  Created by Rafael Escaleira on 12/04/25.
//

import Foundation
import Observation

/// An observable store that holds application state and processes actions through reducers and middleware.
///
/// `PrismStore` is the central hub of the Prism architecture. It owns the current state,
/// applies actions via a reducer, executes asynchronous effects, and supports scoping
/// to derive child stores for sub-features.
///
/// ```swift
/// struct AppState: Sendable, Equatable {
///     var count = 0
/// }
///
/// enum AppAction: Sendable {
///     case increment
///     case decrement
/// }
///
/// let store = PrismStore(
///     initialState: AppState(),
///     reduce: { state, action in
///         switch action {
///         case .increment: state.count += 1
///         case .decrement: state.count -= 1
///         }
///         return .none
///     }
/// )
///
/// store.send(.increment)
/// ```
@MainActor
@Observable
public final class PrismStore<State: Sendable, Action: Sendable> {
    /// The current state managed by the store.
    public private(set) var state: State

    @ObservationIgnored
    private let reducer: (@MainActor @Sendable (inout State, Action) -> PrismEffect<Action>)?

    @ObservationIgnored
    private let forwardAction: (@MainActor @Sendable (Action) -> Void)?

    @ObservationIgnored
    private let onDeinit: (@Sendable () -> Void)?

    @ObservationIgnored
    private var effectTasks = [UUID: Task<Void, Never>]()

    @ObservationIgnored
    private var scopedStateObservers = [UUID: @MainActor @Sendable (State) -> Void]()

    /// Creates a store with the given initial state and a typed reducer.
    ///
    /// - Parameters:
    ///   - initialState: The initial value of the store's state.
    ///   - reducer: A ``PrismReducer`` that processes actions and returns effects.
    public init<Reducer: PrismReducer>(
        initialState: State,
        reducer: Reducer
    )
    where
        Reducer.State == State,
        Reducer.Action == Action
    {
        self.state = initialState
        self.reducer = { state, action in
            reducer.reduce(
                into: &state,
                action: action
            )
        }
        self.forwardAction = nil
        self.onDeinit = nil
    }

    /// Creates a store with the given initial state and a closure-based reducer.
    ///
    /// This is a convenience initializer that wraps the closure in a ``PrismReduce`` instance.
    ///
    /// - Parameters:
    ///   - initialState: The initial value of the store's state.
    ///   - reduce: A closure that mutates state in response to an action and returns an effect.
    public convenience init(
        initialState: State,
        reduce: @escaping @MainActor @Sendable (inout State, Action) -> PrismEffect<Action>
    ) {
        self.init(
            initialState: initialState,
            reducer: PrismReduce(reduce)
        )
    }

    /// Creates a store with the given initial state, a typed reducer, and middleware.
    ///
    /// The middleware intercepts every action after the reducer runs, enabling
    /// cross-cutting concerns such as logging or analytics.
    ///
    /// - Parameters:
    ///   - initialState: The initial value of the store's state.
    ///   - reducer: A ``PrismReducer`` that processes actions and returns effects.
    ///   - middleware: A ``PrismMiddleware`` that runs after each action is reduced.
    public convenience init<Reducer: PrismReducer, Middleware: PrismMiddleware>(
        initialState: State,
        reducer: Reducer,
        middleware: Middleware
    )
    where
        Reducer.State == State,
        Reducer.Action == Action,
        Middleware.State == State,
        Middleware.Action == Action
    {
        self.init(
            initialState: initialState,
            reducer: reducer.handling(with: middleware)
        )
    }

    private init(
        initialState: State,
        send: @escaping @MainActor @Sendable (Action) -> Void,
        onDeinit: @escaping @Sendable () -> Void
    ) {
        self.state = initialState
        self.reducer = nil
        self.forwardAction = send
        self.onDeinit = onDeinit
    }

    deinit {
        effectTasks.values.forEach { $0.cancel() }
        onDeinit?()
    }

    /// Sends an action to the store for immediate processing.
    ///
    /// The action is passed through the reducer (or forwarded to the parent store
    /// when this is a scoped store). Any resulting effects are executed asynchronously.
    ///
    /// - Parameter action: The action to process.
    public func send(_ action: Action) {
        if let forwardAction {
            forwardAction(action)
            return
        }

        guard let reducer else { return }

        process(
            action,
            using: reducer
        )
    }

    /// Asynchronously dispatches an action to the store.
    ///
    /// This is an `async` wrapper around ``send(_:)`` for use in asynchronous contexts.
    ///
    /// - Parameter action: The action to dispatch.
    public func dispatch(action: Action) async {
        send(action)
    }

    /// Derives a child store by mapping state and actions.
    ///
    /// The returned store stays synchronized with this parent store.
    /// Actions sent to the child are transformed and forwarded to the parent,
    /// and state changes in the parent are projected back into the child.
    ///
    /// - Parameters:
    ///   - toLocalState: A closure that extracts local state from the parent state.
    ///   - fromLocalAction: A closure that converts a local action into a parent action.
    /// - Returns: A scoped ``PrismStore`` with the derived state and action types.
    public func scope<LocalState: Sendable, LocalAction: Sendable>(
        state toLocalState: @escaping @MainActor @Sendable (State) -> LocalState,
        action fromLocalAction: @escaping @MainActor @Sendable (LocalAction) -> Action
    ) -> PrismStore<LocalState, LocalAction> {
        let id = UUID()
        let childStore = PrismStore<LocalState, LocalAction>(
            initialState: toLocalState(state),
            send: { [weak self] action in
                self?.send(fromLocalAction(action))
            },
            onDeinit: { [weak self] in
                Task { @MainActor in
                    self?.removeScopedStoreObserver(id)
                }
            }
        )

        scopedStateObservers[id] = { [weak childStore] state in
            childStore?.replaceState(
                with: toLocalState(state)
            )
        }

        return childStore
    }

    /// Derives a child store using a key path for state and a closure for actions.
    ///
    /// - Parameters:
    ///   - keyPath: A key path into the parent state that selects the local state.
    ///   - fromLocalAction: A closure that converts a local action into a parent action.
    /// - Returns: A scoped ``PrismStore`` with the derived state and action types.
    public func scope<LocalState: Sendable, LocalAction: Sendable>(
        state keyPath: KeyPath<State, LocalState>,
        action fromLocalAction: @escaping @MainActor @Sendable (LocalAction) -> Action
    ) -> PrismStore<LocalState, LocalAction> {
        scope(
            state: { state in
                state[keyPath: keyPath]
            },
            action: fromLocalAction
        )
    }

    /// Derives a child store that shares the same action type, selecting state via a key path.
    ///
    /// - Parameter keyPath: A key path into the parent state that selects the local state.
    /// - Returns: A scoped ``PrismStore`` whose actions pass through unchanged.
    public func scope<LocalState: Sendable>(
        state keyPath: KeyPath<State, LocalState>
    ) -> PrismStore<LocalState, Action> {
        scope(
            state: keyPath,
            action: { action in
                action
            }
        )
    }

    /// Cancels all in-flight effect tasks managed by this store.
    public func cancelEffects() {
        effectTasks.values.forEach { $0.cancel() }
        effectTasks.removeAll()
    }

    var hasInFlightEffects: Bool {
        !effectTasks.isEmpty
    }

    func replaceState(with state: State) {
        self.state = state
        syncScopedStores()
    }

    private func process(
        _ action: Action,
        using reducer: @MainActor @Sendable (inout State, Action) -> PrismEffect<Action>
    ) {
        let effect = reducer(
            &state,
            action
        )

        syncScopedStores()
        handle(effect)
    }

    private func syncScopedStores() {
        for observer in scopedStateObservers.values {
            observer(state)
        }
    }

    private func removeScopedStoreObserver(_ id: UUID) {
        scopedStateObservers.removeValue(forKey: id)
    }

    private func handle(_ effect: PrismEffect<Action>) {
        guard !effect.isEmpty else {
            return
        }

        let id = UUID()

        effectTasks[id] = Task { [weak self] in
            guard let self else { return }

            defer {
                Task { @MainActor [weak self] in
                    self?.effectTasks.removeValue(forKey: id)
                }
            }

            for await action in effect.actions {
                guard !Task.isCancelled else { break }
                await self.dispatch(action: action)
            }
        }
    }
}
