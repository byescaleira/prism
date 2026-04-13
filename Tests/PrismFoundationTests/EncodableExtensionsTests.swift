import Foundation
import Testing

@testable import PrismFoundation

struct EncodableExtensionsTests {
    @Test
    func jsonAndDataEncodeValues() throws {
        let model = SampleModel(name: "Prism", count: 7)

        let json = try model.json
        let data = try model.data()

        #expect(json.contains("\"name\""))
        #expect(json.contains("\"count\""))
        #expect(data.string.contains("\"name\""))
        #expect(data.string.contains("\"count\""))
    }

    @Test
    func dataEncodesDatesUsingRequestedStyle() throws {
        let model = SampleDatedModel(
            name: "Prism",
            date: Date(timeIntervalSince1970: 1_744_070_400)
        )

        let data = try model.data(with: .short)
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .short

        let decoded: SampleDatedModel = try #require(
            try? data.entity(
                for: SampleDatedModel.self,
                with: formatter
            )
        )

        #expect(decoded.name == "Prism")
        #expect(formatter.string(from: decoded.date) == formatter.string(from: model.date))
    }

    @Test
    func dataEncodesDatesExactlyWithCustomFormatter() throws {
        let model = SampleDatedModel(
            name: "Prism",
            date: Date(timeIntervalSince1970: 1_744_070_400)
        )

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let data = try model.data(with: formatter)
        let decoded: SampleDatedModel = try data.entity(for: SampleDatedModel.self, with: formatter)

        #expect(decoded == model)
    }

    @Test
    func encodingFailuresCanBeObservedByCallers() {
        #expect((try? BrokenEncodable().data()) == nil)
        #expect((try? BrokenEncodable().json) == nil)
    }
}
