//
//  PrismReducer.swift
//  Prism
//
//  Created by Rafael Escaleira on 12/04/25.
//

@MainActor
public protocol PrismReducer: Sendable {
    associatedtype State: Sendable
    associatedtype Action: Sendable

    func reduce(
        into state: inout State,
        action: Action
    ) -> PrismEffect<Action>
}

extension PrismReducer {
    public func eraseToReduce() -> PrismReduce<State, Action> {
        PrismReduce(self.reduce)
    }

    public func handling<Middleware: PrismMiddleware>(
        with middleware: Middleware
    ) -> PrismReduce<State, Action>
    where
        Middleware.State == State,
        Middleware.Action == Action
    {
        PrismReduce { state, action in
            let reducerEffect = reduce(
                into: &state,
                action: action
            )
            let middlewareEffect = middleware.run(
                state: state,
                action: action
            )

            return .merge(
                reducerEffect,
                middlewareEffect
            )
        }
    }
}
