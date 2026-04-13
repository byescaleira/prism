//
//  PrismEffect.swift
//  Prism
//
//  Created by Rafael Escaleira on 08/04/26.
//

import Foundation

public struct PrismEffect<Action: Sendable>: Sendable {
    private let isKnownEmpty: Bool
    private let makeActions: @Sendable () -> AsyncStream<Action>

    public init(
        isEmpty: Bool = false,
        _ makeActions: @escaping @Sendable () -> AsyncStream<Action>
    ) {
        self.isKnownEmpty = isEmpty
        self.makeActions = makeActions
    }

    public var actions: AsyncStream<Action> {
        makeActions()
    }

    var isEmpty: Bool {
        isKnownEmpty
    }
}

extension PrismEffect {
    public static var none: Self {
        Self(isEmpty: true) {
            AsyncStream { continuation in
                continuation.finish()
            }
        }
    }

    public static func send(_ action: Action) -> Self {
        sequence([action])
    }

    public static func sequence<S: Sequence>(
        _ actions: S
    ) -> Self where S.Element == Action {
        let values = Array(actions)

        return Self(isEmpty: values.isEmpty) {
            AsyncStream { continuation in
                for action in values {
                    continuation.yield(action)
                }
                continuation.finish()
            }
        }
    }

    public static func run(
        priority: TaskPriority? = nil,
        _ operation: @escaping @Sendable (@escaping @Sendable (Action) -> Void) async -> Void
    ) -> Self {
        Self {
            AsyncStream { continuation in
                let task = Task(priority: priority) {
                    await operation { action in
                        continuation.yield(action)
                    }
                    continuation.finish()
                }

                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }
    }

    public static func merge(_ effects: Self...) -> Self {
        merge(effects)
    }

    public static func merge(_ effects: [Self]) -> Self {
        let nonEmptyEffects = effects.filter { !$0.isEmpty }

        if nonEmptyEffects.isEmpty {
            return .none
        }

        if nonEmptyEffects.count == 1, let effect = nonEmptyEffects.first {
            return effect
        }

        return Self {
            AsyncStream { continuation in
                let task = Task {
                    await withTaskGroup(of: Void.self) { group in
                        for effect in nonEmptyEffects {
                            group.addTask {
                                for await action in effect.actions {
                                    continuation.yield(action)
                                }
                            }
                        }

                        await group.waitForAll()
                        continuation.finish()
                    }
                }

                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }
    }
}
