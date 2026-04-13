import Foundation
import Testing

@testable import PrismFoundation

struct DataExtensionsTests {
    @Test
    func stringUsesLossyUTF8Decoding() {
        #expect(Data("Prism".utf8).string == "Prism")
        #expect(Data([0xFF, 0xFE]).string == "\u{FFFD}\u{FFFD}")
    }

    @Test
    func entityDecodesCodableValues() throws {
        let data = try JSONEncoder().encode(
            SampleModel(
                name: "Prism",
                count: 7
            )
        )

        let decoded: SampleModel = try #require(try? data.entity(for: SampleModel.self))
        #expect(decoded == SampleModel(name: "Prism", count: 7))
    }

    @Test
    func entityDecodesDatesWithFormatter() throws {
        let formatter = StubDateFormatter(
            format: "yyyy-MM-dd",
            locale: Locale(identifier: "en_US_POSIX")
        ).rawValue
        let data = Data(#"{"name":"Prism","date":"2026-04-08"}"#.utf8)

        let decoded: SampleDatedModel = try #require(
            try? data.entity(
                for: SampleDatedModel.self,
                with: formatter
            )
        )

        #expect(decoded.name == "Prism")
        #expect(decoded.date == formatter.date(from: "2026-04-08"))
    }

    @Test
    func fieldRangesSplitASCIIDelimitersAndHandleNonASCIIInput() {
        let data = Data("12,-34,5.67,hello".utf8)
        let ranges = data.fieldRanges(for: ",")
        let segments = ranges.compactMap { data.string(in: $0) }

        #expect(segments == ["12", "-34", "5.67", "hello"])
        #expect(
            Data("prism".utf8).fieldRanges(for: "é").map { Data("prism".utf8).string(in: $0) }
                == ["prism"]
        )
    }

    @Test
    func intParsingSupportsValidAndInvalidRanges() {
        let data = Data("42,-17,x,-".utf8)
        let ranges = data.fieldRanges(for: ",")

        #expect(data.int(in: ranges[0]) == 42)
        #expect(data.int(in: ranges[1]) == -17)
        #expect(data.int(in: ranges[2]) == nil)
        #expect(data.int(in: ranges[3]) == nil)
        #expect(data.int(in: 0..<0) == nil)
    }

    @Test
    func doubleParsingSupportsDotCommaAndNegativeValues() {
        let data = Data("5.67,-8,12,3,1.2.3,x".utf8)
        let ranges = data.fieldRanges(for: ",")

        #expect(data.double(in: ranges[0]) == 5.67)
        #expect(data.double(in: ranges[1]) == -8)
        #expect(data.double(in: ranges[2]) == 12)
        #expect(data.double(in: 0..<0) == nil)
        #expect(Data("1,25".utf8).double(in: 0..<4) == 1.25)
        #expect(Data("-".utf8).double(in: 0..<1) == nil)
        #expect(Data("1.2.3".utf8).double(in: 0..<5) == nil)
        #expect(Data("abc".utf8).double(in: 0..<3) == nil)
    }

    @Test
    func byteParsingRequiresSingleByteRanges() {
        let data = Data("AB".utf8)

        #expect(data.byte(in: 0..<1) == UInt8(ascii: "A"))
        #expect(data.byte(in: 0..<2) == nil)
        #expect(data.byte(in: 0..<0) == nil)
    }

    @Test
    func asciiComparisonHelpersReturnExpectedResults() {
        let data = Data("hello".utf8)

        #expect(data.equalsASCII("hello", in: 0..<5))
        #expect(!data.equalsASCII("hell", in: 0..<5))
        #expect(!data.equalsASCII("world", in: 0..<5))
        #expect(data.hasPrefixASCII("he"))
        #expect(!data.hasPrefixASCII("hi"))
        #expect(!Data("h".utf8).hasPrefixASCII("hello"))
        #expect(Data().hasPrefixASCII(""))
    }

    @Test
    func stringInRangeReturnsOptionalUTF8String() {
        #expect(Data("hello".utf8).string(in: 1..<4) == "ell")
        #expect(Data([0xFF]).string(in: 0..<1) == nil)
    }
}
