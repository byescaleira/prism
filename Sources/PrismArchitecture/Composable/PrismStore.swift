//
//  PrismStore.swift
//  Prism
//
//  Created by Rafael Escaleira on 12/04/25.
//

import Foundation
import Observation

@MainActor
@Observable
public final class PrismStore<State: Sendable, Action: Sendable> {
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

    public convenience init(
        initialState: State,
        reduce: @escaping @MainActor @Sendable (inout State, Action) -> PrismEffect<Action>
    ) {
        self.init(
            initialState: initialState,
            reducer: PrismReduce(reduce)
        )
    }

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

    public func send(_ action: Action) {
        if let forwardAction {
            forwardAction(action)
            return
        }

        process(
            action,
            using: reducer!
        )
    }

    public func dispatch(action: Action) async {
        send(action)
    }

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
