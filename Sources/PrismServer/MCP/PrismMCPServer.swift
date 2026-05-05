import Foundation

/// Sendable wrapper for JSON dictionary values crossing actor boundaries.
public struct PrismJSONObject: @unchecked Sendable {
    /// The raw.
    public let raw: [String: Any]
    /// Creates a new `PrismJSONObject` with the specified configuration.
    public init(_ raw: [String: Any]) { self.raw = raw }

    /// Returns the raw value for the given key.
    public subscript(key: String) -> Any? { raw[key] }

    /// Returns the string value for the given key, if present.
    public func string(_ key: String) -> String? { raw[key] as? String }
    /// Returns the dictionary value for the given key, if present.
    public func dict(_ key: String) -> [String: Any]? { raw[key] as? [String: Any] }
    /// Returns the string dictionary value for the given key, if present.
    public func stringDict(_ key: String) -> [String: String]? { raw[key] as? [String: String] }
}

/// Actor-based MCP server that handles JSON-RPC 2.0 requests.
public actor PrismMCPServer {
    private let serverName: String
    private let serverVersion: String

    private var tools: [String: RegisteredTool] = [:]
    private var resources: [String: RegisteredResource] = [:]
    private var prompts: [String: RegisteredPrompt] = [:]
    private var initialized = false

    /// Creates a new `PrismMCPServer` with the specified configuration.
    public init(name: String = "PrismMCPServer", version: String = "1.0.0") {
        self.serverName = name
        self.serverVersion = version
    }

    // MARK: - Registration

    /// Registers a tool with a handler.
    public func registerTool(
        _ name: String,
        description: String,
        inputSchema: [String: any Sendable] = [:],
        handler: @escaping @Sendable (PrismJSONObject) async throws -> PrismMCPToolResult
    ) {
        let tool = PrismMCPTool(name: name, description: description, inputSchema: inputSchema)
        tools[name] = RegisteredTool(tool: tool, handler: handler)
    }

    /// Registers a resource with a handler.
    public func registerResource(
        _ resource: PrismMCPResource,
        handler: @escaping @Sendable () async throws -> String
    ) {
        resources[resource.uri] = RegisteredResource(resource: resource, handler: handler)
    }

    /// Registers a prompt template with a handler.
    public func registerPrompt(
        _ prompt: PrismMCPPrompt,
        handler: @escaping @Sendable ([String: String]) async throws -> [PrismMCPMessage]
    ) {
        prompts[prompt.name] = RegisteredPrompt(prompt: prompt, handler: handler)
    }

    // MARK: - JSON-RPC Dispatch

    /// Handles a JSON-RPC 2.0 request as Data, returns response as Data.
    public func handleRequestData(_ requestData: Data) async -> Data {
        guard let json = try? JSONSerialization.jsonObject(with: requestData) as? [String: Any] else {
            let errorResp: [String: Any] = [
                "jsonrpc": "2.0",
                "error": ["code": -32700, "message": "Parse error"],
                "id": NSNull()
            ]
            return (try? JSONSerialization.data(withJSONObject: errorResp)) ?? Data()
        }

        let id = json["id"]
        let method = json["method"] as? String ?? ""
        let params = json["params"] as? [String: Any] ?? [:]

        do {
            let result = try await dispatch(method: method, params: params)
            let resp = makeResponse(id: id, result: result)
            return (try? JSONSerialization.data(withJSONObject: resp)) ?? Data()
        } catch let error as PrismMCPError {
            let resp = makeErrorResponse(id: id, error: error)
            return (try? JSONSerialization.data(withJSONObject: resp)) ?? Data()
        } catch {
            let resp = makeErrorResponse(id: id, error: .internalError("\(error)"))
            return (try? JSONSerialization.data(withJSONObject: resp)) ?? Data()
        }
    }

    private func dispatch(method: String, params: [String: Any]) async throws -> [String: Any] {
        switch method {
        case "initialize":
            return handleInitialize()
        case "ping":
            return [:]
        case "tools/list":
            return handleToolsList()
        case "tools/call":
            return try await handleToolsCall(params)
        case "resources/list":
            return handleResourcesList()
        case "resources/read":
            return try await handleResourcesRead(params)
        case "prompts/list":
            return handlePromptsList()
        case "prompts/get":
            return try await handlePromptsGet(params)
        default:
            throw PrismMCPError.methodNotFound(method)
        }
    }

    // MARK: - Method Handlers

    private func handleInitialize() -> [String: Any] {
        initialized = true
        var capabilities: [String: Any] = [:]
        if !tools.isEmpty { capabilities["tools"] = [String: Any]() }
        if !resources.isEmpty { capabilities["resources"] = [String: Any]() }
        if !prompts.isEmpty { capabilities["prompts"] = [String: Any]() }

        return [
            "protocolVersion": "2024-11-05",
            "capabilities": capabilities,
            "serverInfo": [
                "name": serverName,
                "version": serverVersion
            ]
        ]
    }

    private func handleToolsList() -> [String: Any] {
        ["tools": tools.values.map { $0.tool.toJSON() }]
    }

    private func handleToolsCall(_ params: [String: Any]) async throws -> [String: Any] {
        guard let name = params["name"] as? String else {
            throw PrismMCPError.invalidParams("Missing 'name'")
        }
        guard let registered = tools[name] else {
            throw PrismMCPError.toolNotFound(name)
        }
        let arguments = params["arguments"] as? [String: Any] ?? [:]
        let wrappedArgs = PrismJSONObject(arguments)
        let result = try await registered.handler(wrappedArgs)
        return result.toJSON()
    }

    private func handleResourcesList() -> [String: Any] {
        ["resources": resources.values.map { $0.resource.toJSON() }]
    }

    private func handleResourcesRead(_ params: [String: Any]) async throws -> [String: Any] {
        guard let uri = params["uri"] as? String else {
            throw PrismMCPError.invalidParams("Missing 'uri'")
        }
        guard let registered = resources[uri] else {
            throw PrismMCPError.resourceNotFound(uri)
        }
        let text = try await registered.handler()
        return [
            "contents": [
                [
                    "uri": uri,
                    "mimeType": registered.resource.mimeType,
                    "text": text
                ]
            ]
        ]
    }

    private func handlePromptsList() -> [String: Any] {
        ["prompts": prompts.values.map { $0.prompt.toJSON() }]
    }

    private func handlePromptsGet(_ params: [String: Any]) async throws -> [String: Any] {
        guard let name = params["name"] as? String else {
            throw PrismMCPError.invalidParams("Missing 'name'")
        }
        guard let registered = prompts[name] else {
            throw PrismMCPError.promptNotFound(name)
        }
        let arguments = params["arguments"] as? [String: String] ?? [:]
        let messages = try await registered.handler(arguments)
        return [
            "description": registered.prompt.description,
            "messages": messages.map { $0.toJSON() }
        ]
    }

    // MARK: - JSON-RPC Response Builders

    private func makeResponse(id: Any?, result: [String: Any]) -> [String: Any] {
        var resp: [String: Any] = [
            "jsonrpc": "2.0",
            "result": result
        ]
        if let id { resp["id"] = id }
        return resp
    }

    private func makeErrorResponse(id: Any?, error: PrismMCPError) -> [String: Any] {
        let (code, message): (Int, String) = {
            switch error {
            case .methodNotFound(let m): (-32601, "Method not found: \(m)")
            case .invalidParams(let m): (-32602, "Invalid params: \(m)")
            case .toolNotFound(let n): (-32602, "Tool not found: \(n)")
            case .resourceNotFound(let u): (-32602, "Resource not found: \(u)")
            case .promptNotFound(let n): (-32602, "Prompt not found: \(n)")
            case .internalError(let m): (-32603, m)
            }
        }()

        var resp: [String: Any] = [
            "jsonrpc": "2.0",
            "error": ["code": code, "message": message]
        ]
        if let id { resp["id"] = id }
        return resp
    }
}

// MARK: - Internal Registration Types

private struct RegisteredTool: Sendable {
    let tool: PrismMCPTool
    let handler: @Sendable (PrismJSONObject) async throws -> PrismMCPToolResult
}

private struct RegisteredResource: Sendable {
    let resource: PrismMCPResource
    let handler: @Sendable () async throws -> String
}

private struct RegisteredPrompt: Sendable {
    let prompt: PrismMCPPrompt
    let handler: @Sendable ([String: String]) async throws -> [PrismMCPMessage]
}
