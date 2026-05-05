import Foundation

/// An MCP tool that can be called by clients.
public struct PrismMCPTool: Sendable {
    /// The name.
    public let name: String
    /// The description.
    public let description: String
    /// The input schema.
    public let inputSchema: [String: any Sendable]

    /// Creates a new `PrismMCPTool` with the specified configuration.
    public init(name: String, description: String, inputSchema: [String: any Sendable] = [:]) {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema
    }

    func toJSON() -> [String: Any] {
        var schema: [String: Any] = ["type": "object"]
        for (k, v) in inputSchema { schema[k] = v }
        return [
            "name": name,
            "description": description,
            "inputSchema": schema
        ]
    }
}

/// An MCP resource exposed to clients.
public struct PrismMCPResource: Sendable {
    /// The uri.
    public let uri: String
    /// The name.
    public let name: String
    /// The description.
    public let description: String
    /// The mime type.
    public let mimeType: String

    /// Creates a new `PrismMCPResource` with the specified configuration.
    public init(uri: String, name: String, description: String, mimeType: String = "text/plain") {
        self.uri = uri
        self.name = name
        self.description = description
        self.mimeType = mimeType
    }

    func toJSON() -> [String: Any] {
        [
            "uri": uri,
            "name": name,
            "description": description,
            "mimeType": mimeType
        ]
    }
}

/// An MCP prompt template.
public struct PrismMCPPrompt: Sendable {
    /// The name.
    public let name: String
    /// The description.
    public let description: String
    /// The arguments.
    public let arguments: [PrismMCPPromptArgument]

    /// Creates a new `PrismMCPPrompt` with the specified configuration.
    public init(name: String, description: String, arguments: [PrismMCPPromptArgument] = []) {
        self.name = name
        self.description = description
        self.arguments = arguments
    }

    func toJSON() -> [String: Any] {
        [
            "name": name,
            "description": description,
            "arguments": arguments.map { $0.toJSON() }
        ]
    }
}

/// An argument for an MCP prompt.
public struct PrismMCPPromptArgument: Sendable {
    /// The name.
    public let name: String
    /// The description.
    public let description: String
    /// The required.
    public let required: Bool

    /// Creates a new `PrismMCPPromptArgument` with the specified configuration.
    public init(name: String, description: String, required: Bool = false) {
        self.name = name
        self.description = description
        self.required = required
    }

    func toJSON() -> [String: Any] {
        [
            "name": name,
            "description": description,
            "required": required
        ]
    }
}

/// Content returned by tools or in prompt messages.
public enum PrismMCPContent: Sendable {
    case text(String)
    case image(data: String, mimeType: String)
    case resource(uri: String, text: String, mimeType: String?)

    func toJSON() -> [String: Any] {
        switch self {
        case .text(let text):
            return ["type": "text", "text": text]
        case .image(let data, let mimeType):
            return ["type": "image", "data": data, "mimeType": mimeType]
        case .resource(let uri, let text, let mimeType):
            var dict: [String: Any] = ["type": "resource", "resource": ["uri": uri, "text": text]]
            if let mimeType {
                var res = dict["resource"] as! [String: Any]
                res["mimeType"] = mimeType
                dict["resource"] = res
            }
            return dict
        }
    }
}

/// Result from calling an MCP tool.
public struct PrismMCPToolResult: Sendable {
    /// The content.
    public let content: [PrismMCPContent]
    /// The is error.
    public let isError: Bool

    /// Creates a new `PrismMCPToolResult` with the specified configuration.
    public init(content: [PrismMCPContent], isError: Bool = false) {
        self.content = content
        self.isError = isError
    }

    /// Creates a successful tool result containing the given text.
    public static func text(_ text: String) -> PrismMCPToolResult {
        PrismMCPToolResult(content: [.text(text)])
    }

    /// Creates an error tool result with the given message.
    public static func error(_ message: String) -> PrismMCPToolResult {
        PrismMCPToolResult(content: [.text(message)], isError: true)
    }

    func toJSON() -> [String: Any] {
        var dict: [String: Any] = [
            "content": content.map { $0.toJSON() }
        ]
        if isError { dict["isError"] = true }
        return dict
    }
}

/// Role in an MCP prompt message.
public enum PrismMCPRole: String, Sendable {
    case user
    case assistant
}

/// A message in an MCP prompt response.
public struct PrismMCPMessage: Sendable {
    /// The role.
    public let role: PrismMCPRole
    /// The content.
    public let content: PrismMCPContent

    /// Creates a new `PrismMCPMessage` with the specified configuration.
    public init(role: PrismMCPRole, content: PrismMCPContent) {
        self.role = role
        self.content = content
    }

    func toJSON() -> [String: Any] {
        [
            "role": role.rawValue,
            "content": content.toJSON()
        ]
    }
}

/// MCP protocol errors.
public enum PrismMCPError: Error, Sendable {
    case methodNotFound(String)
    case invalidParams(String)
    case toolNotFound(String)
    case resourceNotFound(String)
    case promptNotFound(String)
    case internalError(String)
}
