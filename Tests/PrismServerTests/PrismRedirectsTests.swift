import Testing
import Foundation
@testable import PrismServer

@Suite("PrismRedirects Tests")
struct PrismRedirectsTests {

    @Test("Exact path redirect")
    func exactRedirect() async throws {
        let rules = [PrismRedirectRule.permanent(from: "/old", to: "/new")]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .GET, uri: "/old")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.status.code == 301)
        #expect(response.headers.value(for: PrismHTTPHeaders.location) == "/new")
    }

    @Test("Non-matching path passes through")
    func nonMatchingPassthrough() async throws {
        let rules = [PrismRedirectRule.permanent(from: "/old", to: "/new")]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .GET, uri: "/other")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("passed through")
        }

        #expect(response.status == .ok)
    }

    @Test("Temporary redirect uses 302")
    func temporaryRedirect302() async throws {
        let rules = [PrismRedirectRule.temporary(from: "/temp", to: "/dest")]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .GET, uri: "/temp")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.status.code == 302)
    }

    @Test("307 redirect")
    func redirect307() async throws {
        let rules = [PrismRedirectRule.seeOther(from: "/api/old", to: "/api/new")]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .POST, uri: "/api/old")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.status.code == 307)
    }

    @Test("308 permanent redirect")
    func redirect308() async throws {
        let rules = [PrismRedirectRule(source: "/api/v1", destination: "/api/v2", statusCode: 308)]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .GET, uri: "/api/v1")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.status.code == 308)
    }

    @Test("Query string preserved")
    func queryStringPreserved() async throws {
        let rules = [PrismRedirectRule.permanent(from: "/old", to: "/new")]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .GET, uri: "/old?page=1&sort=name")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        let location = response.headers.value(for: PrismHTTPHeaders.location) ?? ""
        #expect(location.contains("?page=1&sort=name"))
    }

    @Test("Query string not preserved when disabled")
    func queryStringNotPreserved() async throws {
        let rules = [PrismRedirectRule(source: "/old", destination: "/new", preserveQueryString: false)]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .GET, uri: "/old?page=1")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        let location = response.headers.value(for: PrismHTTPHeaders.location) ?? ""
        #expect(location == "/new")
    }

    @Test("Parameterized path redirect")
    func parameterizedRedirect() async throws {
        let rules = [PrismRedirectRule.permanent(from: "/users/:id/profile", to: "/profiles/:id")]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .GET, uri: "/users/42/profile")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.status.code == 301)
        #expect(response.headers.value(for: PrismHTTPHeaders.location) == "/profiles/42")
    }

    @Test("Regex pattern redirect")
    func regexRedirect() async throws {
        let rules = [PrismRedirectRule.pattern(from: "^/blog/(\\d{4})/(\\d{2})/(.+)$", to: "/posts/$1-$2-$3")]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .GET, uri: "/blog/2024/03/hello")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.status.code == 301)
        let location = response.headers.value(for: PrismHTTPHeaders.location) ?? ""
        #expect(location.contains("2024"))
        #expect(location.contains("hello"))
    }

    @Test("First matching rule wins")
    func firstMatchWins() async throws {
        let rules = [
            PrismRedirectRule.permanent(from: "/path", to: "/first"),
            PrismRedirectRule.permanent(from: "/path", to: "/second")
        ]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .GET, uri: "/path")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.headers.value(for: PrismHTTPHeaders.location) == "/first")
    }

    @Test("Trailing slash add action")
    func trailingSlashAdd() async throws {
        let middleware = PrismRedirectMiddleware(rules: [], trailingSlashAction: .add)
        let request = PrismHTTPRequest(method: .GET, uri: "/path")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.status.code == 301)
        #expect(response.headers.value(for: PrismHTTPHeaders.location) == "/path/")
    }

    @Test("Trailing slash remove action")
    func trailingSlashRemove() async throws {
        let middleware = PrismRedirectMiddleware(rules: [], trailingSlashAction: .remove)
        let request = PrismHTTPRequest(method: .GET, uri: "/path/")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        #expect(response.status.code == 301)
        #expect(response.headers.value(for: PrismHTTPHeaders.location) == "/path")
    }

    @Test("Trailing slash none does nothing")
    func trailingSlashNone() async throws {
        let middleware = PrismRedirectMiddleware(rules: [], trailingSlashAction: .none)
        let request = PrismHTTPRequest(method: .GET, uri: "/path")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("passed through")
        }

        #expect(response.status == .ok)
    }

    @Test("Root path not affected by trailing slash")
    func rootPathNoTrailingSlash() async throws {
        let middleware = PrismRedirectMiddleware(rules: [], trailingSlashAction: .add)
        let request = PrismHTTPRequest(method: .GET, uri: "/")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("root")
        }

        #expect(response.status == .ok)
    }

    @Test("Redirect rule convenience constructors")
    func convenienceConstructors() {
        let perm = PrismRedirectRule.permanent(from: "/a", to: "/b")
        #expect(perm.statusCode == 301)

        let temp = PrismRedirectRule.temporary(from: "/a", to: "/b")
        #expect(temp.statusCode == 302)

        let other = PrismRedirectRule.seeOther(from: "/a", to: "/b")
        #expect(other.statusCode == 307)

        let pattern = PrismRedirectRule.pattern(from: "^/x$", to: "/y", statusCode: 308)
        #expect(pattern.statusCode == 308)
        #expect(pattern.isRegex == true)
    }

    @Test("Query string appended to destination with existing query")
    func queryAppendedToExisting() async throws {
        let rules = [PrismRedirectRule.permanent(from: "/old", to: "/new?ref=redirect")]
        let middleware = PrismRedirectMiddleware(rules: rules)
        let request = PrismHTTPRequest(method: .GET, uri: "/old?page=2")

        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse.text("should not reach")
        }

        let location = response.headers.value(for: PrismHTTPHeaders.location) ?? ""
        #expect(location.contains("ref=redirect"))
        #expect(location.contains("page=2"))
    }
}
