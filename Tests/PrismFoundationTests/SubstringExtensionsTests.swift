import Testing

@testable import PrismFoundation

struct SubstringExtensionsTests {
    @Test
    func substringHelpersReturnExpectedValues() {
        let value = "42.5".dropFirst()

        #expect(value.string == "2.5")
        #expect("42".dropFirst().int == 2)
        #expect(value.double == 2.5)
    }
}
