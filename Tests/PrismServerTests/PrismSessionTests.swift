import Testing
import Foundation
@testable import PrismServer

@Suite("PrismSession Tests")
struct PrismSessionTests {

    @Test("Session has unique ID")
    func uniqueID() {
        let s1 = PrismSession()
        let s2 = PrismSession()
        #expect(s1.id != s2.id)
    }

    @Test("Subscript get and set")
    func subscriptAccess() {
        var session = PrismSession()
        session["user"] = "Alice"
        #expect(session["user"] == "Alice")
    }

    @Test("Session expiry check")
    func expiry() {
        let expired = PrismSession(ttl: -1)
        #expect(expired.isExpired)

        let valid = PrismSession(ttl: 3600)
        #expect(!valid.isExpired)
    }
}

@Suite("PrismMemorySessionStore Tests")
struct PrismMemorySessionStoreTests {

    @Test("Save and load session")
    func saveAndLoad() async {
        let store = PrismMemorySessionStore()
        var session = PrismSession(id: "test-id")
        session["key"] = "value"
        await store.save(session)

        let loaded = await store.load(id: "test-id")
        #expect(loaded?.data["key"] == "value")
    }

    @Test("Load returns nil for unknown ID")
    func loadMissing() async {
        let store = PrismMemorySessionStore()
        let result = await store.load(id: "unknown")
        #expect(result == nil)
    }

    @Test("Destroy removes session")
    func destroy() async {
        let store = PrismMemorySessionStore()
        await store.save(PrismSession(id: "to-delete"))
        await store.destroy(id: "to-delete")
        #expect(await store.load(id: "to-delete") == nil)
    }
}

@Suite("PrismCookie Tests")
struct PrismCookieTests {

    @Test("Header value formatting")
    func headerValue() {
        let cookie = PrismCookie(name: "session", value: "abc123", maxAge: 3600)
        let header = cookie.headerValue
        #expect(header.contains("session=abc123"))
        #expect(header.contains("Max-Age=3600"))
        #expect(header.contains("HttpOnly"))
        #expect(header.contains("Secure"))
        #expect(header.contains("SameSite=Lax"))
        #expect(header.contains("Path=/"))
    }

    @Test("Cookie with domain")
    func withDomain() {
        let cookie = PrismCookie(name: "a", value: "b", domain: "example.com")
        #expect(cookie.headerValue.contains("Domain=example.com"))
    }

    @Test("Cookie parsing from request")
    func parseCookies() {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Cookie", value: "session=abc; theme=dark")
        let request = PrismHTTPRequest(method: .GET, uri: "/", headers: headers)
        #expect(request.cookies["session"] == "abc")
        #expect(request.cookies["theme"] == "dark")
    }

    @Test("No cookies returns empty dict")
    func noCookies() {
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        #expect(request.cookies.isEmpty)
    }

    @Test("Set cookie on response")
    func setCookieOnResponse() {
        var response = PrismHTTPResponse.text("ok")
        response.setCookie(PrismCookie(name: "token", value: "xyz"))
        let values = response.headers.values(for: "Set-Cookie")
        #expect(values.count == 1)
        #expect(values[0].contains("token=xyz"))
    }
}
