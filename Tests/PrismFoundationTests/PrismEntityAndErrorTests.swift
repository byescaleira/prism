import Foundation
import Testing

@testable import PrismFoundation

struct PrismEntityAndErrorTests {
    @Test
    func entityDescriptionUsesJSONRepresentation() throws {
        let entity = SampleEntity(name: "Prism", count: 7)
        let data = try #require(entity.description.data(using: .utf8))
        let decoded: SampleEntity = try data.entity(for: SampleEntity.self)

        #expect(decoded == entity)
    }

    @Test
    func entityDescriptionFallsBackWhenEncodingFails() {
        let entity = BrokenEntity()

        #expect(entity.description == BrokenEncodingError.forced.localizedDescription)
    }

    @Test
    func entityAndEntityArraysCanLogWithoutCrashing() {
        SampleEntity(name: "Prism", count: 7).log()
        BrokenEntity().log()
        [SampleEntity(name: "Prism", count: 7)].log()
        [BrokenEntity()].log()
    }

    @Test
    func prismErrorLogsDetailedAndMinimalVariants() {
        SamplePrismError.detailed.log()
        SamplePrismError.minimal.log()

        #expect(SamplePrismError.detailed.errorDescription == "Something went wrong")
        #expect(SamplePrismError.minimal.failureReason == nil)
    }
}
