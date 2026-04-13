import Foundation
import Testing

@testable import PrismFoundation

struct DateExtensionsTests {
    @Test
    func dateNumericHelpersReturnEpochBasedValues() {
        let date = Date(timeIntervalSince1970: 1234.567)

        #expect(date.timestamp == 1234)
        #expect(date.milliseconds == 1_234_567)
    }

    @Test
    func relativeDateHelpersMatchCalendarExpectations() throws {
        let now = Date()
        let yesterday = try #require(Calendar.current.date(byAdding: .day, value: -1, to: now))
        let tomorrow = try #require(Calendar.current.date(byAdding: .day, value: 1, to: now))

        #expect(now.isToday)
        #expect(yesterday.isYesterday)
        #expect(tomorrow.isTomorrow)
    }

    @Test
    func dateFormatsWithPrismDateFormatter() {
        let formatter = StubDateFormatter(format: "yyyy-MM-dd")
        let date = Date(timeIntervalSince1970: 1_744_070_400)

        #expect(date.string(with: formatter) == "2025-04-08")
    }
}
