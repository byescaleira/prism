import Foundation

/// Stdio transport for MCP — reads JSON-RPC from stdin, writes to stdout.
public final class PrismMCPStdioTransport: Sendable {
    private let server: PrismMCPServer

    /// Creates a new `PrismMCPStdioTransport` with the specified configuration.
    public init(server: PrismMCPServer) {
        self.server = server
    }

    /// Starts the stdio event loop. Blocks until stdin closes.
    public func run() async {
        let input = FileHandle.standardInput
        let output = FileHandle.standardOutput

        while let lineData = readLine(from: input) {
            guard !lineData.isEmpty else { continue }
            let responseData = await server.handleRequestData(lineData)
            var outData = responseData
            outData.append(UInt8(ascii: "\n"))
            output.write(outData)
        }
    }

    private func readLine(from handle: FileHandle) -> Data? {
        var buffer = Data()
        while true {
            let byte = handle.readData(ofLength: 1)
            if byte.isEmpty { return buffer.isEmpty ? nil : buffer }
            if byte[0] == UInt8(ascii: "\n") { return buffer }
            buffer.append(byte)
        }
    }
}

/// HTTP transport for MCP — PrismMiddleware that handles JSON-RPC over HTTP.
public struct PrismMCPHTTPTransport: PrismMiddleware, Sendable {
    private let server: PrismMCPServer
    private let basePath: String

    /// Creates a new `PrismMCPHTTPTransport` with the specified configuration.
    public init(server: PrismMCPServer, path: String = "/mcp") {
        self.server = server
        self.basePath = path
    }

    /// Handles the request and returns a response.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        if request.path == basePath && request.method == .POST {
            return await handleJSONRPC(request)
        }

        if request.path == "\(basePath)/sse" && request.method == .GET {
            return handleSSEEndpoint()
        }

        return try await next(request)
    }

    private func handleJSONRPC(_ request: PrismHTTPRequest) async -> PrismHTTPResponse {
        guard let body = request.body, !body.isEmpty else {
            let errorData = makeParseError()
            return jsonResponse(errorData, status: .badRequest)
        }

        let responseData = await server.handleRequestData(body)
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/json; charset=utf-8")
        headers.set(name: "Content-Length", value: "\(responseData.count)")
        return PrismHTTPResponse(status: .ok, headers: headers, body: .data(responseData))
    }

    private func handleSSEEndpoint() -> PrismHTTPResponse {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "text/event-stream")
        headers.set(name: "Cache-Control", value: "no-cache")
        headers.set(name: "Connection", value: "keep-alive")

        let sseData = "event: endpoint\ndata: \(basePath)\n\n"
        return PrismHTTPResponse(
            status: .ok,
            headers: headers,
            body: .data(Data(sseData.utf8))
        )
    }

    private func makeParseError() -> Data {
        let errorResp: [String: Any] = [
            "jsonrpc": "2.0",
            "error": ["code": -32700, "message": "Parse error"],
            "id": NSNull()
        ]
        return (try? JSONSerialization.data(withJSONObject: errorResp)) ?? Data()
    }

    private func jsonResponse(_ data: Data, status: PrismHTTPStatus) -> PrismHTTPResponse {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/json; charset=utf-8")
        headers.set(name: "Content-Length", value: "\(data.count)")
        return PrismHTTPResponse(status: status, headers: headers, body: .data(data))
    }
}
