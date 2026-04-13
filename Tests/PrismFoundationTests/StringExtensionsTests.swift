import Foundation
import Testing

@testable import PrismFoundation

struct StringExtensionsTests {
    @Test
    func stableHashIsDeterministic() {
        let value = "Prism"

        #expect(value.stableHash == value.stableHash)
    }

    @Test
    func stableHashChangesWhenContentChanges() {
        #expect("Prism".stableHash != "Prism Core".stableHash)
    }

    @Test
    func basicStringHelpersReturnExpectedValues() {
        #expect("Prism".breakLine == "Prism\n")
        #expect(String.breakLine == "\n")
        #expect("Prism".space == "Prism ")
        #expect(String.space == " ")
        #expect("42".int == 42)
        #expect("42.5".double == 42.5)
        #expect("São Paulo".normalized == "sao paulo")
    }

    @Test
    func stringConvertsToDateUsingFormatter() {
        let formatter = StubDateFormatter(format: "yyyy-MM-dd")
        let date = "2026-04-08".date(with: formatter)

        #expect(date == formatter.rawValue.date(from: "2026-04-08"))
    }

    @Test
    func substringStableHashMatchesItsContent() {
        let value = "Prism".dropFirst()

        #expect(value.stableHash == "yze".stableHash)
    }
}
