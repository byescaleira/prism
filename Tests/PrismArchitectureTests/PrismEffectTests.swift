import Testing

@testable import PrismArchitecture

struct PrismEffectTests {
    @Test
    func noneProducesNoActions() async {
        let actions = await collectActions(from: PrismEffect<CounterAction>.none)

        #expect(actions.isEmpty)
    }

    @Test
    func sendAndSequenceEmitActionsInOrder() async {
        let single = await collectActions(
            from: PrismEffect<CounterAction>.send(.increment)
        )
        let sequence = await collectActions(
            from: PrismEffect<CounterAction>.sequence([
                CounterAction.increment,
                .decrement,
            ])
        )

        #expect(single == [CounterAction.increment])
        #expect(sequence == [CounterAction.increment, .decrement])
    }

    @Test
    func runExecutesAsyncWorkAndMergeCollectsAllActions() async {
        let asyncEffect = PrismEffect<CounterAction>.run { send in
            send(.increment)
        }
        let merged = PrismEffect.merge(
            PrismEffect.send(.decrement),
            asyncEffect
        )

        let actions = await collectActions(from: merged)

        #expect(Set(actions) == Set([.increment, .decrement]))
        #expect(actions.count == 2)
    }

    @Test
    func mergeOfEmptyEffectsBehavesLikeNone() async {
        let actions = await collectActions(
            from: PrismEffect<CounterAction>.merge([])
        )

        #expect(actions.isEmpty)
    }

    @Test
    func mergeSkipsEmptyEffectsAndPreservesSingleNonEmptyEffect() async {
        let actions = await collectActions(
            from: PrismEffect<CounterAction>.merge([
                .none,
                .sequence([]),
                .send(.increment),
            ])
        )

        #expect(actions == [.increment])
    }
}
