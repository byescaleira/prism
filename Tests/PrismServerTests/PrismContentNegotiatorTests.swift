import Foundation
import Testing

@testable import PrismServer

@Suite("PrismMediaType Tests")
struct PrismMediaTypeTests {

    @Test("Parse single type")
    func parseSingle() {
        let types = PrismMediaType.parse("application/json")
        #expect(types.count == 1)
        #expect(types[0].type == "application")
        #expect(types[0].subtype == "json")
        #expect(types[0].quality == 1.0)
    }

    @Test("Parse with quality factor")
    func parseQuality() {
        let types = PrismMediaType.parse("text/html;q=0.9")
        #expect(types.count == 1)
        #expect(types[0].quality == 0.9)
    }

    @Test("Parse multiple sorted by quality")
    func parseMultiple() {
        let types = PrismMediaType.parse("text/html;q=0.9, application/json, text/plain;q=0.5")
        #expect(types.count == 3)
        #expect(types[0].fullType == "application/json")
        #expect(types[1].fullType == "text/html")
        #expect(types[2].fullType == "text/plain")
    }

    @Test("Full type string")
    func fullType() {
        let mt = PrismMediaType(type: "text", subtype: "html")
        #expect(mt.fullType == "text/html")
    }

    @Test("Matches exact type")
    func matchesExact() {
        let mt = PrismMediaType(type: "application", subtype: "json")
        #expect(mt.matches("application", "json"))
        #expect(!mt.matches("text", "html"))
    }

    @Test("Matches wildcard type")
    func matchesWildcard() {
        let mt = PrismMediaType(type: "*", subtype: "*")
        #expect(mt.matches("application", "json"))
        #expect(mt.matches("text", "html"))
    }

    @Test("Matches wildcard subtype")
    func matchesWildcardSubtype() {
        let mt = PrismMediaType(type: "text", subtype: "*")
        #expect(mt.matches("text", "html"))
        #expect(mt.matches("text", "plain"))
        #expect(!mt.matches("application", "json"))
    }
}

@Suite("PrismResponseFormat Tests")
struct PrismResponseFormatTests {

    @Test("JSON MIME type")
    func jsonMime() {
        #expect(PrismResponseFormat.json.mimeType == "application/json")
    }

    @Test("XML MIME type")
    func xmlMime() {
        #expect(PrismResponseFormat.xml.mimeType == "application/xml")
    }

    @Test("HTML MIME type")
    func htmlMime() {
        #expect(PrismResponseFormat.html.mimeType == "text/html")
    }

    @Test("CSV MIME type")
    func csvMime() {
        #expect(PrismResponseFormat.csv.mimeType == "text/csv")
    }

    @Test("Text MIME type")
    func textMime() {
        #expect(PrismResponseFormat.text.mimeType == "text/plain")
    }

    @Test("Custom MIME type")
    func customMime() {
        #expect(PrismResponseFormat.custom("image/png").mimeType == "image/png")
    }
}

@Suite("PrismContentNegotiator Tests")
struct PrismContentNegotiatorNegotiateTests {

    @Test("Picks best match")
    func bestMatch() {
        let result = PrismContentNegotiator.negotiate(
            accept: "application/json",
            available: [.json, .xml, .text]
        )
        #expect(result == .json)
    }

    @Test("Picks by quality")
    func picksByQuality() {
        let result = PrismContentNegotiator.negotiate(
            accept: "text/html;q=0.5, application/xml",
            available: [.html, .xml]
        )
        #expect(result == .xml)
    }

    @Test("Falls back to first available")
    func fallback() {
        let result = PrismContentNegotiator.negotiate(
            accept: "image/png",
            available: [.json, .text]
        )
        #expect(result == .json)
    }
}

@Suite("PrismNegotiatedResponse Tests")
struct PrismNegotiatedResponseTests {

    @Test("Renders JSON")
    func renderJSON() {
        let response = PrismNegotiatedResponse.render(data: ["name": "test"], as: .json)
        #expect(response.headers.value(for: "Content-Type")?.contains("application/json") == true)
        let body = response.serialize()
        let str = String(data: body, encoding: .utf8) ?? ""
        #expect(str.contains("name"))
    }

    @Test("Renders CSV")
    func renderCSV() {
        let response = PrismNegotiatedResponse.render(data: ["a": "1", "b": "2"], as: .csv)
        #expect(response.headers.value(for: "Content-Type")?.contains("text/csv") == true)
    }

    @Test("Renders text")
    func renderText() {
        let response = PrismNegotiatedResponse.render(data: ["key": "val"], as: .text)
        #expect(response.headers.value(for: "Content-Type")?.contains("text/plain") == true)
    }

    @Test("Renders XML")
    func renderXML() {
        let response = PrismNegotiatedResponse.render(data: ["item": "value"], as: .xml)
        #expect(response.headers.value(for: "Content-Type")?.contains("application/xml") == true)
    }

    @Test("Renders HTML")
    func renderHTML() {
        let response = PrismNegotiatedResponse.render(data: ["field": "data"], as: .html)
        #expect(response.headers.value(for: "Content-Type")?.contains("text/html") == true)
    }

    @Test("Respond uses Accept header")
    func respondUsesAccept() {
        var request = PrismHTTPRequest(method: .GET, uri: "/data")
        request.headers.set(name: "Accept", value: "text/csv")
        let response = PrismNegotiatedResponse.respond(to: request, data: ["x": "1"])
        #expect(response.headers.value(for: "Content-Type")?.contains("text/csv") == true)
    }
}
