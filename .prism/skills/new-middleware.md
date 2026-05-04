# Skill: Add PrismServer Middleware

## Steps

### 1. Create Middleware File
```
Sources/PrismServer/MiddlewareName/PrismMiddlewareName.swift
```

### 2. Implementation Pattern
```swift
import PrismFoundation

/// Brief description of middleware purpose.
public struct PrismMiddlewareNameMiddleware: PrismMiddleware, Sendable {
    // Config
    private let config: Config

    public init(config: Config = .default) {
        self.config = config
    }

    public func handle(
        _ request: PrismHTTPRequest,
        next: @Sendable (PrismHTTPRequest) async throws -> PrismHTTPResponse
    ) async throws -> PrismHTTPResponse {
        // Pre-processing
        let response = try await next(request)
        // Post-processing
        return response
    }
}

// MARK: - Config

extension PrismMiddlewareNameMiddleware {
    public struct Config: Sendable {
        // config fields
        public static let `default` = Config(/* defaults */)
    }
}
```

### 3. Requirements
- [ ] Conforms to `PrismMiddleware` protocol
- [ ] Fully `Sendable`
- [ ] Config struct with sensible defaults
- [ ] Async-only, no blocking I/O
- [ ] Proper error propagation (don't swallow errors)
- [ ] DocC documentation

### 4. Registration
```swift
let server = PrismHTTPServer()
    .use(PrismMiddlewareNameMiddleware(config: .default))
```

### 5. Testing
```swift
// Tests/PrismServerTests/MiddlewareNameTests.swift
// Test: happy path, error path, config variations, middleware chain order
```
