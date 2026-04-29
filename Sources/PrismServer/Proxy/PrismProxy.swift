import Foundation

public struct PrismProxyConfig: Sendable {
    public let upstream: String
    public let pathRewrite: [String: String]
    public let timeout: TimeInterval
    public let forwardHeaders: Bool
    public let preserveHost: Bool
    public let additionalHeaders: [String: String]
    public let stripPrefix: String?

    public init(
        upstream: String,
        pathRewrite: [String: String] = [:],
        timeout: TimeInterval = 30,
        forwardHeaders: Bool = true,
        preserveHost: Bool = false,
        additionalHeaders: [String: String] = [:],
        stripPrefix: String? = nil
    ) {
        self.upstream = upstream.hasSuffix("/") ? String(upstream.dropLast()) : upstream
        self.pathRewrite = pathRewrite
        self.timeout = timeout
        self.forwardHeaders = forwardHeaders
        self.preserveHost = preserveHost
        self.additionalHeaders = additionalHeaders
        self.stripPrefix = stripPrefix
    }
}

public struct PrismProxyMiddleware: PrismMiddleware {
    private let config: PrismProxyConfig
    private let pathPrefix: String
    private let session: URLSession

    public init(pathPrefix: String = "/", config: PrismProxyConfig) {
        self.pathPrefix = pathPrefix
        self.config = config
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = config.timeout
        self.session = URLSession(configuration: sessionConfig)
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        guard request.path.hasPrefix(pathPrefix) else {
            return try await next(request)
        }

        var targetPath = request.path
        if let stripPrefix = config.stripPrefix, targetPath.hasPrefix(stripPrefix) {
            targetPath = String(targetPath.dropFirst(stripPrefix.count))
            if !targetPath.hasPrefix("/") {
                targetPath = "/" + targetPath
            }
        }

        for (from, to) in config.pathRewrite {
            targetPath = targetPath.replacingOccurrences(of: from, with: to)
        }

        let queryString: String
        if let qIdx = request.uri.firstIndex(of: "?") {
            queryString = String(request.uri[qIdx...])
        } else {
            queryString = ""
        }

        guard let url = URL(string: config.upstream + targetPath + queryString) else {
            return PrismHTTPResponse(status: .badGateway, body: .text("Invalid upstream URL"))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = config.timeout

        if config.forwardHeaders {
            for entry in request.headers.entries {
                let name = entry.name.lowercased()
                if name == "host" && !config.preserveHost { continue }
                if name == "connection" || name == "transfer-encoding" { continue }
                urlRequest.setValue(entry.value, forHTTPHeaderField: entry.name)
            }
        }

        if !config.preserveHost, let urlHost = url.host {
            urlRequest.setValue(urlHost, forHTTPHeaderField: "Host")
        }

        let clientIP = request.headers.value(for: "X-Forwarded-For") ?? request.userInfo["remoteAddress"] ?? "unknown"
        urlRequest.setValue(clientIP, forHTTPHeaderField: "X-Forwarded-For")
        urlRequest.setValue(request.headers.value(for: "Host") ?? "", forHTTPHeaderField: "X-Forwarded-Host")
        urlRequest.setValue(request.userInfo["scheme"] ?? "http", forHTTPHeaderField: "X-Forwarded-Proto")

        for (name, value) in config.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }

        if let body = request.body, !body.isEmpty {
            urlRequest.httpBody = body
        }

        do {
            let (data, urlResponse) = try await session.data(for: urlRequest)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return PrismHTTPResponse(status: .badGateway, body: .text("Invalid response from upstream"))
            }

            var headers = PrismHTTPHeaders()
            for (key, value) in httpResponse.allHeaderFields {
                let name = "\(key)"
                let val = "\(value)"
                let lower = name.lowercased()
                if lower == "transfer-encoding" || lower == "connection" { continue }
                headers.set(name: name, value: val)
            }
            headers.set(name: PrismHTTPHeaders.contentLength, value: "\(data.count)")

            let status = PrismHTTPStatus(code: httpResponse.statusCode, reason: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))

            return PrismHTTPResponse(status: status, headers: headers, body: .data(data))
        } catch {
            return PrismHTTPResponse(status: .badGateway, body: .text("Upstream error: \(error.localizedDescription)"))
        }
    }
}
