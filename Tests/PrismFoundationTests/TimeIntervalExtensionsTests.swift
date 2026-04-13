import Foundation
import Testing

@testable import PrismFoundation

struct TimeIntervalExtensionsTests {
    @Test
    func timeIntervalHelpersReturnExpectedValues() {
        let value: TimeInterval = 2

        #expect(value.second == 2)
        #expect(value.minute == 120)
        #expect(value.hour == 7200)
        #expect(value.day == 172800)
        #expect(value.date == Date(timeIntervalSince1970: 2))
    }

    @Test
    func yearMonthBuildsCompactIntegerRepresentation() throws {
        let interval = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            year: 2026,
            month: 4,
            day: 8
        ).date?.timeIntervalSince1970

        let value = try #require(interval)
        #expect(value.yearMonth == 202604)
    }
}
