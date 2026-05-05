import Foundation

/// Wraps PrismHTTPResponse with chainable assertion helpers for testing.
public struct PrismAssertResponse: Sendable {
    /// The response.
    public let response: PrismHTTPResponse

    /// Creates a new `PrismAssertResponse` with the specified configuration.
    public init(_ response: PrismHTTPResponse) {
        self.response = response
    }

    /// The body string.
    public var bodyString: String? {
        switch response.body {
        case .data(let data): return String(data: data, encoding: .utf8)
        case .text(let str): return str
        case .empty: return nil
        }
    }

    /// Asserts the response status matches the expected HTTP status.
    @discardableResult
    public func assertStatus(_ expected: PrismHTTPStatus) -> PrismAssertResponse {
        assert(response.status == expected, "Expected status \(expected.code) but got \(response.status.code)")
        return self
    }

    /// Asserts a response header matches the expected value.
    @discardableResult
    public func assertHeader(_ name: String, _ value: String) -> PrismAssertResponse {
        let actual = response.headers.value(for: name)
        assert(actual == value, "Expected header '\(name)' to be '\(value)' but got '\(actual ?? "nil")'")
        return self
    }

    /// Asserts the response body contains the given substring.
    @discardableResult
    public func assertBodyContains(_ substring: String) -> PrismAssertResponse {
        let body = bodyString ?? ""
        assert(body.contains(substring), "Expected body to contain '\(substring)' but body was '\(body)'")
        return self
    }

    /// Asserts that j s o n matches the expected value.
    public func assertJSON<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        let data: Data
        switch response.body {
        case .data(let d): data = d
        case .text(let s): data = Data(s.utf8)
        case .empty: throw PrismTestError.emptyBody
        }
        return try decoder.decode(type, from: data)
    }
}

/// Fluent API for building test requests.
public struct PrismRequestBuilder: Sendable {
    private var method: PrismHTTPMethod
    private var path: String
    private var headers: PrismHTTPHeaders
    private var requestBody: Data?

    private init(method: PrismHTTPMethod, path: String) {
        self.method = method
        self.path = path
        self.headers = PrismHTTPHeaders()
        self.requestBody = nil
    }

    /// Creates a GET request builder for the given path.
    public static func get(_ path: String) -> PrismRequestBuilder {
        PrismRequestBuilder(method: .GET, path: path)
    }

    /// Sends a POST request.
    public static func post(_ path: String) -> PrismRequestBuilder {
        PrismRequestBuilder(method: .POST, path: path)
    }

    /// Sends a PUT request.
    public static func put(_ path: String) -> PrismRequestBuilder {
        PrismRequestBuilder(method: .PUT, path: path)
    }

    /// Sends a PATCH request.
    public static func patch(_ path: String) -> PrismRequestBuilder {
        PrismRequestBuilder(method: .PATCH, path: path)
    }

    /// Deletes the specified resource.
    public static func delete(_ path: String) -> PrismRequestBuilder {
        PrismRequestBuilder(method: .DELETE, path: path)
    }

    /// Adds a header to the test request.
    public func header(_ name: String, _ value: String) -> PrismRequestBuilder {
        var copy = self
        copy.headers.set(name: name, value: value)
        return copy
    }

    /// Sets the raw body data for the test request.
    public func body(_ data: Data) -> PrismRequestBuilder {
        var copy = self
        copy.requestBody = data
        return copy
    }

    /// Encodes the value as JSON and sets it as the request body.
    public func jsonBody<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) -> PrismRequestBuilder {
        var copy = self
        if let data = try? encoder.encode(value) {
            copy.requestBody = data
            copy.headers.set(name: "Content-Type", value: "application/json")
            copy.headers.set(name: "Content-Length", value: "\(data.count)")
        }
        return copy
    }

    /// Builds the configured HTTP request for test execution.
    public func build() -> PrismHTTPRequest {
        PrismHTTPRequest(
            method: method,
            uri: path,
            headers: headers,
            body: requestBody
        )
    }
}

/// Errors from test utilities.
public enum PrismTestError: Error, Sendable {
    case emptyBody
    case serverNotStarted
}
