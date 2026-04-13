import Foundation
import Testing

@testable import PrismFoundation

struct BinaryExtensionsTests {
    @Test
    func floatingPointHelpersReturnExpectedValues() {
        let value: Double = -1234.5678

        #expect(value.abs == 1234.5678)
        #expect(value.double == -1234.5678)
        #expect(value.int == -1234)
        #expect(value.string == "-1234.5678")
        #expect(value.int64 == -1234)
        #expect(value.largeNormalized == -123_456_780_000)
        #expect(
            value.formatted(
                decimals: 2,
                locale: Locale(identifier: "en_US_POSIX")
            ) == "-1,234.57"
        )

        let currency = value.abs.currency(locale: Locale(identifier: "en_US"))
        #expect(currency?.contains("$") == true)
    }

    @Test
    func integerHelpersReturnExpectedValues() {
        let value = 1234

        #expect(value.isEven)
        #expect(!value.isOdd)
        #expect(value.double == 1234)
        #expect(value.string == "1234")
        #expect(value.timestamp == Date(timeIntervalSince1970: 1234))
        #expect(value.milliseconds == Date(timeIntervalSince1970: 1.234))
        #expect(value.formatted(withSeparator: false) == "1234")

        let grouped = 1_234_567.formatted()
        let currency = value.currency(locale: Locale(identifier: "en_US"))

        #expect(grouped != "")
        #expect(grouped != "1234567")
        #expect(currency?.contains("$") == true)
        #expect(3.isOdd)
    }
}
