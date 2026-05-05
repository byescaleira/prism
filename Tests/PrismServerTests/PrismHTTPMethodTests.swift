import Testing

@testable import PrismServer

@Suite("PrismHTTPMethod Tests")
struct PrismHTTPMethodTests {

    @Test("All HTTP methods have correct raw values")
    func rawValues() {
        #expect(PrismHTTPMethod.GET.rawValue == "GET")
        #expect(PrismHTTPMethod.POST.rawValue == "POST")
        #expect(PrismHTTPMethod.PUT.rawValue == "PUT")
        #expect(PrismHTTPMethod.PATCH.rawValue == "PATCH")
        #expect(PrismHTTPMethod.DELETE.rawValue == "DELETE")
        #expect(PrismHTTPMethod.HEAD.rawValue == "HEAD")
        #expect(PrismHTTPMethod.OPTIONS.rawValue == "OPTIONS")
        #expect(PrismHTTPMethod.TRACE.rawValue == "TRACE")
        #expect(PrismHTTPMethod.CONNECT.rawValue == "CONNECT")
    }

    @Test("CaseIterable returns all 9 methods")
    func caseIterable() {
        #expect(PrismHTTPMethod.allCases.count == 9)
    }

    @Test("Init from raw value")
    func initFromRaw() {
        #expect(PrismHTTPMethod(rawValue: "GET") == .GET)
        #expect(PrismHTTPMethod(rawValue: "INVALID") == nil)
    }
}
