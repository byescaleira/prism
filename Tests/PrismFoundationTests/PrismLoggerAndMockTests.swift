import Testing

@testable import PrismFoundation

struct PrismLoggerAndMockTests {
    @Test
    func foundationLogMessageBuildsMessageValues() {
        #expect(PrismFoundationLogMessage.message("hello").value == "hello")
        #expect(
            PrismFoundationLogMessage.error(BrokenEncodingError.forced).value
                == BrokenEncodingError.forced.localizedDescription
        )
    }

    @Test
    func foundationLoggerAcceptsAllLogLevels() {
        let logger = PrismFoundationLogger()

        logger.info(.message("info"))
        logger.warning(.message("warning"))
        logger.error(.error(BrokenEncodingError.forced))
    }

    @Test
    func mockProtocolBuildsTenMocksByDefault() {
        let mocks = SampleMockValue.mocks

        #expect(mocks.count == 10)
        #expect(mocks.allSatisfy { $0 == .mock })
    }
}
