//
//  PrismTestStore.swift
//  Prism
//
//  Created by Rafael Escaleira on 08/04/26.
//

import Foundation

@MainActor
public final class PrismTestStore<State: Sendable & Equatable, Action: Sendable> {
    public let store: PrismStore<State, Action>

    private let clock = ContinuousClock()

    public var state: State {
        store.state
    }

    public init<Reducer: PrismReducer>(
        initialState: State,
        reducer: Reducer
    )
    where
        Reducer.State == State,
        Reducer.Action == Action
    {
        self.store = PrismStore(
            initialState: initialState,
            reducer: reducer
        )
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

    public init<Reducer: PrismReducer, Middleware: PrismMiddleware>(
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
        self.store = PrismStore(
            initialState: initialState,
            reducer: reducer,
            middleware: middleware
        )
    }

    @discardableResult
    public func send(_ action: Action) -> State {
        store.send(action)
        return store.state
    }

    @discardableResult
    public func waitForEffects(
        timeout: Duration = .seconds(1),
        pollInterval: Duration = .milliseconds(10)
    ) async -> Bool {
        let deadline = clock.now.advanced(by: timeout)

        while store.hasInFlightEffects {
            if clock.now >= deadline {
                return false
            }

            try? await Task.sleep(for: pollInterval)
        }

        return true
    }

    @discardableResult
    public func waitUntil(
        _ predicate: @escaping @Sendable (State) -> Bool,
        timeout: Duration = .seconds(1),
        pollInterval: Duration = .milliseconds(10)
    ) async -> Bool {
        let deadline = clock.now.advanced(by: timeout)

        while !predicate(store.state) {
            if clock.now >= deadline {
                return false
            }

            try? await Task.sleep(for: pollInterval)
        }

        return true
    }
}
