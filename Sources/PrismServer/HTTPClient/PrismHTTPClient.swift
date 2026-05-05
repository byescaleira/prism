import Foundation

/// Configuration for the HTTP client.
public struct PrismHTTPClientConfig: Sendable {
    /// The base u r l.
    public let baseURL: String?
    /// The default headers.
    public let defaultHeaders: [String: String]
    /// The timeout.
    public let timeout: TimeInterval
    /// The retry count.
    public let retryCount: Int
    /// The retry delay.
    public let retryDelay: Duration

    /// Creates a new `PrismHTTPClientConfig` with the specified configuration.
    public init(
        baseURL: String? = nil,
        defaultHeaders: [String: String] = [:],
        timeout: TimeInterval = 30,
        retryCount: Int = 0,
        retryDelay: Duration = .seconds(1)
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeout = timeout
        self.retryCount = retryCount
        self.retryDelay = retryDelay
    }
}

/// An outbound HTTP request.
public struct PrismClientRequest: Sendable {
    /// The url.
    public var url: String
    /// The method.
    public var method: String
    /// The headers.
    public var headers: [String: String]
    /// The body.
    public var body: Data?
    /// The timeout.
    public var timeout: TimeInterval?

    /// Creates a new `PrismClientRequest` with the specified configuration.
    public init(
        url: String, method: String = "GET", headers: [String: String] = [:], body: Data? = nil,
        timeout: TimeInterval? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }
}

/// An HTTP response from the client.
public struct PrismClientResponse: Sendable {
    /// The status code.
    public let statusCode: Int
    /// The headers.
    public let headers: [String: String]
    /// The body.
    public let body: Data?

    /// Creates a new `PrismClientResponse` with the specified configuration.
    public init(statusCode: Int, headers: [String: String], body: Data?) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }

    /// The text.
    public var text: String? {
        body.flatMap { String(data: $0, encoding: .utf8) }
    }

    /// Decodes the response body as JSON into the specified type.
    public func json<T: Decodable>(_ type: T.Type = T.self, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard let body else { throw PrismHTTPClientError.requestFailed("No response body") }
        return try decoder.decode(type, from: body)
    }
}

/// Errors from the HTTP client.
public enum PrismHTTPClientError: Error, Sendable {
    case invalidURL
    case requestFailed(String)
    case timeout
}

/// Native HTTP client built on URLSession.
public struct PrismHTTPClient: Sendable {
    private let config: PrismHTTPClientConfig

    /// Creates a new `PrismHTTPClient` with the specified configuration.
    public init(config: PrismHTTPClientConfig = PrismHTTPClientConfig()) {
        self.config = config
    }

    /// Sends a request and returns the response.
    public func request(_ clientRequest: PrismClientRequest) async throws -> PrismClientResponse {
        var urlString = clientRequest.url
        if let baseURL = config.baseURL, !urlString.hasPrefix("http://"), !urlString.hasPrefix("https://") {
            urlString = baseURL.hasSuffix("/") ? baseURL + urlString : baseURL + "/" + urlString
        }

        guard let url = URL(string: urlString) else {
            throw PrismHTTPClientError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = clientRequest.method
        urlRequest.timeoutInterval = clientRequest.timeout ?? config.timeout

        for (key, value) in config.defaultHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        for (key, value) in clientRequest.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        urlRequest.httpBody = clientRequest.body

        var lastError: Error = PrismHTTPClientError.requestFailed("Unknown error")
        let maxAttempts = config.retryCount + 1

        for attempt in 0..<maxAttempts {
            if attempt > 0 {
                try await Task.sleep(for: config.retryDelay)
            }

            do {
                let (data, response) = try await URLSession.shared.data(for: urlRequest)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw PrismHTTPClientError.requestFailed("Invalid response type")
                }

                let responseHeaders = httpResponse.allHeaderFields.reduce(into: [String: String]()) { result, pair in
                    if let key = pair.key as? String, let value = pair.value as? String {
                        result[key] = value
                    }
                }

                return PrismClientResponse(
                    statusCode: httpResponse.statusCode,
                    headers: responseHeaders,
                    body: data
                )
            } catch let error as PrismHTTPClientError {
                lastError = error
            } catch is URLError {
                lastError = PrismHTTPClientError.timeout
            } catch {
                lastError = PrismHTTPClientError.requestFailed(error.localizedDescription)
            }
        }

        throw lastError
    }

    // MARK: - Convenience Methods

    /// Retrieves the value asynchronously.
    public func get(_ url: String, headers: [String: String] = [:]) async throws -> PrismClientResponse {
        try await request(PrismClientRequest(url: url, method: "GET", headers: headers))
    }

    /// Sends a POST request.
    public func post(_ url: String, body: Data? = nil, headers: [String: String] = [:]) async throws
        -> PrismClientResponse
    {
        try await request(PrismClientRequest(url: url, method: "POST", headers: headers, body: body))
    }

    /// Sends a PUT request.
    public func put(_ url: String, body: Data? = nil, headers: [String: String] = [:]) async throws
        -> PrismClientResponse
    {
        try await request(PrismClientRequest(url: url, method: "PUT", headers: headers, body: body))
    }

    /// Sends a PATCH request.
    public func patch(_ url: String, body: Data? = nil, headers: [String: String] = [:]) async throws
        -> PrismClientResponse
    {
        try await request(PrismClientRequest(url: url, method: "PATCH", headers: headers, body: body))
    }

    /// Deletes the specified resource.
    public func delete(_ url: String, headers: [String: String] = [:]) async throws -> PrismClientResponse {
        try await request(PrismClientRequest(url: url, method: "DELETE", headers: headers))
    }
}
