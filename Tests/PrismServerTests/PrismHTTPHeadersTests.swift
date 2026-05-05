import Testing

@testable import PrismServer

@Suite("PrismHTTPHeaders Tests")
struct PrismHTTPHeadersTests {

    @Test("Set and get header value")
    func setAndGet() {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/json")
        #expect(headers.value(for: "Content-Type") == "application/json")
    }

    @Test("Case-insensitive lookup")
    func caseInsensitive() {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "text/html")
        #expect(headers.value(for: "content-type") == "text/html")
        #expect(headers.value(for: "CONTENT-TYPE") == "text/html")
    }

    @Test("Add multiple values for same header")
    func addMultiple() {
        var headers = PrismHTTPHeaders()
        headers.add(name: "Set-Cookie", value: "a=1")
        headers.add(name: "Set-Cookie", value: "b=2")
        #expect(headers.values(for: "Set-Cookie").count == 2)
        #expect(headers.value(for: "Set-Cookie") == "a=1")
    }

    @Test("Set replaces existing values")
    func setReplaces() {
        var headers = PrismHTTPHeaders()
        headers.add(name: "Accept", value: "text/html")
        headers.add(name: "Accept", value: "application/json")
        headers.set(name: "Accept", value: "text/plain")
        #expect(headers.values(for: "Accept") == ["text/plain"])
    }

    @Test("Remove header")
    func removeHeader() {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Authorization", value: "Bearer token")
        headers.remove(name: "Authorization")
        #expect(headers.value(for: "Authorization") == nil)
    }

    @Test("Init with array")
    func initWithArray() {
        let headers = PrismHTTPHeaders([("Host", "example.com"), ("Accept", "text/html")])
        #expect(headers.value(for: "Host") == "example.com")
        #expect(headers.count == 2)
    }

    @Test("Entries returns all headers")
    func entries() {
        var headers = PrismHTTPHeaders()
        headers.set(name: "A", value: "1")
        headers.set(name: "B", value: "2")
        #expect(headers.entries.count == 2)
    }

    @Test("Missing header returns nil")
    func missingHeader() {
        let headers = PrismHTTPHeaders()
        #expect(headers.value(for: "X-Custom") == nil)
        #expect(headers.values(for: "X-Custom").isEmpty)
    }
}
