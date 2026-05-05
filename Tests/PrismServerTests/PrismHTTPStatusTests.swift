import Testing

@testable import PrismServer

@Suite("PrismHTTPStatus Tests")
struct PrismHTTPStatusTests {

    @Test("Common status codes have correct values")
    func statusCodes() {
        #expect(PrismHTTPStatus.ok.code == 200)
        #expect(PrismHTTPStatus.created.code == 201)
        #expect(PrismHTTPStatus.noContent.code == 204)
        #expect(PrismHTTPStatus.notFound.code == 404)
        #expect(PrismHTTPStatus.internalServerError.code == 500)
        #expect(PrismHTTPStatus.unauthorized.code == 401)
        #expect(PrismHTTPStatus.forbidden.code == 403)
        #expect(PrismHTTPStatus.badRequest.code == 400)
        #expect(PrismHTTPStatus.tooManyRequests.code == 429)
    }

    @Test("Reason phrases are correct")
    func reasonPhrases() {
        #expect(PrismHTTPStatus.ok.reason == "OK")
        #expect(PrismHTTPStatus.notFound.reason == "Not Found")
        #expect(PrismHTTPStatus.internalServerError.reason == "Internal Server Error")
    }

    @Test("Custom status code")
    func customStatus() {
        let custom = PrismHTTPStatus(code: 418, reason: "I'm a teapot")
        #expect(custom.code == 418)
        #expect(custom.reason == "I'm a teapot")
    }

    @Test("Equatable conformance")
    func equatable() {
        #expect(PrismHTTPStatus.ok == PrismHTTPStatus(code: 200, reason: "OK"))
        #expect(PrismHTTPStatus.ok != PrismHTTPStatus.notFound)
    }

    @Test("Redirect status codes")
    func redirectCodes() {
        #expect(PrismHTTPStatus.movedPermanently.code == 301)
        #expect(PrismHTTPStatus.found.code == 302)
        #expect(PrismHTTPStatus.temporaryRedirect.code == 307)
        #expect(PrismHTTPStatus.permanentRedirect.code == 308)
        #expect(PrismHTTPStatus.notModified.code == 304)
    }
}
