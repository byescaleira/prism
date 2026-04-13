import Testing

@testable import PrismArchitecture

@MainActor
struct PrismReducerAndMiddlewareTests {
    @Test
    func combinedReducersMutateStateAndMergeEffects() async {
        let incrementReducer = PrismReduce<CounterState, CounterAction> { state, action in
            guard action == .increment else { return .none }
            state.count += 1
            return .send(.setReadyTitle)
        }
        let titleReducer = PrismReduce<CounterState, CounterAction> { state, action in
            guard action == .setReadyTitle else { return .none }
            state.title = "Ready"
            return .none
        }
        let reducer = PrismReduce.combine(
            incrementReducer,
            titleReducer
        )
        let store = PrismStore(
            initialState: CounterState(),
            reducer: reducer
        )

        store.send(.increment)
        await settleTasks()

        #expect(store.state.count == 1)
        #expect(store.state.title == "Ready")
    }

    @Test
    func combinedMiddlewaresMergeTheirEffects() async {
        let first = PrismSideEffect<CounterState, CounterAction> { _, action in
            guard action == .startMiddlewareEffect else { return .none }
            return .send(.increment)
        }
        let second = PrismSideEffect<CounterState, CounterAction> { _, action in
            guard action == .startMiddlewareEffect else { return .none }
            return .send(.setReadyTitle)
        }
        let middleware = PrismSideEffect.combine(
            first,
            second
        )
        let store = PrismStore(
            initialState: CounterState(),
            reducer: makeCounterReducer(),
            middleware: middleware
        )

        store.send(.startMiddlewareEffect)
        await settleTasks()

        #expect(store.state.count == 1)
        #expect(store.state.title == "Ready")
    }

    @Test
    func erasedMiddlewareAndNoneMiddlewareBehaveAsExpected() async {
        let noneEffect = await collectActions(
            from: AnyPrismMiddleware(
                PrismSideEffect<CounterState, CounterAction>.none
            ).run(
                state: CounterState(),
                action: .increment
            )
        )
        let middleware = AnyPrismMiddleware(
            PrismSideEffect<CounterState, CounterAction> { _, action in
                guard action == .startMiddlewareEffect else { return .none }
                return .send(.setReadyTitle)
            }
        )
        let store = PrismStore(
            initialState: CounterState(),
            reducer: makeCounterReducer(),
            middleware: middleware
        )

        store.send(.startMiddlewareEffect)
        await settleTasks()

        #expect(noneEffect.isEmpty)
        #expect(store.state.title == "Ready")
    }
}
