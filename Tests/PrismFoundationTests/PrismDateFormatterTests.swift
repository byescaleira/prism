import Foundation
import Testing

@testable import PrismFoundation

struct PrismDateFormatterTests {
    @Test
    func convertsDateToStringAndBack() {
        let formatter = StubDateFormatter(format: "yyyy-MM-dd")
        let date = Date(timeIntervalSince1970: 1_744_070_400)

        let string = formatter.string(from: date)
        let parsed = formatter.date(from: string)

        #expect(string == "2025-04-08")
        #expect(parsed == date)
    }

    @Test
    func returnsNilWhenStringOrDateIsMissing() {
        let formatter = StubDateFormatter()

        #expect(formatter.string(from: nil) == nil)
        #expect(formatter.date(from: nil) == nil)
    }

    @Test
    func buildsFormatterWithRequestedFormatAndCurrentLocale() {
        let formatter = StubDateFormatter()
        let generated = formatter.getFormatter(from: "dd/MM/yyyy")

        #expect(generated.dateFormat == "dd/MM/yyyy")
        #expect(generated.locale == PrismLocale.current.rawValue)
    }
}
