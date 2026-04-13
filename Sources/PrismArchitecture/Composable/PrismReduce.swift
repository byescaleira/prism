//
//  PrismReduce.swift
//  Prism
//
//  Created by Rafael Escaleira on 08/04/26.
//

public struct PrismReduce<State: Sendable, Action: Sendable>: PrismReducer {
    private let body: @MainActor @Sendable (inout State, Action) -> PrismEffect<Action>

    public init(
        _ body: @escaping @MainActor @Sendable (inout State, Action) -> PrismEffect<Action>
    ) {
        self.body = body
    }

    public func reduce(
        into state: inout State,
        action: Action
    ) -> PrismEffect<Action> {
        body(&state, action)
    }
}

extension PrismReduce {
    public static func combine(_ reducers: Self...) -> Self {
        combine(reducers)
    }

    public static func combine(_ reducers: [Self]) -> Self {
        Self { state, action in
            var effects = [PrismEffect<Action>]()

            for reducer in reducers {
                effects.append(
                    reducer.reduce(
                        into: &state,
                        action: action
                    )
                )
            }

            return .merge(effects)
        }
    }
}
