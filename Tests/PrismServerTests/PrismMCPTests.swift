import Foundation
import Testing

@testable import PrismServer

@Suite("PrismMCPTypes Tests")
struct PrismMCPTypesTests {

    @Test("PrismMCPTool stores name and description")
    func toolFields() {
        let tool = PrismMCPTool(name: "search", description: "Search things")
        #expect(tool.name == "search")
        #expect(tool.description == "Search things")
    }

    @Test("PrismMCPResource stores uri and name")
    func resourceFields() {
        let resource = PrismMCPResource(uri: "file:///data.txt", name: "data", description: "Data file")
        #expect(resource.uri == "file:///data.txt")
        #expect(resource.name == "data")
        #expect(resource.mimeType == "text/plain")
    }

    @Test("PrismMCPContent text case")
    func contentText() {
        let content = PrismMCPContent.text("hello")
        let json = content.toJSON()
        #expect(json["type"] as? String == "text")
        #expect(json["text"] as? String == "hello")
    }

    @Test("PrismMCPContent image case")
    func contentImage() {
        let content = PrismMCPContent.image(data: "base64data", mimeType: "image/png")
        let json = content.toJSON()
        #expect(json["type"] as? String == "image")
        #expect(json["data"] as? String == "base64data")
    }

    @Test("PrismMCPToolResult text convenience")
    func toolResultText() {
        let result = PrismMCPToolResult.text("done")
        #expect(result.content.count == 1)
        #expect(result.isError == false)
    }

    @Test("PrismMCPToolResult error convenience")
    func toolResultError() {
        let result = PrismMCPToolResult.error("failed")
        #expect(result.isError == true)
    }

    @Test("PrismMCPMessage stores role and content")
    func message() {
        let msg = PrismMCPMessage(role: .user, content: .text("hello"))
        #expect(msg.role == .user)
        let json = msg.toJSON()
        #expect(json["role"] as? String == "user")
    }

    @Test("PrismMCPPrompt stores arguments")
    func prompt() {
        let arg = PrismMCPPromptArgument(name: "topic", description: "The topic", required: true)
        let prompt = PrismMCPPrompt(name: "summarize", description: "Summarize", arguments: [arg])
        #expect(prompt.arguments.count == 1)
        #expect(prompt.arguments[0].required == true)
    }
}

@Suite("PrismMCPServer Tests")
struct PrismMCPServerTests {

    private func makeRequest(method: String, params: [String: Any] = [:], id: Int = 1) -> Data {
        let dict: [String: Any] = [
            "jsonrpc": "2.0",
            "method": method,
            "params": params,
            "id": id,
        ]
        return (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
    }

    private func parseResponse(_ data: Data) -> [String: Any]? {
        try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    @Test("Handles initialize")
    func initialize() async {
        let server = PrismMCPServer(name: "TestServer", version: "0.1.0")
        let response = await server.handleRequestData(makeRequest(method: "initialize"))
        let json = parseResponse(response)
        let result = json?["result"] as? [String: Any]
        #expect(result?["protocolVersion"] as? String == "2024-11-05")
        let serverInfo = result?["serverInfo"] as? [String: Any]
        #expect(serverInfo?["name"] as? String == "TestServer")
    }

    @Test("Handles ping")
    func ping() async {
        let server = PrismMCPServer()
        let response = await server.handleRequestData(makeRequest(method: "ping"))
        let json = parseResponse(response)
        #expect(json?["result"] != nil)
    }

    @Test("Registers and lists tools")
    func toolsList() async {
        let server = PrismMCPServer()
        await server.registerTool("echo", description: "Echo input") { args in
            .text(args.string("message") ?? "")
        }
        let response = await server.handleRequestData(makeRequest(method: "tools/list"))
        let json = parseResponse(response)
        let result = json?["result"] as? [String: Any]
        let tools = result?["tools"] as? [[String: Any]]
        #expect(tools?.count == 1)
        #expect(tools?[0]["name"] as? String == "echo")
    }

    @Test("Calls registered tool")
    func toolsCall() async {
        let server = PrismMCPServer()
        await server.registerTool("greet", description: "Greet") { args in
            let name = args.string("name") ?? "world"
            return .text("Hello, \(name)!")
        }
        let response = await server.handleRequestData(
            makeRequest(method: "tools/call", params: ["name": "greet", "arguments": ["name": "Alice"]])
        )
        let json = parseResponse(response)
        let result = json?["result"] as? [String: Any]
        let content = result?["content"] as? [[String: Any]]
        #expect(content?[0]["text"] as? String == "Hello, Alice!")
    }

    @Test("Returns error for unknown method")
    func unknownMethod() async {
        let server = PrismMCPServer()
        let response = await server.handleRequestData(makeRequest(method: "unknown/method"))
        let json = parseResponse(response)
        let error = json?["error"] as? [String: Any]
        #expect(error?["code"] as? Int == -32601)
    }

    @Test("Returns error for missing tool")
    func missingTool() async {
        let server = PrismMCPServer()
        let response = await server.handleRequestData(
            makeRequest(method: "tools/call", params: ["name": "nonexistent"])
        )
        let json = parseResponse(response)
        let error = json?["error"] as? [String: Any]
        #expect(error != nil)
    }

    @Test("Registers and lists resources")
    func resourcesList() async {
        let server = PrismMCPServer()
        let resource = PrismMCPResource(uri: "file:///test.txt", name: "test", description: "Test file")
        await server.registerResource(resource) { "file contents" }
        let response = await server.handleRequestData(makeRequest(method: "resources/list"))
        let json = parseResponse(response)
        let result = json?["result"] as? [String: Any]
        let resources = result?["resources"] as? [[String: Any]]
        #expect(resources?.count == 1)
    }

    @Test("Reads a resource")
    func resourcesRead() async {
        let server = PrismMCPServer()
        let resource = PrismMCPResource(uri: "file:///data.txt", name: "data", description: "Data")
        await server.registerResource(resource) { "hello data" }
        let response = await server.handleRequestData(
            makeRequest(method: "resources/read", params: ["uri": "file:///data.txt"])
        )
        let json = parseResponse(response)
        let result = json?["result"] as? [String: Any]
        let contents = result?["contents"] as? [[String: Any]]
        #expect(contents?[0]["text"] as? String == "hello data")
    }
}
