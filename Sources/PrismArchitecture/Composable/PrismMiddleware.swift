//
//  PrismMiddleware.swift
//  Prism
//
//  Created by Rafael Escaleira on 12/04/25.
//

public protocol PrismMiddleware: Sendable {
    associatedtype State: Sendable
    associatedtype Action: Sendable

    func run(
        state: State,
        action: Action
    ) -> PrismEffect<Action>
}

public struct PrismSideEffect<State: Sendable, Action: Sendable>: PrismMiddleware {
    private let operation: @Sendable (State, Action) -> PrismEffect<Action>

    public init(
        _ operation: @escaping @Sendable (State, Action) -> PrismEffect<Action>
    ) {
        self.operation = operation
    }

    public func run(
        state: State,
        action: Action
    ) -> PrismEffect<Action> {
        operation(state, action)
    }
}

extension PrismSideEffect {
    public static var none: Self {
        Self { _, _ in
            .none
        }
    }

    public static func combine(_ middlewares: Self...) -> Self {
        combine(middlewares)
    }

    public static func combine(_ middlewares: [Self]) -> Self {
        Self { state, action in
            .merge(
                middlewares.map {
                    $0.run(
                        state: state,
                        action: action
                    )
                }
            )
        }
    }
}

public struct AnyPrismMiddleware<State: Sendable, Action: Sendable>: PrismMiddleware {
    private let operation: @Sendable (State, Action) -> PrismEffect<Action>

    public init<Middleware: PrismMiddleware>(_ middleware: Middleware)
    where
        Middleware.State == State,
        Middleware.Action == Action
    {
        self.operation = { state, action in
            middleware.run(
                state: state,
                action: action
            )
        }
    }

    public func run(
        state: State,
        action: Action
    ) -> PrismEffect<Action> {
        operation(state, action)
    }
}
