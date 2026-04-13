import Foundation
import Testing

@testable import PrismFoundation

struct ArrayExtensionsTests {
    @Test
    func asyncMapTransformsElements() async {
        let result = await [1, 2, 3].asyncMap { value in
            value * 2
        }

        #expect(result == [2, 4, 6])
    }

    @Test
    func asyncCompactMapDropsNilValues() async {
        let result: [Int] = await [1, 2, 3, 4].asyncCompactMap { value in
            value.isMultiple(of: 2) ? value : nil
        }

        #expect(result == [2, 4])
    }

    @Test
    func asyncFilterKeepsMatchingValues() async {
        let result = await [1, 2, 3, 4].asyncFilter { value in
            value > 2
        }

        #expect(result == [3, 4])
    }

    @Test
    func elementConvenienceAccessorsReturnExpectedValues() {
        #expect([1, 2, 3].second == 2)
        #expect([1, 2, 3].secondToLast == 2)
        #expect([1].second == nil)
        #expect([1].secondToLast == nil)
    }

    @Test
    func chunkedSplitsArraysAndHandlesInvalidSize() {
        #expect([1, 2, 3, 4, 5].chunked(into: 2) == [[1, 2], [3, 4], [5]])
        #expect([1, 2, 3].chunked(into: 0).isEmpty)
    }

    @Test
    func optionalKeyPathSortsNilValuesLast() {
        struct Item: Equatable {
            let name: String
            let priority: Int?
        }

        let values = [
            Item(name: "b", priority: nil),
            Item(name: "c", priority: 3),
            Item(name: "a", priority: 1),
            Item(name: "d", priority: nil),
        ]

        let ascending = values.sorted(by: \.priority)
        let descending = values.sorted(by: \.priority, using: >)

        #expect(ascending.map(\.name) == ["a", "c", "b", "d"])
        #expect(descending.map(\.name) == ["c", "a", "b", "d"])
    }

    @Test
    func safeSubscriptReturnsElementOnlyWhenIndexExists() {
        let values = [10, 20, 30]

        #expect(values[safe: 1] == 20)
        #expect(values[safe: -1] == nil)
        #expect(values[safe: 3] == nil)
    }
}
