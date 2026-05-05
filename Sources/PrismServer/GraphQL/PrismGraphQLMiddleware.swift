import Foundation

/// Middleware that serves a GraphQL endpoint.
public struct PrismGraphQLMiddleware: PrismMiddleware, Sendable {
    private let schema: PrismGraphQLSchema
    private let path: String
    private let context: (any Sendable)?
    private let executor: PrismGraphQLExecutor
    private let parser: PrismGraphQLParser

    /// Creates a GraphQL middleware serving the given schema at the specified path.
    public init(schema: PrismGraphQLSchema, path: String = "/graphql", context: (any Sendable)? = nil) {
        self.schema = schema
        self.path = path
        self.context = context
        self.executor = PrismGraphQLExecutor()
        self.parser = PrismGraphQLParser()
    }

    /// Routes GraphQL requests to the executor and returns JSON results.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        guard request.path == path else {
            return try await next(request)
        }

        switch request.method {
        case .POST:
            return await handlePost(request)
        case .GET:
            return await handleGet(request)
        default:
            return try await next(request)
        }
    }

    private func handlePost(_ request: PrismHTTPRequest) async -> PrismHTTPResponse {
        guard let body = request.body,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
              let query = json["query"] as? String else {
            return errorResponse("Missing or invalid query in request body")
        }

        let variables = json["variables"] as? [String: Any] ?? [:]
        let operationName = json["operationName"] as? String

        return await executeQuery(query, variables: variables, operationName: operationName)
    }

    private func handleGet(_ request: PrismHTTPRequest) async -> PrismHTTPResponse {
        guard let query = request.queryParameters["query"], !query.isEmpty else {
            return errorResponse("Missing 'query' parameter")
        }

        var variables: [String: Any] = [:]
        if let varsString = request.queryParameters["variables"],
           let varsData = varsString.data(using: .utf8),
           let parsed = try? JSONSerialization.jsonObject(with: varsData) as? [String: Any] {
            variables = parsed
        }

        let operationName = request.queryParameters["operationName"]
        return await executeQuery(query, variables: variables, operationName: operationName)
    }

    private func executeQuery(_ query: String, variables: [String: Any], operationName: String?) async -> PrismHTTPResponse {
        let document: PrismGraphQLDocument
        do {
            document = try parser.parse(query)
        } catch {
            let result = PrismGraphQLResult(data: nil, errors: [
                PrismGraphQLError(message: "Parse error: \(error.localizedDescription)")
            ])
            return jsonResponse(result.toJSON())
        }

        let result = await executor.execute(
            document: document,
            schema: schema,
            context: context,
            variables: variables,
            operationName: operationName
        )

        return jsonResponse(result.toJSON())
    }

    private func jsonResponse(_ data: Data) -> PrismHTTPResponse {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/json; charset=utf-8")
        headers.set(name: "Content-Length", value: "\(data.count)")
        return PrismHTTPResponse(status: .ok, headers: headers, body: .data(data))
    }

    private func errorResponse(_ message: String) -> PrismHTTPResponse {
        let result = PrismGraphQLResult(data: nil, errors: [PrismGraphQLError(message: message)])
        return jsonResponse(result.toJSON())
    }
}

/// Middleware that serves GraphiQL playground UI.
public struct PrismGraphQLPlayground: PrismMiddleware, Sendable {
    private let path: String
    private let graphqlEndpoint: String

    /// Creates a GraphQL playground middleware serving the UI at the given path.
    public init(path: String = "/graphql/playground", endpoint: String = "/graphql") {
        self.path = path
        self.graphqlEndpoint = endpoint
    }

    /// Serves the GraphiQL playground HTML page for GET requests at the configured path.
    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        guard request.path == path && request.method == .GET else {
            return try await next(request)
        }

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>PrismServer GraphQL Playground</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0d1117; color: #c9d1d9; }
                .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
                h1 { font-size: 1.5rem; margin-bottom: 20px; color: #58a6ff; }
                .editor { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; height: calc(100vh - 140px); }
                textarea { width: 100%; height: 100%; background: #161b22; color: #c9d1d9; border: 1px solid #30363d;
                    border-radius: 8px; padding: 16px; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 14px;
                    resize: none; outline: none; }
                textarea:focus { border-color: #58a6ff; }
                #result { background: #161b22; color: #7ee787; }
                .toolbar { display: flex; gap: 12px; margin-bottom: 16px; align-items: center; }
                button { background: #238636; color: #fff; border: none; padding: 8px 20px; border-radius: 6px;
                    font-size: 14px; cursor: pointer; font-weight: 600; }
                button:hover { background: #2ea043; }
                input { background: #161b22; color: #c9d1d9; border: 1px solid #30363d; border-radius: 6px;
                    padding: 8px 12px; font-size: 14px; flex: 1; max-width: 400px; }
                .label { font-size: 12px; color: #8b949e; margin-bottom: 4px; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Prism GraphQL Playground</h1>
                <div class="toolbar">
                    <button onclick="executeQuery()">Execute</button>
                    <input id="variables" placeholder='Variables (JSON): {"key": "value"}' />
                </div>
                <div class="editor">
                    <div>
                        <div class="label">Query</div>
                        <textarea id="query" placeholder="{ hello }">{ __schema { queryType { name } types { name fields { name type { name } } } } }</textarea>
                    </div>
                    <div>
                        <div class="label">Result</div>
                        <textarea id="result" readonly></textarea>
                    </div>
                </div>
            </div>
            <script>
                async function executeQuery() {
                    const query = document.getElementById('query').value;
                    const varsText = document.getElementById('variables').value;
                    let variables = {};
                    try { if (varsText) variables = JSON.parse(varsText); } catch(e) {}
                    try {
                        const res = await fetch('\(graphqlEndpoint)', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ query, variables })
                        });
                        const json = await res.json();
                        document.getElementById('result').value = JSON.stringify(json, null, 2);
                    } catch(e) {
                        document.getElementById('result').value = 'Error: ' + e.message;
                    }
                }
                document.getElementById('query').addEventListener('keydown', e => {
                    if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') executeQuery();
                });
            </script>
        </body>
        </html>
        """

        let data = Data(html.utf8)
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "text/html; charset=utf-8")
        headers.set(name: "Content-Length", value: "\(data.count)")
        return PrismHTTPResponse(status: .ok, headers: headers, body: .data(data))
    }
}
