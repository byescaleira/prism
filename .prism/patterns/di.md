# Pattern: Dependency Injection

## Protocol-Based DI (default approach)
```swift
// Define protocol in lower module
public protocol HTTPClientProtocol: Sendable {
    func send(_ request: PrismHTTPRequest) async throws -> PrismHTTPResponse
}

// Real implementation
public struct PrismHTTPClient: HTTPClientProtocol { ... }

// Mock for tests
struct MockHTTPClient: HTTPClientProtocol { ... }
```

## PrismServer DI Container
```swift
let container = PrismContainer()
container.register(DatabaseProtocol.self) { PrismDatabase(config: .default) }
container.register(CacheProtocol.self) { PrismCache() }

// Resolve
let db = container.resolve(DatabaseProtocol.self)
```

## Environment-Based DI (PrismUI)
```swift
// Define environment key
private struct HTTPClientKey: EnvironmentKey {
    static let defaultValue: any HTTPClientProtocol = PrismHTTPClient()
}

extension EnvironmentValues {
    var httpClient: any HTTPClientProtocol {
        get { self[HTTPClientKey.self] }
        set { self[HTTPClientKey.self] = newValue }
    }
}

// Use in View
@Environment(\.httpClient) private var client
```

## Rules
- Inject at boundaries, not everywhere
- Default to protocol-based DI for testability
- Container DI for PrismServer (complex dependency graphs)
- Environment DI for SwiftUI
- Never use singletons for mutable state
