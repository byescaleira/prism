import Testing

@testable import PrismArchitecture

@MainActor
struct PrismTestStoreTests {
    @Test
    func sendReturnsLatestStateAndWaitForEffectsSettles() async {
        let store = PrismTestStore(
            initialState: CounterState(),
            reducer: makeCounterReducer()
        )

        let immediateState = store.send(.increment)
        store.send(.startReducerEffect)
        let settled = await store.waitForEffects()

        #expect(immediateState.count == 1)
        #expect(settled)
        #expect(store.state.count == 3)
    }

    @Test
    func reduceInitializerBuildsTestStoreFromClosure() {
        let store = PrismTestStore<CounterState, CounterAction>(initialState: CounterState()) { state, action in
            guard action == .increment else { return .none }
            state.count = 5
            return .none
        }

        let state = store.send(.increment)

        #expect(state.count == 5)
        #expect(store.state.count == 5)
    }

    @Test
    func middlewareInitializerAndWaitUntilObserveAsyncChanges() async {
        let middleware = PrismSideEffect<CounterState, CounterAction> { _, action in
            guard action == .startMiddlewareEffect else { return .none }
            return .send(.setReadyTitle)
        }
        let store = PrismTestStore(
            initialState: CounterState(),
            reducer: makeCounterReducer(),
            middleware: middleware
        )

        store.send(.startMiddlewareEffect)
        let reachedExpectedState = await store.waitUntil {
            $0.title == "Ready"
        }

        #expect(reachedExpectedState)
    }

    @Test
    func waitHelpersReturnFalseWhenWorkDoesNotFinishBeforeDeadline() async {
        let store = PrismTestStore(
            initialState: CounterState(),
            reducer: makeCounterReducer()
        )

        store.send(.longRunningEffect)
        let effectTimedOut = await store.waitForEffects(
            timeout: .milliseconds(5),
            pollInterval: .milliseconds(1)
        )
        let stateTimedOut = await store.waitUntil(
            { $0.title == "Never" },
            timeout: .milliseconds(5),
            pollInterval: .milliseconds(1)
        )
        store.store.cancelEffects()

        #expect(effectTimedOut == false)
        #expect(stateTimedOut == false)
    }
}
